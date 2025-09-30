.PHONY: all

requirements:
	@echo "Generate requirements.txt..."
	uv sync
	uv pip freeze > src/requirements.txt

all:
	@echo "Run Streamlit app..."
	uv run streamlit run app.py
