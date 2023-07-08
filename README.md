# devops-docker-centos

The contents of this repository will allow local development using an NC State configured Linux environment.

# Installed packages

 - CentOS 8 stream
 - Apache
 - Python 3.10
 - Oracle Instant Client v. 21
 - Salesforce CLI (latest version)
 - Salesforce ODBC driver (DevArt)
 - LibreOffice
 - PHP 8.1
 - NC State configured Shibboleth

# Prerequites

 - Enable virtualization in the BIOS 
 - WSDL 2 (https://learn.microsoft.com/en-us/windows/wsl/install)
 - Docker desktop (https://www.docker.com/products/docker-desktop/)

# Setup
After cloning the repository, the docker.sh file contains some useful commands

 - docker.sh build: builds the container using the Docker cache
 - docker.sh build-full: re-builds the container from scratch, downloads all necessary files
 - docker.sh run: run the container using suggested volume mappings and settings
 - docker.sh bash: open a bash terminal in the container
 - docker.sh stop: stops the running container
 - docker.sh kill: stops and removes the container
