#!/bin/bash

# Running machines
for num in {1..3} do {
    docker-machine create mach$num
}

# Getting master IP
ip_master=$(docker-machine ip mach1)

# Starting swarm
docker-machine ssh mach1 "docker swarm init --advertise-addr $ip_master"

# Getting master and worker token

master_token=$(docker-machine ssh mach1 "docker swarm join-token master")
worker_token=$(docker-machine ssh mach1 "docker swarm join-token worker")

