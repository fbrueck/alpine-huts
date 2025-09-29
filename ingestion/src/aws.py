import boto3

from models import Availability, HutInfo
import logging

logger = logging.getLogger(__name__)

s3 = boto3.client("s3")

BUCKET_NAME = "fab-alpine-huts-data"
PATH_NAME = "raw-alpine-huts"


def _upload_file_to_s3(file_path: str, s3_key: str, data: str):
    try:
        s3.put_object(
            Bucket=BUCKET_NAME, Key=f"{PATH_NAME}/{s3_key}/{file_path}", Body=data
        )
    except Exception as e:
        logger.error(f"Error uploading file: {e}")
        raise e


def upload_hut_info_to_s3(hut_info: HutInfo):
    _upload_file_to_s3(
        f"{hut_info.hut_id}.json", "hut-info", hut_info.model_dump_json()
    )


def upload_availability_to_s3(availability: Availability):
    _upload_file_to_s3(
        f"{availability.hut_id}.json", "availability", availability.model_dump_json()
    )
