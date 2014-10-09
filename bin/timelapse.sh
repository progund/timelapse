#!/bin/sh

DEST_DIR_BASE=/media/camera-disk/
WIDTH="2592"
HEIGHT="1944"
LOG_FILE=$DEST_DIR_BASE/timelapse.log
DAYS_OLD_WHEN_REMOVED=30


YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DEST_DIR=$DEST_DIR_BASE/$YEAR/$MONTH
DATE=$(date +"%Y-%m-%d_%H-%M")

PREVENT_REMOVAL="false"

if [ ! -d $DEST_DIR ]
then
    mkdir -p $DEST_DIR 
    RET=$?
    if [ "$RET" != "0" ]
	then
	echo "Failed creating dir...."
	exit $RET
    fi
fi

log()
{
    echo "[$(date)]   $*" >> $LOG_FILE
}


#
# find and remove old dirs
#
clean_up_old_dirs() 
{
    for i in $(find ${DEST_DIR_BASE} -mtime +${DAYS_OLD_WHEN_REMOVED} -type d)
    do
	log   "  * removing files and dirs dir $i"

	if [ "$PREVENT_REMOVAL" != "true" ]
	then
	    rm    $i/*.jpg 2>> $LOG_FILE
	    rmdir $i/*     2>> $LOG_FILE
	    rmdir $i       2>> $LOG_FILE
	else
	    echo " * not removing $i ($PREVENT_REMOVAL)"
	fi
    done
}



clean_up_old_dirs

PHOTO_NAME=$DEST_DIR/$DATE.jpg
log "Photo: $PHOTO_NAME [${WIDTH}x${HEIGHT}]"
raspistill  -w $WIDTH -h $HEIGHT -o $PHOTO_NAME
RET=$?
if [ "$RET" != "0" ]
then
    log "*** ERROR: $PHOTO_NAME failed ***"
    echo "Failed taking photo....$PHOTO_NAME"
    exit $RET
fi
#log " ... end :)"



