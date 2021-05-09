#!/bin/bash
# A bash script to uninstall CLAP
CLAP_PATH="/opt/clap"
# Ask sudo rights
sudo -A ls&
# Stop and remove containers
sudo docker stop awx_task awx_web awx_redis awx_postgres
sudo docker rm awx_task awx_web awx_redis awx_postgres

# Remove the CLAP main path 
sudo rm -rf $CLAP_PATH