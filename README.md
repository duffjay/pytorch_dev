# pytorch_dev
Docker build for pytorch dev

## Dockerfile

### CUDA docker
requires nvidia-docker  
start w/ nvidia/cuda    Go to Dockerhub, search nvidia/cuda look for all tags. You want the developer (to get the CUDA toolkit)
20211124  PyTorch says 11.3  (use 11.3.1)  

## Build

`cd /project/docker/pytorch_dev`
`docker build -t pytorch_dev --build-arg USER_PASSWORD=q2w3E$R% .`

## Run

`docker run -it --runtime=nvidia \
--user=jay \
--gpus all \
--volume=/project:/project \
--volume=/hsdata:/hsdata \
--volume=/home/$USER/.aws:/home/$USER/.aws \
--network host \
--env=DISPLAY --volume=$HOME/.Xauthority:/root/.Xauthority \
pytorch_dev \
bash`

