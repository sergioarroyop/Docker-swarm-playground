#!/bin/bash

playground-delete(){
    # Deleting playground
    for del in $(docker-machine ls | grep -o bro'[0-9$]'); do {
        echo "Deleting machine $del"
        docker-machine rm $del
    } done
}

playground-init() {

    ints='^[0-9]+$'

    #if ! [[ $1 =~ $re ]]
    #then
    #    echo "Please insert a valid number of nodes"
    #    exit 1
    #fi

    # Checking if the nodes are created
    CHECK=$(docker-machine ls | grep bro1)
    if [ -z $CHECK ]
    then
        echo "The playground already exist, do you want to delete it? (y/n)"
        read option
        if [ $option =~ "y" ] 
        then
            playground-delete()
        else
            echo "Bye bye!"
            exit 0
        fi
    else

    # Checking machines and turning them up them
    for ((num=1; num<=$1; num++)); do {
        echo "Creating machine bro$num"
        docker-machine create --driver virtualbox bro$num
    } done

    # Getting master IP
    ip_master=$(docker-machine ip bro1)

    # Starting swarm
    eval $(docker-machine env bro1)
    
    docker swarm init --advertise-addr $ip_master
    
    # Getting master and worker token
    master_token=$(docker-machine ssh bro1 "docker swarm join-token master -q")
    worker_token=$(docker-machine ssh bro2 "docker swarm join-token worker -q")

    # Joining workers to swarm
    for ((num=2; num<=$1; num++)); do {
        echo "Joining bro$num as a worker"
        eval $(docker-machine env bro$num)
        docker swarm join --token worker_token $ip_master:2377
    } done
}

init(){
    echo "What do you want to do?"
    echo "1. Create playground"
    echo "2. Delete playground"
    echo "3. Exit"
    read option

    clear

    if [ $option == 1 ]
    then
        echo "How many nodes do you want?"
        read num
    fi
}

init

case $option in
    1)
        playground-init $num
    ;;
    2)
        playground-delete
    ;;
    3)
        echo "Bye Bye"
        exit 0
    ;;
    *)
        echo "Please, select an option"
        init        
    ;;
esac