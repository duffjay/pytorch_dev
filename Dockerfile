# CUDA 11.2.2  cuDNN 8  Ubuntu 20.04
# - expecting nvidia-docker
#
# docker build -t object_detection_api:tf25 .
#
# assumes
# - you have awscli installed on the host such that you can copy credientials & config files
# /project 
#   /opencv
#   /opencv_contrib

FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

WORKDIR /app

# this will eliminate interactive dialog on installation steps
ARG DEBIAN_FRONTEND=noninteractive

LABEL author=jduff

ENV user jay
ENV group duff

# --- user: root
RUN apt-get update && apt-get install -y apt-utils 
RUN apt-get install -y sudo
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata


# add user
RUN useradd -m -d /home/${user} ${user} && \
    chown -R ${user} /home/${user} && \
    adduser ${user} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


# --- user: jay

USER ${user}
WORKDIR /home/${user}

# Install apt dependencies
RUN sudo apt-get update 
RUN sudo apt-get install -y \
    nano \
    git \
    gpg-agent \
    python3-cairocffi \
    protobuf-compiler \
    python3-pil \
    python3-lxml \
    python3-tk \
    wget
   

    
RUN sudo apt-get install -y software-properties-common
RUN sudo add-apt-repository ppa:deadsnakes/ppa
RUN sudo apt-get update
RUN sudo apt-get install -y apt-utils
RUN sudo apt-get install -y pigz
RUN sudo apt-get install -y awscli


# access python 3.9 with $ python3.9
RUN sudo apt-get install -y python3.7
RUN sudo apt-get install -y python3.9
RUN sudo apt-get install -y python3-pip
RUN sudo apt-get install -y python-dev
RUN sudo apt-get install -y python3-dev
RUN sudo apt-get install -y python3.7-dev
RUN sudo apt-get install -y python3.8-dev
RUN sudo apt-get install -y python3.9-dev
RUN sudo apt-get install -y python-setuptools
RUN sudo apt-get install -y python3-setuptools
RUN sudo apt-get install -y python3-testresources


# you should be at python 3.8 only
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 2
RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.9 3
RUN sudo update-alternatives  --set python /usr/bin/python3.8


RUN python -m pip install --upgrade pip

# -- UI forwarding via X11 -- 
# ** accompish this with movuting a volume for Xauthority
# https://www.geeksforgeeks.org/running-gui-applications-on-docker-in-linux/
# you need to put in the correct X11_COOKIE - per computer
# RUN sudo apt-get install -y xauth
# RUN touch ~/.Xauthority
# RUN xauth add 5950X/unix:  MIT-MAGIC-COOKIE-1  b60ae6f2a270b8d52b581154d0a06a00

EXPOSE 8887


# install Anaconda
RUN wget -O install_anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
RUN bash install_anaconda.sh -bu
RUN ./anaconda3/bin/conda config --set auto_activate_base false
RUN ./anaconda3/bin/conda create -y -n pytorch python=3.8


# Make RUN commands use the new environment:
# - https://pythonspeed.com/articles/activate-conda-dockerfile/
# - https://stackoverflow.com/questions/55123637/activate-conda-environment-in-docker

# Make RUN commands use the new environment:
RUN echo "export PATH=$PATH:/home/$user/anaconda3/bin" >> ~/.bashrc
RUN echo "conda init bash" >> ~/.bashrc
#RUN /home/$user/anaconda3/bin/conda init
RUN echo "source activate pytorch" >> ~/.bashrc
# SHELL ["/bin/bash", "--login", "-c"]

SHELL ["/bin/sh","-c"]
RUN echo $CONDA_DEFAULT_ENV
RUN echo $CONDA_PREFIX

RUN pip install torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html

# -- won't install from Docker Build --
# RUN ./anaconda3/bin/conda install pytorch torchvision torchaudio cudatoolkit=11.3 -c pytorch
RUN ./anaconda3/bin/conda install matplotlib
RUN ./anaconda3/bin/conda install -c conda-forge statsmodels
RUN ./anaconda3/bin/conda install scikit-learn

RUN pip install pytorch-forecasting

RUN ./anaconda3/bin/conda install jupyter

# RUN echo "*** finished - /project/docker/pytorch_dev"

## *** do the conda init in the build opencv script **
SHELL ["/bin/sh", "-c"]
