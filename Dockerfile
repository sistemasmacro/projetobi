FROM apache/airflow:2.10.3
WORKDIR "/opt/airflow/"

COPY airflow.cfg .
COPY requirements.txt .

RUN pip install --upgrade pip

RUN pip install apache-airflow==2.10.3 -r requirements.txt

USER airflow