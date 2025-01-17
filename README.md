
### Overall idea

Three different services collect statistics about the host machine, the docker containers, and kernel (host) metrics.
Prometheus, a time-series database collects (scraps) the metrics from the aforementioned services.
Grafana, a visualization web-service, will continuously present the data.

### Technical setup

A start script handles preliminary steps and calls docker-compose.
The start script builds local files and create docker images.
Docker-Compose starts all five services.
Docker-Compose doesn't work well while your have an active VPN connection!

#### Requirements for local testing:

- libelf-dev
- clang
- docker.io
- docker-compose
- make
- stress
- maybe more

#### General Information

- Read the readme at https://github.com/cloudflare/ebpf_exporter
- In a seperate, temporary folder, clone & compile the ebpf_exporter without using docker.
- Run the syscalls example as described in the readme of ebpf_exporter
- Execute `stress -d 6 --hdd-bytes 10GB` to see if the amout of write syscalls increase substatially.
- Hint: The examples need be compiled locally and later mounted into the ebpf-container

- Read the readme at https://github.com/google/cadvisor
- Read the readme at https://github.com/prometheus/node_exporter

#### Steps to run

- Start with `start.sh`, then `docker-compose.yml`
- Use `docker-compose run SERVICENAME` to test individual services

- Ensure that all services start
- Use `docker ps` to check
- `start.sh` should be a working one-click-be-happy script
- Open the urls listed at the end of `start.sh` for verification.

- Ensure that Prometheus is fetching metrics from all three sources (ebpf-exporter, cAdvisor, node-exporter)
  - Status -> Targets

- Create a toy-query in Prometheus to check if you have data, e.g. 'node_memory_Cached_bytes'
- Open  Grafana instance and login: admin (PW defined in `config.monitoring`)
- Add  prometheus instance as source (use the container name as url)
- Create an empty dashboard
- Create multiple panels in Grafana dashboard  these metrics:
  - `ebpf_exporter_syscalls_total`: Show the rate of all read and write syscalls (host).
  - `container_cpu_usage_seconds_total`: Show the CPU utilization of only the Prometheus container and only the Grafana container.
  - `ebpf_exporter_llc_misses_total`: Show the current rate of cache misses on the host.
  - `container_network_receive_bytes_total`, `container_network_transmit_bytes_total`: Show the network traffic of only the Prometheus container.
  - `node_memory_MemTotal_bytes`, `node_memory_MemAvailable_bytes`: Show the node's (host's) memory utilization.
  - `node_cpu_seconds_total`: Show the node's CPU utilization (needs a longer formula).
  - `ebpf_exporter_bio_latency_seconds_bucket`: show a historgram of your disk's write latency (hints: heatmap, https://grafana.com/blog/2020/06/23/how-to-visualize-prometheus-histograms-in-grafana/, ebpf-exporter readme)
  - `container_???`: Create a panel that shows the memory utilization of the Grafana container after you added the other panels.

- How much memory does Grafana actually use?
- Adapt the `docker-compose.yml` (at line ~101) file to limit the available memory of the grafana container to it's average usage plus ~20% extra.

- Stress  machine with, e.g., `stress`, `dd`, or youtube, to see if yur metrics change.
- Try `stress -d 6 --hdd-bytes 10GB`



