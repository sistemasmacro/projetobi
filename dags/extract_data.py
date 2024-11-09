from airflow import DAG
from airflow.providers.oracle.hooks.oracle import OracleHook
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator
from datetime import datetime
import pandas as pd

# Função para extrair do Oracle e carregar no PostgreSQL
def transfer_data_to_postgres(**kwargs):
    oracle_hook = OracleHook(oracle_conn_id="oracle_sapiens")
    postgres_hook = PostgresHook(postgres_conn_id="postgres_dw")

    # Extrai dados do Oracle
    query = "SELECT * FROM SAPIENS.E019RET"
    df = oracle_hook.get_pandas_df(sql=query)
    
    # Cria a tabela no PostgreSQL, se não existir
    postgres_conn = postgres_hook.get_conn()
    cursor = postgres_conn.cursor()
    table_name = "E019RET"
    
    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS {table_name} (
        {', '.join(f'{col} TEXT' for col in df.columns)}
    )
    """
    cursor.execute(create_table_query)
    postgres_conn.commit()

    # Carrega os dados para o PostgreSQL
    postgres_hook.insert_rows(
        table=table_name,
        rows=df.values.tolist(),
        target_fields=list(df.columns)
    )

    print("Dados transferidos com sucesso para o PostgreSQL.")

# Define o DAG
with DAG(
    dag_id="oracle_to_postgres_transfer",
    start_date=datetime(2023, 1, 1),
    schedule_interval="@daily",
    catchup=False,
) as dag:

    transfer_data_task = PythonOperator(
        task_id="transfer_data_to_postgres",
        python_callable=transfer_data_to_postgres,
    )

transfer_data_task
