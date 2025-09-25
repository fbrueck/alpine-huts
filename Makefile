
.PHONY: transformation generate-glue-schemas update-infra build-and-deploy all

TERRAFORM_DIR=infrastructure

all: update-infra build-and-deploy transformation

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
	@echo "Deploying ingestion and transformation..."
	make -C ingestion all

transformation:
	@echo "Run transformation..."
	make -C transformation all
