#!/bin/bash

sudo apt update
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
if [-n "$1" ]; then
    sudo usermod -a -G docker $1
fi

export AGENT_ALLOW_RUNASROOT=1
export RUNNER_ALLOW_RUNASROOT=1
if [-n "$2" ]; then
    ./githubActionsRunner.sh $2 $3
fi

if [-n "$4" ]; then
    ./azurePipelinesAgent.sh $4 $5 $6
fi