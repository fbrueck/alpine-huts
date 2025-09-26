# -------- Build Stage --------
FROM python:3.13-slim AS builder
    # Install build tools and Python
    RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    python3-pip \
    zip \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install dependencies
COPY requirements.txt .
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt -t /tmp/python

# -------- Runtime Stage --------
FROM public.ecr.aws/lambda/python:3.13

# Copy installed packages
COPY --from=builder /tmp/python /var/task/

COPY dbt /var/task/dbt/
COPY main.py /var/task/

CMD ["main.lambda_handler"]
