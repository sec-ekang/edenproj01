#!/bin/bash
# jenkins_docker_cleanup.sh
# Cleanup script for Jenkins & Docker resources on a CI server

echo "==== Starting Docker resource cleanup ===="

# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes
docker volume prune -f

# Remove unused networks
docker network prune -f

echo "==== Docker resource cleanup complete ===="

echo "==== Cleaning Jenkins workspace and build logs ===="

# Jenkins workspace (Adjust the path if your Jenkins home is different)
JENKINS_HOME="/var/lib/jenkins"

# Remove all workspace directories
rm -rf $JENKINS_HOME/workspace/*
rm -rf $JENKINS_HOME/jobs/*/workspace*

# Optionally, remove build artifacts older than 30 days
find $JENKINS_HOME/jobs/ -type d -name builds -exec find {} -type d -mtime +30 -exec rm -rf {} \;

# Optionally, remove logs older than 30 days
find $JENKINS_HOME/logs/ -type f -mtime +30 -exec rm -f {} \;

echo "==== Jenkins workspace and logs cleanup complete ===="

echo "==== Cleaning temporary files ===="

# Clean up /tmp and /var/tmp
rm -rf /tmp/*
rm -rf /var/tmp/*

echo "==== Temporary file cleanup complete ===="

echo "==== Disk usage summary ===="
df -h

echo "==== Cleanup finished ===="