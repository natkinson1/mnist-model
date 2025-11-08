FROM python:3.13.9-slim-trixie

WORKDIR /app

COPY ./requirements.txt .

RUN pip install -r requirements.txt

COPY . .

ENTRYPOINT [ "sh", "entrypoint.sh" ]