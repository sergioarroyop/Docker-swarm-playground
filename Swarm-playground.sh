#!/bin/bash

playground-init(){
    if [ -z $1 ]
    then
        echo "Please insert a valid number of nodes"
        exit 1
    fi

    # Checking machines and turning them up them
    for num in {1..$1} do {
        docker-machine create bro$num
    }

    # Getting master IP
    ip_master=$(docker-machine ip bro1)

    echo $ip_master

    ## Starting swarm
    #$(eval docker-machine env bro1)"
    #
    #docker swarm init --advertise-addr $ip_master"
    #
    ## Getting master and worker token
    #master_token=$(docker-machine ssh bro1 "docker swarm join-token master")
    #worker_token=$(docker-machine ssh bro1 "docker swarm join-token worker")
}

playground-delete(){
    # Deleting playground
    for del in $(docker-machine ls | grep bro[0-9]) do {
        docker-machine rm $del
    }
}


