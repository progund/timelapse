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

    mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4:aspect=16/9:vbitrate=8000000 -vf scale=1920:1080 -o $VIDEO_DIR/$VIDEO_FILE -mf type=jpeg:fps=4 mf://@${TMP_FILE}
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

setup_daily()
{
    find $LOCAL_DIR/ -name "${Y_YEAR}-${Y_MONTH}-${Y_DAY}*.jpg"  | sort -u > $TMP_FILE
    exit_on_error $? ": finding photos"

    check_image_count
    
    VIDEO_DIR=$WWW_DEST_DIR/videos/$YEAR/$MONTH/
    VIDEO_FILE=timelapse-$DAY.avi
}

setup_monthly()
{
    find $LOCAL_DIR/ -name "${Y_YEAR}-${Y_MONTH}*.jpg"  | sort -u > $TMP_FILE
    exit_on_error $? ": finding photos"

    check_image_count
    
    VIDEO_DIR=$WWW_DEST_DIR/videos/$YEAR/
    VIDEO_FILE=timelapse-$MONTH.avi
}

setup_yearly()
{
    find $LOCAL_DIR/ -name "${Y_YEAR}-*_12-00.jpg"  | sort -u > $TMP_FILE
    exit_on_error $? ": finding photos"

    check_image_count

    VIDEO_DIR=$WWW_DEST_DIR/videos/
    VIDEO_FILE=timelapse-$YEAR.avi
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


