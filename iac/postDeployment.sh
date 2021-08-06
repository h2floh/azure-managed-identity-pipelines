#!/bin/bash

sudo apt update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker $1

./githubActionsRunner.sh $2 $3
./azurePipelinesAgent.sh $4 $5 $6