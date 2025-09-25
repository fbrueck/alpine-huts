.PHONY: all

RUN_DBT_COMMAND := cd dbt && uvx --with dbt-athena-community --from dbt-core dbt

build:
	@echo "Build dbt models..."
	$(RUN_DBT_COMMAND) build

clean:
	@echo "Clean dbt artifacts..."
	$(RUN_DBT_COMMAND) clean

