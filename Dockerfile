# Base image: slim Python for small footprint
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies (if any additional libs are needed, add here)

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY src/ src/

# Expose no ports by default; the container acts as a client to
# the MT5 bridge running on the host.  If you add a web UI you may
# need to expose ports here.

# Command to run the trading script.  We use the -m flag so that
# Python executes the module inside the src package, ensuring
# relative imports work correctly.  The environment variables
# MT5_HOST and MT5_PORT can be overridden at runtime.
CMD ["python", "-m", "src.main"]