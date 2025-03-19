FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    libopencv-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Install PM2
RUN npm install -g pm2

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy source files
COPY src/ ./src/

# Expose the application port (if needed)
EXPOSE 6777

# Command to run the application
CMD ["pm2-runtime", "start", "app.json"]