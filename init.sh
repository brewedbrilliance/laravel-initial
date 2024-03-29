# BrewedBrilliance.net 
# composer wrapper for creating new laravel project
# in a docker environment
# $1 = project name
# $2 = -f (force creation, delete existing app and replace)

DEV_FOLDER=`pwd`
DEVELOPMENT_PORT=8081
PROJNAME=$1
FORCE_FLAG=$2
LARAVEL_APP=$DEV_FOLDER/$PROJNAME
ENVFILE=.env

create_env() {
    if [ "$FORCE_FLAG" = "-f" ];then
        echo "Removing Env file"
        rm -rf $ENVFILE 2>&1 
    fi
    if [ -f $ENVFILE ]; then
        echo "Env file [.env] already exists..."
        exit 2
    fi
    echo "DEVELOPMENT_FOLDER=$LARAVEL_APP" > .env
    echo "MOUNT_PATH=/var/www/html/$PROJNAME" >> .env
    echo "PROJ_NAME=$PROJNAME" >> .env
    echo "DEVELOPMENT_PORT=$DEVELOPMENT_PORT" >> .env
}


# this was a tricky one
wait_until_up_db() {
    CONTAINER=$1
    iteration=0
    stopvalue=5
    check=
    
    while [ "$check" = "" ]; do
        check=`docker logs $CONTAINER 2>&1 | grep "/usr/sbin/mysqld: ready for connections"`
        echo "Waiting [$CONTAINER] to be up [$iteration]"
        iteration=$((iteration+1))
        if [ $iteration -gt $stopvalue ];then
            exit 24
        fi
        sleep 1
    done
}

wait_until_up() {
    CONTAINER=$1
    iteration=0
    stopvalue=5
    check=
    
    while [ "$check" = "" ]; do
        check=`docker ps -qf "name=$CONTAINER"`
        echo "Waiting [$CONTAINER] to be up [$iteration]"
        iteration=$((iteration+1))
        if [ $iteration -gt $stopvalue ];then
            exit 23
        fi
        sleep 1
    done
}

run_migrations() {
    echo "Running Migrations for [$PROJNAME]"
    docker exec -it $PROJNAME sh -c "cd /var/www/html/$PROJNAME && php artisan migrate:fresh"
}


is_available() {
    cmd_to_check=`echo $1|sed "s/\///g"`
    r=`which $cmd_to_check`
    if [ "x$r" = "x" ];then
        echo "$cmd_to_check is not available"
        exit 1
    else
        echo "[$cmd_to_check] is available"
    fi
}

docker_build() {
    res=`docker-compose build`
    echo $res
}

docker_run() {
    res=`docker-compose up -d`
    echo $res
}

create() {
    echo "Creating laravel project in [$1]"
    sleep 5
    composer create-project laravel/laravel $1
    echo "$? > after creating laravel project for $1" > /tmp/init-log
}

create_bootstrap_proj() {
    PRJFOLER=$1
    echo "Creating the bootstrap project in [$PRJFOLER]..."
    if [ "$FORCE_FLAG" = "-f" ];then
        echo "[$PRJFOLER] will be removed"
        rm -rf $PRJFOLER 2>&1 
    fi
    echo "Installing the laravel application"
    if [ ! -d $PRJFOLER ];then
        echo "The project folder [$PRJFOLER] does not exist"
        create "$PRJFOLER"
    elif [ -z "$(ls -A $PROJNAME)" ]; then
        echo "The project folder [$PRJFOLER] is empty"
        create "$PROJNAME"
    fi
}

create_env $FORCE
is_available docker
is_available docker-compose
is_available composer
create_bootstrap_proj $PROJNAME 
docker_build
docker_run

wait_until_up_db mysql_db

wait_until_up $PROJNAME && {
    echo "[$PROJNAME] is now up"
    run_migrations
}

echo "Laravel UP and running at http://localhost:$DEVELOPMENT_PORT/$PROJNAME/public"

