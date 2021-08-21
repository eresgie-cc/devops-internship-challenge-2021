ARG IMAGE=python:3.9.6-alpine3.14

FROM $IMAGE AS base

FROM base as builder

WORKDIR /build

COPY requirements.txt /requirements.txt

RUN pip install --prefix=/build -r /requirements.txt

FROM base
WORKDIR /app

COPY --from=builder /build /usr/local

ADD flask-app.py ./

EXPOSE 5001
CMD ["gunicorn", "-b", "0.0.0.0:5001", "flask-app:app"]
