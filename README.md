# Custom scripts with arguments in Docker
> This repo shows how to build and run a Docker container, for example, downloading favicons.

## Usage
Download `favicon-image.tar` file to a host with Docker.  
Fuse the image to your Docker:
```bash
docker load -i /Downloads/favicon-image.tar
```
Follow next section commands to run a container.

## List of commands to build and run the image
- build an image;
- create a volume;
- run a container with a mounted volume and a url;  
- remove a container;
- remove a volume; 
- make a tar file to share the image;
- remove an image;

> Don't miss a dot in the end of the `docker build` command !
```bash
# Building an image; don't miss a dot at the end
docker build -t favicon-image .

# Run a container; files are copied to the VPS at /var/lib/docker/volumes/favicons/_data
# A container downloads a favicon from https://skillfactory.ru if no url provided.
# Adding a url at the end of the command changes behavior.
# It's worth changing --name in accordance with the url provided.
docker run -it -d --name favicon-bike24 --mount type=volume,source=favicons,target=/favicons  favicon-image:latest https://bike24.de

# Remove all stopped containers
docker rm $(docker ps -aq)

# Remove all volumes; -q means list volumes names only
docker volume rm $(docker volume ls -q) 

# make a tar file to share the image; 
# execute a command on the host to run Ansible copy-image role (uncomment it first in the main.yml)
# ansible-playbook -i terraform-do/inventory.yml main.yml --tags=copy-image
docker save -o /tmp/favicon-image.tar favicon-image

# Remove an image
docker image rm favicon-bike24
```
## Dockerfile
```bash
FROM ubuntu # choose a parent image here
RUN  apt-get update \
    && apt-get install -y wget \
    && rm -rf /var/lib/apt/lists/* # compress in one command to minimize the number of layers
COPY ./favicon.sh /
RUN chmod +x /favicon.sh
ENTRYPOINT ["/favicon.sh"] # You can't overwrite it, so it's worth using it to run the script
CMD [ "https://skillfactory.ru" ] # You can overwrite it when running a container; ideal for script arguments 
```

## Installation
You should have Terraform and Ansible on your host to roll out a VPS.
You also should have Digital Ocean account and your credentials listed in main.auto.tfvars.sample.
```bash
terraform init
terraform apply --auto-approve
```
This will create a Debian 10 VPS (droplet) in Digital Ocean, install curl, Docker, and copy a Shell script and a Dockerfile in a `/root/favicons` dir.

## Acknowledgments
This repo was inspired by [skillfactory.ru](https://skillfactory.ru/devops#syllabus) team

## See also 
- [Use volumes](https://docs.docker.com/storage/volumes/)
- [Running Custom Scripts In Docker With Arguments](https://devopscube.com/run-scripts-docker-arguments/)  
- [How to run wget inside Ubuntu Docker image](https://stackoverflow.com/questions/28885137/how-to-run-wget-inside-ubuntu-docker-image)

## License
Follow all involved parties licenses terms and conditions.


