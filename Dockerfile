FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    cmake \
    git \
    libopencv-dev \
    python3 \
    python3-pip \
    python3-dev \
    tzdata \
    pkg-config \
    libgtk-3-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
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

ENV OPENCV4NODEJS_DISABLE_AUTOBUILD=1
ENV NODE_PATH=/usr/local/lib/node_modules

RUN npm install -g @u4/opencv4nodejs


# Copy source files
COPY src/ ./src/

# Expose the application port (if needed)
EXPOSE 6777

# Command to run the application
CMD ["pm2-runtime", "start", "app.json"]