FROM ubuntu:18.04

RUN apt update && apt install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y python3.8 python3-pip python3.8

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libopenblas-dev \
    libblas-dev \
    libmetis-dev

RUN python3.8 -m pip install --upgrade pip
RUN python3.8 -m pip install torch==1.9.1+cpu -f https://download.pytorch.org/whl/torch_stable.html
RUN python3.8 -m pip install torchvision==0.10.1+cpu -f https://download.pytorch.org/whl/torch_stable.html
RUN python3.8 -m pip install torchaudio==0.9.1 -f https://download.pytorch.org/whl/torch_stable.html


# install PyTorch Geometric and other Python packages
RUN python3.8 -m pip install numpy pandas

RUN python3.8 -m pip install torch-geometric==1.4.3 \
  torch-sparse==0.6.12 \
  torch-scatter==2.0.9 \
  torch-cluster==1.5.9 \
  torch-spline-conv==1.2.1 \
  -f https://pytorch-geometric.com/whl/torch-1.9.1+cpu.html

# Get ThreaTrace repository into ROOT directory
RUN mkdir /ROOT
WORKDIR /ROOT/
COPY threaTrace .

# Download and extract DARPA TC dataset
RUN mkdir -p /ROOT/threaTrace/graphchi-cpp-master/graph_data/darpatc/
WORKDIR /ROOT/threaTrace/graphchi-cpp-master/graph_data/darpatc/

COPY cadets .

# Run the parsing script
WORKDIR /ROOT/threaTrace/scripts/
RUN python3.8 parse_darpatc.py

# set working directory
WORKDIR /ROOT/threaTrace

# run evaluation on DARPA TC dataset
CMD ["bash", "-c", "python3.8 scripts/setup.py && python3.8 scripts/train_darpatc.py --scene cadets"]