.PHONY: build push clean

AWS_REGION      := eu-central-1
ACCOUNT_ID      := $(shell aws sts get-caller-identity --query Account --output text)
REPO_NAME       := dbt
IMAGE_TAG       := latest
ECR_URI         := $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(REPO_NAME):$(IMAGE_TAG)

all: build push

build:
	@echo "Generate requirements.txt..."
	uv sync
	uv pip freeze > requirements.txt

	@echo "Building the Docker image..."
	docker buildx build --provenance=false --platform linux/amd64 -t $(REPO_NAME):latest --load .
	@echo "Tagging the image with ECR URI..."
	docker tag $(REPO_NAME):$(IMAGE_TAG) $(ECR_URI)

push:
	@echo "Pushing the image to ECR..."
	docker push $(ECR_URI)

clean:
	@echo "Cleaning up local images..."
	docker rmi $(REPO_NAME):$(IMAGE_TAG) $(ECR_URI) || true
	@echo "Cleaning up requirements..."
	rm -rf requirements.txt
