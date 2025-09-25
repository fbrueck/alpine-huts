
.PHONY: data generate-glue-schemas update-infra build-and-deploy all

TERRAFORM_DIR=infrastructure

all: update-infra build-and-deploy data


generate-glue-schemas: 
	@echo "Generate glue schema..."
	uvx pydantic-glue -f ./ingestion/src/models.py -c Availability -o generated/availability.json --schema-by-name
	uvx pydantic-glue -f ./ingestion/src/models.py -c HutInfo -o generated/hut_info.json --schema-by-name

init:
	cd $(TERRAFORM_DIR) && terraform init

validate:
	cd $(TERRAFORM_DIR) && terraform validate

update-infra: generate-glue-schemas init validate
	@echo "Update infrastructure..."
	terraform -chdir=$(TERRAFORM_DIR) apply

build-and-deploy:
	@echo "Deploying ingestion and data..."
	make -C ingestion all

build-data-models:
	@echo "Build data models..."
	make -C data build
