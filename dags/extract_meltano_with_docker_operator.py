import os
from datetime import timedelta
from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.docker_operator import DockerOperator
from airflow.utils.task_group import TaskGroup
from docker.types import Mount
from datetime import datetime
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig, ExecutionMode

meltano_path = os.getenv("MELTANO_PATH", "/home/macromaq/projetobi/meltano")
meltano_hack_path = os.getenv("MELTANO_HACK_PATH", "/home/macromaq/projetobi/hack")

# tables = ["e006pai", "e012fam", "e043pcm", "e044ccu", "e045pla", "e070fil", "e075pro", 
#           "e080ser", "e085cli", "e090rep", "e091plf", "e095for", "e120ped", "e120rat", 
#           "e120ipd", "e140ipv", "e140isv", "e140nfv", "e140rat", "e210mvp", "e440ipc",
#           "e440nfc", "e440rat", "e600mcc", "e640rat", "e640lct", "e640lot", "e644lnf",
#           "e440isc", "e130dme", "e130hfi", "e130csu", "e130ags", "e090rat", "e046hpd",
#         ]

tables = ["e044ccu", "e045pla","e070emp", "e070fil", "e640rat", "e640lct", "e640lot", "e046hpd" ]

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email': ['rphpacheco@gmail.com','tecnologia@macromaq.com.br'],
    'email_on_failure': True,
    'retries': 3,
    'retry_delay': timedelta(minutes=1)
}

def get_table_group_prefix(table_name):
    return table_name[1:3] + "0"

with DAG(
    'exec_meltano_container_from_docker_operator',
    default_args=default_args,
    description='DAG to start existing Meltano container using BashOperator',
    start_date=datetime(2023, 1, 1),
    schedule_interval='0 3 * * *',
    catchup=False,
    tags=["meltano", "extract"],
) as dag:
    start = DummyOperator(task_id="start")
    end = DummyOperator(task_id="end")

    prefix_groups = {}
    for table in tables:
        prefix = get_table_group_prefix(table)
        if prefix not in prefix_groups:
            prefix_groups[prefix] = []

        prefix_groups[prefix].append(table)

    with TaskGroup("extract_and_load_meltano") as extract_group:
        for prefix, tables_in_prefix in prefix_groups.items():
            with TaskGroup(f"el_group_table_{prefix}") as sub_group:
                prev_task = None
                for table in tables_in_prefix:
                    task = DockerOperator(
                        mem_limit='1g',
                        api_version='auto',
                        docker_url='unix://var/run/docker.sock',
                        network_mode='airflow-network',
                        auto_remove=True,
                        image='meltano:latest',
                        container_name=f'el-meltano-{table}',
                        task_id=f'{table}',
                        entrypoint="/bin/bash",
                        command=f"./hack/meltano.sh {table} && meltano el tap-{table} target-postgres --state-id={table}-to-postgres",
                        mounts=[
                            Mount("/opt/meltano", meltano_path, type="bind"), 
                            Mount("/opt/meltano/hack", meltano_hack_path, type="bind")
                        ],
                        force_pull=False
                    )
                    if prev_task:
                        prev_task >> task
                    prev_task = task

    dbt_workflow = DbtTaskGroup(
        group_id="dbt_workflow",
        project_config=ProjectConfig(
            dbt_project_path="/opt/airflow/dbt/macromaq",
            # env_vars={
            #     "ENV": os.getenv("ENV"),
            #     "PG_USER": os.getenv("PG_USER", "postgres"),
            #     "PG_PASS": os.getenv("PG_PASS"),
            # },
        ),
        profile_config=ProfileConfig(
            profile_name="macromaq",
            target_name="dev",
            profiles_yml_filepath="/opt/airflow/dbt/macromaq/profiles.yml",
        ),
        execution_config=ExecutionConfig(
            dbt_executable_path="/home/airflow/.local/bin/dbt",
        )
    )
    
    start >> extract_group >> dbt_workflow >> end
