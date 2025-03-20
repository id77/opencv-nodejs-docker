# OpenCV NodeJS Docker

使用GitHub Actions自动构建的Docker镜像，基于：
- Ubuntu
- NodeJS
- OpenCV
- @u4/opencv4nodejs
- onnxruntime-node
- @tensorflow/tfjs-node
- @tensorflow/tfjs
- @tensorflow/tfjs-core
- long
- protobufjs
- seedrandom
- PM2

## 支持的架构
- AMD64 (x86_64)
- ARM64 (aarch64)

## 使用方法

```bash
docker pull id77/opencv-nodejs:latest
docker run -it id77/opencv-nodejs:latest
```