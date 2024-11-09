from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.docker_operator import DockerOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 1,
}

with DAG(
    'start_meltano_container_from_docker_operator',
    default_args=default_args,
    description='DAG to start existing Meltano container using BashOperator',
    schedule_interval=None,
    start_date=datetime(2024, 11, 7),
    catchup=False,
) as dag:
    
    install_tap_and_loader = DockerOperator(
        task_id='start_meltano',
        image='meltano',
        container_name='macromaq-meltano',
        api_version='auto',
        auto_remove=True,
        command='meltano el tap-oracle target-postgres',
        docker_url="tcp://localhost:2375",
        network_mode='bridge',
        do_xcom_push=False,
        force_pull=False,
        dag=dag,
        # docker_url='tcp://0.0.0.0:2375',
        tty=True,
        xcom_all=False,
        mount_tmp_dir=False,
    )
