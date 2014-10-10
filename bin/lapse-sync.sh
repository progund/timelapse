#!/bin/bash

FUNCTIONS=$(dirname $0)/functions
if [ ! -f $FUNCTIONS ] 
then
    echo "Can't find functions file: $FUNCTIONS"
    exit 2
else
    . $FUNCTIONS
fi


get_images() 
{
    rsync  -arv --progress --exclude=lost+found  $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR $LOCAL_DIR/
    exit_on_error $? ": rsync"
}

read_conf_file $1
shift

init_sync_host
get_images



