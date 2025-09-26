.PHONY: dbt

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
	@echo "RUnd dbt command..."
	$(RUN_DBT_COMMAND) $(filter-out $@,$(MAKECMDGOALS))
