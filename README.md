# Openroadmap setup
This repository was made to ensure a proper initial setup to the openroadmap project

## Getting Started
To run this project you previously need to install:
* ```docker``` & ```docker-compose``` 

### Running the App with Docker
#### Create the container's network
```
make network
```

#### Starting the containers
```
make run
```
#### Access the container through SSH
```
make enter
```
#### Start the server
```
make s
```
#### Creating DB
```
make db-create
```
#### Inside the container run the migrations and seeds:
```
rails db:migrate
rails db:seed
```

## Versions
This project is build with Ruby `2.6.8` with Rails `5.2.6`
