from dbt.cli.main import dbtRunner
import os

def lambda_handler(event, context):
    project_dir = os.path.abspath("./dbt")

    os.environ["DBT_PROFILES_DIR"] = project_dir

    # Run dbt build
    dbt = dbtRunner()
    result = dbt.invoke(["build", "--project-dir", project_dir, "--target-path", "/tmp/target/", "--log-path", "/tmp/logs/", "--threads", 1])

    if not result.success:
        return {
            "statusCode": 500,
            "body": "dbt build failed"
        }

    models_built = [r.node.name for r in result.result]
    return {
        "statusCode": 200,
        "body": f"dbt build succeeded. Models: {models_built}"
    }
