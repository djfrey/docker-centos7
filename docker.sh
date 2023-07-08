#!/bin/bash

container="midwood"
hostname="local.midwood.com"

case $1 in
    run)
        docker run -p 80:80 -p 443:443 -v C:/webapp:/var/www/html --cap-add SYS_ADMIN --hostname $hostname --name $container centos
        exit 1
        ;;
    build)
        docker build -t centos .
        exit 1
        ;;
    build-full)
        docker build --no-cache --pull -t centos .
        exit 1
        ;;
    bash)
        docker exec -it $container sh -c "cd /var/www/html && /bin/bash"
        exit 1
        ;;
    stop)
        docker stop $container
        echo "Container stopped" >&2
        exit 1
        ;;
    restart)
        docker stop $container
        echo "Container stopped" >&2
        docker rm $container
        echo "Container removed" >&2
        docker run -p 80:80 -p 443:443 -v C:/webapp:/var/www/html --cap-add SYS_ADMIN --hostname $hostname --name $container centos
        exit 1
        ;;
    kill)
        docker stop $container 
        echo "Container stopped" >&2
        docker rm $container
        echo "Container removed" >&2
        exit 1
        ;;
    *)
        echo "Invalid option: $1, valid options are run, build, build-full, bash, stop, kill" >&2
        exit 1
        ;; 
esac