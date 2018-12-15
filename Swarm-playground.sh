#!/bin/bash

<<<<<<< HEAD
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

=======
red () {
	echo -e "\e[31m $1 \e[0m"
}

yellow () {
	echo -e "\e[33m $1 \e[0m"
}

green () {
	echo -e "\e[32m $1 \e[0m"
}

errors () {
	red "$1"
	exit 1
}

ifdeb () {
	green "$1" || errors "$2"
}

playground-delete(){
    # Deleting playground
    for del in $(docker-machine ls | grep -o bro'[0-9$]'); do
        yellow "- Deleting machine $del"
        docker-machine rm $del &> ./errors.log && ifdeb "Node deleted successfuly" "There was a problem deleting the node, check errors.log" 
    done
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
    if [ ! -z "$CHECK" ]
    then
        red "The playground already exist, do you want to delete it? (y/n)"
        read option
        if [ $option == "y" ] 
        then
            playground-delete
        else
            errors "- Bye bye!"
        fi
    else

    # Checking machines and turning them up them
    for ((num=1; num<=$1; num++)); do {
        yellow "- Creating machine bro$num"
        docker-machine create --driver virtualbox bro$num &> ./errors.log &&
	green "+ Nodes created successfuly" || errors "- There was a problem creating the nodes, check errors.log"
    } done

    # Getting master IP
    ip_master=$(docker-machine ip bro1)

    # Starting swarm
    eval $(docker-machine env bro1) &> errors.log
    
    docker swarm init --advertise-addr $ip_master &> errors.log
    
    # Getting master and worker token
    master_token=$(docker-machine ssh bro1 "docker swarm join-token master -q")
    worker_token=$(docker-machine ssh bro2 "docker swarm join-token worker -q")

    # Joining workers to swarm
    for ((num=2; num<=$1; num++)); do
        yellow "- Joining bro$num as a worker"
        eval $(docker-machine env bro$num)
        docker swarm join --token worker_token $ip_master:2377 &> errors.log && \
	green "+ Node bro$num joined successfuly" || errors "- Node bro$num not joined :c"
    done

    fi
}

init(){
    yellow "- What do you want to do?"
    yellow "1. Create playground"
    yellow "2. Delete playground"
    yellow "3. Exit"
    read option

    clear

    if [ $option == 1 ]
    then
        yellow "- How many nodes do you want?"
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
        yellow "- Bye Bye"
        exit 0
    ;;
    *)
        yellow "- Please, select an option"
        init        
    ;;
esac
>>>>>>> develop
