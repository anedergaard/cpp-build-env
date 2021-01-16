#!/bin/bash

print_help()
{
    echo "***************** Usage ******************"
}

if [ -z "$*" ]; then
    print_help;
    exit 0;
fi

case $1 in
    -e)
	docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t clion/remote-ubuntu:20.04 -f Dockerfile .
	;;
    -r)
	docker run -d --cap-add sys_ptrace -p127.0.0.1:2222:22 clion/remote-ubuntu:20.04
	;;
    -h)
	print_help
;;
esac


