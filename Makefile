
.PHONY: transformation generate-glue-schemas update-infra deploy

generate-glue-schemas: 
	uvx pydantic-glue -f ./ingestion/src/models.py -c Availability -o generated/availability.json --schema-by-name
	uvx pydantic-glue -f ./ingestion/src/models.py -c HutInfo -o generated/hut_info.json --schema-by-name

update-infra: generate-glue-schemas
	terraform -chdir=infrastructure apply

deploy: update-infra
	make -C ingestion all

transformation:
	make -C transformation all
