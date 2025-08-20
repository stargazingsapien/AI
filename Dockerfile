# Use a Python version that Mediapipe supports
FROM python:3.10-slim

# System deps needed by OpenCV / MediaPipe
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
  && rm -rf /var/lib/apt/lists/*

# Prevent Python from buffering stdout/stderr
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install Python deps first (better layer caching)
COPY requirements.txt .
RUN python -m pip install --upgrade pip \
 && pip install -r requirements.txt

# Copy the rest of your app
COPY . .

# Expose Streamlit’s port (Render/Railway will still pass $PORT)
EXPOSE 8501

# Use $PORT if platform provides it, else default to 8501
CMD ["bash", "-lc", "streamlit run main.py --server.address 0.0.0.0 --server.port ${PORT:-8501}"]
