from datetime import datetime
from pydantic import BaseModel, Field
from typing import List, Optional


def to_camel(string: str) -> str:
    components = string.split("_")
    return components[0] + "".join(x.title() for x in components[1:])


class AlpineHutBaseModel(BaseModel):
    class Config:
        alias_generator = to_camel
        populate_by_name = True


class Picture(AlpineHutBaseModel):
    file_type: str
    blob_path: str
    file_name: str
    file_data: Optional[str] = None


class HutBedCategoryLanguageData(AlpineHutBaseModel):
    language: str
    label: str
    short_label: str
    description: str | None


class Room(AlpineHutBaseModel):
    id: int
    index: int
    label: str
    sleeping_places: int
    is_linked: bool


class HutBedCategory(AlpineHutBaseModel):
    index: int
    category_id: int = Field(alias="categoryID")
    rooms: List[Room]
    is_visible: bool
    total_sleeping_places: int
    reservation_mode: str
    hut_bed_category_language_data: List[HutBedCategoryLanguageData]
    is_linked_to_reservation: bool
    tenant_bed_category_id: int # debug


class GeneralDescription(AlpineHutBaseModel):
    description: str
    language: str


class HutInfoData(AlpineHutBaseModel):
    hut_website: str | None
    hut_id: int
    tenant_code: str
    hut_unlocked: bool
    max_number_of_nights: int
    hut_name: str
    hut_warden: str | None
    phone: str | None
    coordinates: str | None
    altitude: str | None
    total_beds_info: str | None
    tenant_country: str
    picture: Picture | None
    hut_languages: List[str]
    hut_bed_categories: List[HutBedCategory]
    provider_name: str
    hut_general_descriptions: List[GeneralDescription]
    waiting_list_enabled: bool


class HutInfo(BaseModel):
    hut_id: int
    fetched_at: datetime
    hut_info_data: HutInfoData


class AvailabilityData(AlpineHutBaseModel):
    free_beds: int | None
    hut_status: str
    date: str
    date_formatted: str
    total_sleeping_places: int
    percentage: str


class Availability(BaseModel):
    hut_id: int
    fetched_at: datetime
    availability_data_list: list[AvailabilityData]
