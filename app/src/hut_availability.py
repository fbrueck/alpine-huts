from dataclasses import dataclass
import datetime
from typing import Callable


@dataclass
class HutAvailability:
    hut_id: int
    hut_name: str
    hut_status: str
    latitude: float | None
    longitude: float | None
    free_beds: int | None
    total_beds: int
    availability_date: datetime.datetime


def has_location(hut_availability: HutAvailability) -> bool:
    return hut_availability.latitude is not None and hut_availability.longitude is not None

def has_availability_date_predicate(availabiliy_date: datetime.date) -> Callable[[HutAvailability], bool]:
    def is_availability(hut_availability: HutAvailability) -> bool:
        return hut_availability.availability_date == availabiliy_date
    return is_availability

def has_status_predicate(statuses: list[str]) -> Callable[[HutAvailability], bool]:
    def has_status(hut_availability: HutAvailability) -> bool:
        return hut_availability.hut_status in statuses
    return has_status

def is_available(hut_availability: HutAvailability) -> bool:
    return hut_availability.free_beds is not None and hut_availability.free_beds > 0
