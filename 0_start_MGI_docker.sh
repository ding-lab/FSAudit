# Run this only on MGI to start new docker instance

source docker/docker_image.sh

bash WUDocker/start_docker.sh -M MGI -m 16 -I $IMAGE

