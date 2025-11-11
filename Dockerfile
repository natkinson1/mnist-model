FROM python:3.13.9-slim-trixie

WORKDIR /opt/program

COPY ./requirements.txt .

RUN pip install -r requirements.txt

COPY . .

ENTRYPOINT [ "python", "serve.py" ]