
.PHONY: data generate-glue-schemas update-infra build-and-deploy all

TERRAFORM=terraform -chdir=$(TERRAFORM_DIR)

all: infra ingestion data-models


generate-glue-schemas: 
	@echo "Generate glue schema..."
	uvx pydantic-glue -f ./ingestion/src/models.py -c Availability -o generated/availability.json --schema-by-name
	uvx pydantic-glue -f ./ingestion/src/models.py -c HutInfo -o generated/hut_info.json --schema-by-name


infra: generate-glue-schemas
	@echo "Update infrastructure..."
	$(TERRAFORM) init && $(TERRAFORM) apply

ingestion:
	@echo "Deploying ingestion and data..."
	make -C ingestion all

data-models:
	@echo "Build data models..."
	make -C data build
