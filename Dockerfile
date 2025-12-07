FROM python:3.12-slim

WORKDIR /app

# Optional: basic OS updates (no extra packages needed right now)
RUN apt-get update && apt-get install -y \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire project into /app
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir fastapi uvicorn[standard] pydantic

# Our app will listen on port 8000 inside the container
EXPOSE 8000

# IMPORTANT: never use $PORT here; hardcode 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
