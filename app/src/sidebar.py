from dataclasses import dataclass
import datetime
import streamlit as st

@dataclass
class FilterConfig:
    statuses: list[str]
    availability_date: datetime.date
    list_only_available: bool

def render_sidebar() -> FilterConfig:
    with st.sidebar:
        status = st.multiselect(
            "Hut status", ["SERVICED", "UNSERVICED", "CLOSED"], default=["SERVICED"],
        )
        availability_date = st.date_input(
            "Date",
                value=datetime.datetime.now().date()    )
        list_only_available = st.checkbox("Show only available huts in list")
    return FilterConfig(status, availability_date, list_only_available)
