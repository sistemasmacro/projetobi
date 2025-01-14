from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.operators.python_operator import PythonOperator

def test_env_vars():
    import os
    print("ENV:", os.getenv("ENV"))
    print("PG_USER:", os.getenv("PG_USER"))
    print("PG_PASS:", os.getenv("PG_PASS"))

with DAG(
    dag_id="test_env_vars",
    schedule_interval=None,
    start_date=days_ago(1),
) as dag:
    task = PythonOperator(
        task_id="print_env_vars",
        python_callable=test_env_vars,
    )
