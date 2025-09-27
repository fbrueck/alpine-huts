import datetime
import requests

from models import Availability, AvailabilityData, HutInfo, HutInfoData


BASE_URL = "https://www.hut-reservation.org/api/v1/reservation"

headers = {"User-agent": "Mozilla/5.0"}


def fetch_hut_info(hut_id: int) -> HutInfo | None:
    url = f"{BASE_URL}/hutInfo/{hut_id}"
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        data_json = response.json()
        hut_info_data = HutInfoData.model_validate_json(data_json)
        return HutInfo(
            hut_id=hut_id,
            fetched_at=datetime.datetime.now(),
            hut_info_data=hut_info_data,
        )
    else:
        print(f"Failed to fetch info data for hut {hut_id}")


def fetch_hut_availability(hut_id: int) -> Availability | None:
    url = f"{BASE_URL}/getHutAvailability?hutId={hut_id}"
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        data_json = response.json()
        availability_data_list = [AvailabilityData.model_validate_json(item) for item in data_json]
        return Availability(
            hut_id=hut_id,
            fetched_at=datetime.datetime.now(),
            availability_data_list=availability_data_list,
        )
    else:
        print(f"Failed to fetch availability data for hut {hut_id}")
