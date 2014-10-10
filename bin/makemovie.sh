#!/bin/bash

FUNCTIONS=$(dirname $0)/functions
if [ ! -f $FUNCTIONS ]
then
    echo "Can't find functions file: $FUNCTIONS"
    exit 2
else
    . $FUNCTIONS
fi

generate_video()
{
    mkdir -p $VIDEO_DIR

#    echo "Created $VIDEO_DIR/$VIDEO_FILE"
#    cat ${TMP_FILE} | wc -l
#    cat ${TMP_FILE} 
#exit

    mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4:aspect=16/9:vbitrate=8000000 -vf scale=1920:1080 -o $VIDEO_DIR/$VIDEO_FILE -mf type=jpeg:fps=${FPS} mf://@${TMP_FILE}
    exit_on_error $? ": generating video"


    rm ${TMP_FILE}
}


read_conf_file $1
shift
init_sync_host

check_image_count()
{
    IMAGE_CNT=$(wc -l $TMP_FILE | awk '{print $1}')
    
    if [ "$IMAGE_CNT" = "0" ]
    then
	echo "Missing videos from $Y_YEAR $Y_MONTH $Y_DAY"
	
	exit 3
    fi
}


find_images()
{
    find $LOCAL_DIR/ -name "${1}"  | sort -u > $TMP_FILE
    exit_on_error $? ": finding photos"

    check_image_count
    echo "REGEXP '$1' => $IMAGE_CNT photos"    
}

setup_daily()
{
    find_images "${Y_YEAR}-${Y_MONTH}-${Y_DAY}*.jpg"

    FPS=10
    VIDEO_DIR=$WWW_DEST_DIR/videos/$YEAR/$MONTH/
    VIDEO_FILE=daily-$DAY.avi
    REM_REGEXP="daily-*.avi"
}

setup_monthly()
{
    find_images "${Y_YEAR}-${Y_MONTH}*.jpg" 

    check_image_count
    
    FPS=10
    VIDEO_DIR=$WWW_DEST_DIR/videos/$YEAR/
    VIDEO_FILE=monthly-$MONTH.avi
    REM_REGEXP="monthly-*.avi"
}

setup_yearly()
{
    find_images "${Y_YEAR}-*_12-00.jpg"  

    check_image_count

    FPS=10
    VIDEO_DIR=$WWW_DEST_DIR/videos/
    VIDEO_FILE=yearly-$YEAR.avi
    REM_REGEXP="yearly-*.avi"
}

Y_YEAR=$(date +"%Y" -d "yesterday")
Y_MONTH=$(date +"%m" -d "yesterday")
Y_DAY=$(date +"%d" -d "yesterday")

case "$1" in
    "--daily")
	setup_daily
	;;
    "--monthly")
	setup_monthly
	;;
    "--yearly")
	setup_yearly
	;;
esac

generate_video
LATEST_DIR=$VIDEO_DIR/latest
if [ ! -d $LATEST_DIR ]
then
    mkdir -p $LATEST_DIR
fi

rm -f $LATEST_DIR/$REM_REGEXP
ln -s $VIDEO_DIR/$VIDEO_FILE $LATEST_DIR/

