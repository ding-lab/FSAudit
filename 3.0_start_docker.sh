# Starting docker on compute1

# docker pull amancevice/pandas:latest
BIN="WUDocker/start_docker.sh"

# https://biocontainers.pro/tools/python3-biopython
# IMAGE="python:3.12-slim-bookworm"
IMAGE="mwyczalkowski/python3-util:20250123"

VOLS=""


bash $BIN -r -M compute1 -I $IMAGE $VOLS
