import datetime
from dataclasses import dataclass

import streamlit as st

from model import HutAvailability


@dataclass
class FilterConfig:
    statuses: list[str]
    availability_date: datetime.date
    list_only_available: bool

    def _common_filter(self, hut_availability: HutAvailability) -> bool:
        return (
            hut_availability.availability_date == self.availability_date
            and hut_availability.hut_status in self.statuses
        )

    def show_on_map(self, hut_availability: HutAvailability) -> bool:
        return self._common_filter(hut_availability) and hut_availability.has_location()

    def show_in_list(self, hut_availability: HutAvailability) -> bool:
        if self.list_only_available:
            return (
                self._common_filter(hut_availability)
                and hut_availability.is_available()
            )
        return self._common_filter(hut_availability)


def render_sidebar() -> FilterConfig:
    with st.sidebar:
        status = st.multiselect(
            "Hut status",
            ["SERVICED", "UNSERVICED", "CLOSED"],
            default=["SERVICED"],
        )
        availability_date = st.date_input("Date", value=datetime.datetime.now().date())
        list_only_available = st.checkbox("Show only available huts in list")
    return FilterConfig(status, availability_date, list_only_available)
