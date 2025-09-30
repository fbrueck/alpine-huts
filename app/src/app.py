import streamlit as st

from filter_ import render_sidebar
from map_ import render_map
from query import fetch_data

st.set_page_config(page_title="Alpine huts", layout="wide")

st.html("""
      <style>
          footer {visibility: hidden;}
      </style>
  """)

hut_availability_data = fetch_data()

filter_config = render_sidebar()

render_map(filter(filter_config.show_on_map, hut_availability_data))

st.dataframe(list(filter(filter_config.show_in_list, hut_availability_data)))
