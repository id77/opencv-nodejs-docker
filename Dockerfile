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
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json ./

ENV OPENCV4NODEJS_DISABLE_AUTOBUILD=1
ENV NODE_PATH=/usr/lib/node_modules
#ls -al /usr/lib/node_modules/@u4/opencv4nodejs/build/Release/

# 安装不依赖AVX的包
RUN npm install -g @u4/opencv4nodejs onnxruntime-node long protobufjs seedrandom

# 安装TensorFlow完整套件（构建时全部安装，运行时根据CPU支持情况决定是否卸载）
RUN npm install -g @tensorflow/tfjs @tensorflow/tfjs-core @tensorflow/tfjs-node

# 创建检测CPU支持的脚本
RUN echo '#!/bin/bash \n\
if grep -q "avx" /proc/cpuinfo; then \n\
  echo "AVX support detected, keeping TensorFlow native bindings" \n\
  # 验证tfjs-node是否正常工作 \n\
  node -e "try { require(\"@tensorflow/tfjs-node\"); console.log(\"TensorFlow native bindings working\"); } catch(e) { console.log(\"TensorFlow native bindings failed:\", e.message); npm.uninstall(\"@tensorflow/tfjs-node\"); }" 2>/dev/null || echo "Verification completed" \n\
else \n\
  echo "No AVX support detected, removing TensorFlow native bindings" \n\
  npm uninstall -g @tensorflow/tfjs-node 2>/dev/null || echo "tfjs-node removed" \n\
  echo "Using TensorFlow.js in CPU-only mode" \n\
fi' > /check-cpu.sh && chmod +x /check-cpu.sh

# 在启动时运行检测脚本
RUN echo '#!/bin/bash \n\
/check-cpu.sh \n\
exec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

# Copy source files
COPY app.js ./
COPY app.json ./

# Expose the application port (if needed)
EXPOSE 6777

# Command to run the application
ENTRYPOINT ["/entrypoint.sh"]
CMD ["pm2-runtime", "start", "app.json"]