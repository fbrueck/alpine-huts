import logging
import random
import time

from aws import upload_availability_to_s3, upload_hut_info_to_s3
from hut_reservation import fetch_hut_availability, fetch_hut_info

logger = logging.getLogger(__name__)

MIN_HUT_ID = 1
MAX_HUT_ID = 700


def lambda_handler(event, context):
    failed_huts = []

    for hut_id in range(MIN_HUT_ID, MAX_HUT_ID + 1):
        time.sleep(random.uniform(0.1, 0.5))

        try:
            hut_info = fetch_hut_info(hut_id)
            if hut_info:
                upload_hut_info_to_s3(hut_info)
                availability = fetch_hut_availability(hut_id)
                if availability:
                    upload_availability_to_s3(availability)

        except Exception as e:
            logger.error(f"Error fetching hut {hut_id}: {e}")
            import traceback

            traceback.print_exc()

    if failed_huts:
        failed_summary = "\n".join(
            [f" - Hut {hut_id}: {error}" for hut_id, error in failed_huts]
        )
        raise RuntimeError(f"{len(failed_huts)} hut(s) failed:\n{failed_summary}")


if __name__ == "__main__":
    lambda_handler(None, None)
