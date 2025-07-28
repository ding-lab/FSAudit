# Starting docker on compute1

# docker pull amancevice/pandas:latest
BIN="WUDocker/start_docker.sh"

# https://biocontainers.pro/tools/python3-biopython
# IMAGE="python:3.12-slim-bookworm"
IMAGE="mwyczalkowski/python3-util:20250130"

# ask for 16Gb of memory
ARGS="-m 16"

VOLS="/home/m.wyczalkowski /storage1/fs1/m.wyczalkowski/Active/ProjectStorage"


bash $BIN $ARGS -r -M compute1 -I $IMAGE $VOLS
