import datetime
from dataclasses import dataclass


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

    def has_location(self) -> bool:
        return self.latitude is not None and self.longitude is not None

    def is_available(self) -> bool:
        return self.free_beds is not None and self.free_beds > 0
