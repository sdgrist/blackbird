FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir fastapi uvicorn[standard] pydantic

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
--port $PORT
