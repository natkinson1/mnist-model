FROM python:3.13.9-slim-trixie

WORKDIR /opt/program

COPY ./requirements.txt .

RUN pip install -r requirements.txt

COPY . .

ENV FLASK_ENV=development
ENV PYTHONUNBUFFERED=1

ENV TF_CPP_MIN_LOG_LEVEL=3

ENTRYPOINT [ "sh", "entrypoint.sh" ]