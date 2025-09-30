from hut_availability import is_available, has_location, has_availability_date_predicate, has_status_predicate
from hut_map import render_map
from sidebar import render_sidebar
import streamlit as st
from query import fetch_data

st.set_page_config(page_title="Alpine huts", layout="wide")

st.html("""
      <style>
          footer {visibility: hidden;}
      </style>
  """)

data = fetch_data()

filter_config = render_sidebar()

filtered_data = filter(has_status_predicate(filter_config.statuses), data)
filtered_data = filter(has_availability_date_predicate(filter_config.availability_date), filtered_data) 

render_map(filter(has_location, filtered_data))

if filter_config.list_only_available:
    filtered_data = filter(is_available, filtered_data)

filtered_data
