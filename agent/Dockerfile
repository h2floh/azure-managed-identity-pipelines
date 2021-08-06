# Using Ubuntu as base
FROM ubuntu:20.04

# Install network tool prerequisits
RUN apt-get update
RUN apt-get install curl apt-transport-https --yes

# Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash