#!/bin/bash

print_help()
{
    echo "***************** Usage ******************"
    echo "-e build docker environment"
    echo "-d run images as a daemon"
    echo "--load shows the htop for the running container"
    echo "-h this help text"
}

if [ -z "$*" ]; then
    print_help;
    exit 0;
fi

case $1 in
    -e)
	docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t distcc/ccache -f Dockerfile .
	;;
    -d)
	docker run -p 3632:3632 -p 3633:3633 -d --name localdistcc --network host distcc/ccache
	#export LOCAL_DISTCC_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' localdistcc)
	#export LOCAL_DISTCC_NPROC=$(docker exec -it localdistcc nproc)
	#export DISTCC_HOSTS="$LOCAL_DISTCC_IP/$LOCAL_DISTCC_NPROC localhost"
	;;
    #--update)
	#export LOCAL_DISTCC_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' localdistcc)
	#export LOCAL_DISTCC_NPROC=$(docker exec -it localdistcc nproc)
	#export DISTCC_HOSTS="$LOCAL_DISTCC_IP/$LOCAL_DISTCC_NPROC localhost"
	#echo $LOCAL_DISTCC_IP
	#;;
    #-r)
	#docker run -d --cap-add sys_ptrace -p127.0.0.1:2222:22 clion/remote-ubuntu:20.04
	#;;
    --load)
	docker exec -it localdistcc htop
	;;
    -h)
	print_help
;;
esac


