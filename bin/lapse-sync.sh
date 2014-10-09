#!/bin/bash

REMOTE_HOST=129.16.213.181
REMOTE_USER=pi
REMOTE_DIR=/media/camera-disk/

LOCAL_DIR=/home/hesa/tmp/camera-disk

TMP_FILE=/tmp/$$.txt

exit_on_error()
{
    if [ "$1" != "0" ]
	then
	echo "Failure $2"
	exit $1
    fi
}

if [ ! -d $LOCAL_DIR ]
then
    mkdir -p $LOCAL_DIR 
    exit_on_error $? ": mkdir $LOCAL_DIR"
fi

get_images() 
{
    rsync  -arv --progress --exclude=lost+found  $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR $LOCAL_DIR/
    exit_on_error $? ": rsync"
}

generate_video()
{
    find $LOCAL_DIR/ -name "*.jpg"  | sort -u > $TMP_FILE
    exit_on_error $? ": finding photos"
    
     mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4:aspect=16/9:vbitrate=8000000 -vf scale=1920:1080 -o $LOCAL_DIR/timelapse.avi -mf type=jpeg:fps=4 mf://@${TMP_FILE}
    exit_on_error $? ": generating video"

    rm ${TMP_FILE}
}


if [ "$1" = "--get" ]
then
    get_images
elif [ "$1" = "--gen" ]
then
    generate_video
else
    get_images
    generate_video
fi


