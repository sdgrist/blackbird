FROM python:3.12-slim

# Create app directory
WORKDIR /app

# Install system dependencies (if any are needed later)
# For now, just basic userland is fine
RUN apt-get update && apt-get install -y \
    && rm -rf /var/lib/apt/lists/*

# Copy project files into the image
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir fastapi uvicorn[standard] pydantic

# Expose the port our app will listen on
EXPOSE 8000

# Default command: run the FastAPI app with Uvicorn on port 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
