FROM nvcr.io/nvidia/pytorch:23.05-py3

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    git \
    libgtk2.0-dev \
    pkg-config

WORKDIR /workspace

RUN git clone https://github.com/Megvii-BaseDetection/YOLOX.git && cd YOLOX && pip install -v -e .

