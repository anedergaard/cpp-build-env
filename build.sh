#!/bin/bash

print_help()
{
    echo "***************** Usage ******************"
    echo "-e build docker environment"
    echo "-s start shell in image"
    echo "-h this help text"
}

if [ -z "$*" ]; then
    print_help;
    exit 0;
fi

case $1 in
    -e)
	docker build -t cpp-build-env -f Dockerfile .
	;;
    -s)
      DOCKER_ARGS="--privileged \
      --rm=true \
      -it \
      -u user \
      -v $HOME:/home/user \
      -v empty:/home/user/.local/bin \
      -v $(pwd):/tmp/$(basename "$(pwd)") \
      -w /tmp/$(basename "$(pwd)")"

	    # Just run the command if we are inside a docker container
      if [ -f /.dockerenv ]; then
          $*
      else
          DOCKER_COMMAND="docker run $DOCKER_ARGS --network host cpp-build-env"
          $DOCKER_COMMAND
      fi
	;;
    -h)
	print_help
;;
esac
