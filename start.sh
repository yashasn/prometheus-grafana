#!/bin/bash

# Fail on fist error:
set -e

# Get ebpf_exporter:
# Use git to fetch https://github.com/cloudflare/ebpf_exporter.git into the folder exporters/ebpf_exporter.
# Skip the step if directory existsp

if [ ! -d "exporters/ebpf_exporter" ]; then
  git clone https://github.com/cloudflare/ebpf_exporter.git exporters/ebpf_exporter
else
  echo "Directory 'exporters/ebpf_exporter' already exists. Skipping git clone."
fi
 
# ebpf_exporter contains examples that need to be build locally (on the host) beforehand
# Use make to compile the code in the examples subfolder

cd exporters/ebpf_exporter
make -C examples clean build

# Build the container for ebpf_exporter (Dockerfile exists already)
# Use docker build

docker build -t ebpf_exporter .
cd ../..

# Storage folder for Prometheus
cd prometheus
if [ -d "storage" ]; then
    echo "re-using old storage dir"
else
    mkdir storage
fi
cd ..

#chmod -R 777 prometheus/
#chmod -R 777 grafana/

# Starting all services
CURRENT_UID=$(id -u):$(id -g) docker-compose up -d

# Check if you can open these:
echo "You may now open Ebpf_exporter at http://localhost:9440/metrics"
echo "You may now open Node-Exporter at http://localhost:9441/metrics"
echo "You may now open Cadvisor at http://localhost:9442/metrics"
echo "You may now open Prometheus at http://localhost:9090"
echo "You may now open Grafana at http://localhost:9091"