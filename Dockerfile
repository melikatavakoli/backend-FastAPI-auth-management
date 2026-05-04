FROM docker.arvancloud.ir/python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD sh -c "python -c 'from database import engine, Base; import models; Base.metadata.create_all(bind=engine)' && uvicorn main:app --host 0.0.0.0 --port 8000"
