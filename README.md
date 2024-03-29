# Laravel bootstrap app on docker

This is a bootsrapp laravel application on docker-compose for speeding up your environment setup offered by  [BrewedBrilliance](https://brewedbrilliance.net):

Full article here [https://brewedbrilliance.net/bootstrap-your-laravel-application-on-docker/](https://brewedbrilliance.net/bootstrap-your-laravel-application-on-docker/)

# Prerequisites

To make it working you need to have installed:
- docker engine
- docker-compose
- composer

## Settings needed

In init.sh there is a1 function `create_env` that is responsible for creating the .env file needed to the docker-compose.yaml file. 
`DEV_FOLDER` is the volume folder that will be mounted in the docker container 
`DEVELOPMENT_PORT` is the apache container port
`PROJNAME` will be the first argument passed to the script
`FORCE_FLAG`is the flag for forcing the overwrite and reset of an existing project
 
## Run the script and setup the environment

To create your bootstrap application just run
`sh init.sh <project-name> [-f]` 
example
`sh init.sh my_local_laravel -f`
The script will start all the procedurs for creating the docker containers, setting up the database and run composer for creating the laravel project and wait the database to be ready for running the migrations

## More information
More information can be found on [BrewedBrilliance](https://brewedbrilliance.net)
