# FROM python:3.13.9-slim-trixie
FROM tensorflow/tensorflow:2.20.0

WORKDIR /opt/program

COPY ./requirements.txt .

RUN apt-get remove -y python3-blinker || true
RUN pip install -r requirements.txt

COPY ./app.py .
COPY ./inference.py .
COPY ./entrypoint.sh .
# COPY ./model.keras .

ENV FLASK_ENV=development
ENV PYTHONUNBUFFERED=1

ENV TF_CPP_MIN_LOG_LEVEL=3
ENV PYTHONWARNINGS=ignore

ENTRYPOINT [ "sh", "entrypoint.sh" ]