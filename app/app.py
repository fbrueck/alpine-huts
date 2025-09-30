import streamlit as st
import folium

from streamlit_folium import folium_static

import duckdb

st.set_page_config(page_title="Alpine huts", layout="wide")

st.html("""
      <style>
          footer {visibility: hidden;}
      </style>
  """)

setup_aws_credentials = """
CREATE OR REPLACE SECRET secret (
    TYPE s3,
    PROVIDER credential_chain
);
"""

attach_glue_catalog = f"""
ATTACH IF NOT EXISTS '{st.secrets["ACCOUNT_ID"]}' AS glue_catalog (
    TYPE iceberg,
    ENDPOINT_TYPE glue
);
"""

@st.cache_data()
def fetch_data():
    duckdb.sql(setup_aws_credentials)
    duckdb.sql(attach_glue_catalog)
    result = duckdb.sql(
        "SELECT * FROM glue_catalog.alpine_huts.hut_availability"
        )
    return result.df()


data = fetch_data()

data

with st.sidebar:
    status = st.multiselect(
        "Hut status", data["hut_status"].unique(), default=["SERVICED"]
    )
    day_of_week_labels = st.multiselect(
        "Day of week", data["day_of_week_label"].unique()
    )
    availability_date = st.date_input(
        "Date",
        min_value=data["availability_date"].min(),
        max_value=data["availability_date"].max(),
    )
    list_only_available = st.checkbox("Show only available huts in list")

    if status:
        filtered_data = data[data["hut_status"].isin(status)]
    if day_of_week_labels:
        filtered_data = filtered_data[
            filtered_data["day_of_week_label"].isin(day_of_week_labels)
        ]
    if availability_date:
        filtered_data = filtered_data[
            filtered_data["availability_date"].dt.date == availability_date
        ]

    filtered_data_with_location = filtered_data.dropna(
        subset=["latitude", "longitude", "free_beds"]
    )

m = folium.Map()

bounds = []

for _, row in filtered_data_with_location.iterrows():
    location = [row["latitude"], row["longitude"]]

    color = "green" if row["free_beds"] > 0 else "red"
    icon = folium.Icon(color=color, icon="info-sign")
    folium.Marker(
        location,
        popup=f"{row['hut_name']}<br>Free beds: {row['free_beds']}",
        tooltip=row["hut_name"],
        icon=icon,
    ).add_to(m)

    bounds.append(location)

if bounds:
    m.fit_bounds(bounds)

folium_static(m, width=2000, height=700)

if list_only_available:
    filtered_data = filtered_data[data["free_beds"] > 0]

filtered_data
