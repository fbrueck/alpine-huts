import boto3

from models import Availability, HutInfo

s3 = boto3.client("s3")

BUCKET_NAME = "fab-alpine-huts-data"
PATH_NAME = "raw-alpine-huts"


def upload_hut_info_to_s3(hut_info: HutInfo):
    try:
        key = f"{PATH_NAME}/hut-info/{hut_info.hut_id}.json"
        s3.put_object(Bucket=BUCKET_NAME, Key=key, Body=hut_info.model_dump_json())
    except Exception as e:
        print(f"Error uploading file: {e}")


def upload_availability_to_s3(availability: Availability):
    try:
        key = f"{PATH_NAME}/availability/{availability.hut_id}.json"
        s3.put_object(Bucket=BUCKET_NAME, Key=key, Body=availability.model_dump_json())
    except Exception as e:
        print(f"Error uploading file: {e}")
