
.PHONY: update-image

generate-schemas: 
	pydantic-glue -f ./ingestion/src/models.py -c Availability -o generated/availability.json
	pydantic-glue -f ./ingestion/src/models.py -c HutInfo -o generated/hut_info.json

update-infra: generate-schemas
	terraform -chdir=infrastructure apply

deploy:
	make -C ingestion all
