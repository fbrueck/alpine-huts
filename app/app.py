import streamlit as st
import awswrangler as wr


st.write("Alpine huts")


@st.cache_data()
def fetch_data():
    return wr.athena.read_sql_query(
        "SELECT * FROM hut_availability", database="alpine_huts", ctas_approach=False
    )


data = fetch_data()
data
status = st.multiselect("Hut status", data["hut_status"].unique(), default=["SERVICED"])
day_of_week_labels = st.multiselect("Day of week", data["day_of_week_label"].unique())
availability_date_from = st.date_input(
    "From date",
    min_value=data["availability_date"].min(),
    max_value=data["availability_date"].max(),
)
availability_date_to = st.date_input(
    "To date",
    min_value=data["availability_date"].min(),
    max_value=data["availability_date"].max(),
)
only_available = st.checkbox("Only available huts")

if status:
    filtered_data = data[data["hut_status"].isin(status)]
if day_of_week_labels:
    filtered_data = filtered_data[data["day_of_week_label"].isin(day_of_week_labels)]
if availability_date_from:
    filtered_data = filtered_data[data["availability_date"] >= availability_date_from]
if availability_date_to:
    filtered_data = filtered_data[data["availability_date"] <= availability_date_to]
if only_available:
    filtered_data = filtered_data[data["free_beds"] > 0]

filtered_data
