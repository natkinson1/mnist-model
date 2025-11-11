FROM python:3.13.9-slim-trixie

WORKDIR /opt/program

COPY ./requirements.txt .

RUN pip install -r requirements.txt

COPY . .

ENV FLASK_ENV=development
ENV PYTHONUNBUFFERED=1

ENTRYPOINT [ "python", "serve.py" ]