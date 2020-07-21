# Base dockerfile

This repo contains the docker images 
#### base
can be used a base to build new images
###### usage
- standalone
```
docker pull aditya005/base:latest
```
- inside Dockerfile
```
FROM aditya005/base:latest
```

#### Chromedriver
chromedriver image can be used to run a container to access chromedriver interface

###### usage 
- standalone 
```
docker pull aditya005/chromedriver:latest
```
- using docker-compose
```
services:
    chromedriver:
    image: aditya005/chromedriver:latest
    init: true
    tmpfs: /tmp
    environment:
    - DISABLE_X11=false
    - ENABLE_VNC=true
    - EXPOSE_X11=true
    ports:
    - 127.0.0.1:5900:5900
```