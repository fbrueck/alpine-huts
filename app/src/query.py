import duckdb
import streamlit as st

from model import HutAvailability

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

hut_availability_query = """
SELECT 
    hut_id, 
    hut_name, 
    hut_status, 
    latitude, 
    longitude, 
    free_beds, 
    total_sleeping_places, 
    availability_date 
FROM glue_catalog.alpine_huts.hut_availability
"""


@st.cache_data()
def fetch_data() -> list[HutAvailability]:
    duckdb.sql(setup_aws_credentials)
    duckdb.sql(attach_glue_catalog)
    result = duckdb.sql(hut_availability_query)
    return [HutAvailability(*row) for row in result.fetchall()]
