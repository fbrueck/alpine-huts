FROM python:3.13-slim

RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    python3-pip \
    zip \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

COPY dbt /dbt
WORKDIR /dbt
RUN dbt deps

CMD dbt build
