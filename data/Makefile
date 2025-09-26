.PHONY: dbt

AWS_REGION      := eu-central-1
ACCOUNT_ID      := $(shell aws sts get-caller-identity --query Account --output text)
REPO_NAME       := dbt-lambda
FUNCTION_NAME   := dbt_lambda
IMAGE_TAG       := latest
ECR_URI         := $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(REPO_NAME):$(IMAGE_TAG)

RUN_DBT_COMMAND := cd dbt && uvx --with dbt-athena-community --from dbt-core dbt

build: deps
	@echo "Build dbt models..."
	$(RUN_DBT_COMMAND) build


deps:
	@echo "Install dbt dependencies..."
	$(RUN_DBT_COMMAND) deps


clean:
	@echo "Clean dbt artifacts..."
	$(RUN_DBT_COMMAND) clean

dbt:
	@echo "Run dbt command..."
	$(RUN_DBT_COMMAND) $(filter-out $@,$(MAKECMDGOALS))


requirements:
	@echo "Generate requirements.txt..."
	uv pip freeze > requirements.txt

build-docker: requirements
	@echo "Building the Docker image..."
	docker buildx build --provenance=false --platform linux/amd64 -t $(REPO_NAME):latest --load .

tag: build-docker
	@echo "Tagging the image with ECR URI..."
	docker tag $(REPO_NAME):$(IMAGE_TAG) $(ECR_URI)

push: tag
	@echo "Pushing the image to ECR..."
	docker push $(ECR_URI)

update-lambda: push
	@echo "Updating the Lambda function..."
	aws lambda update-function-code --function-name ${FUNCTION_NAME} --image-uri $(ECR_URI)

clean:
	@echo "Cleaning up local images..."
	docker rmi $(REPO_NAME):$(IMAGE_TAG) $(ECR_URI) || true
	@echo "Cleaning up requirements..."
	rm -rf requirements.txt
