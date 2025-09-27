
.PHONY: infra glue-schemas

TERRAFORM_DIR=./infrastructure
TERRAFORM=terraform -chdir=$(TERRAFORM_DIR)

all: infra

glue-schemas: 
	@echo "Generate glue schema..."
	uvx pydantic-glue -f ./ingestion/src/models.py -c Availability -o generated/availability.json --schema-by-name
	uvx pydantic-glue -f ./ingestion/src/models.py -c HutInfo -o generated/hut_info.json --schema-by-name

infra: glue-schemas
	@echo "Update infrastructure..."
	$(TERRAFORM) init && $(TERRAFORM) apply
