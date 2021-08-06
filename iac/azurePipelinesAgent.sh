#!/bin/bash

# Create a folder
mkdir myagent && cd myagent
# Download the latest runner package
wget https://vstsagentpackage.azureedge.net/agent/2.186.1/vsts-agent-linux-x64-2.186.1.tar.gz
# Extract the installer
tar zxvf vsts-agent-linux-x64-2.186.1.tar.gz
# Create the agent and configure it
./config.sh --unattended  --url $1 --auth pat --token $2 --pool $3
# Install and run the service
./svc.sh install
./svc.sh start