DOCKER_DIR=/var/log/docker
nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1
