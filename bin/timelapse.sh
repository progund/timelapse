#!/bin/bash

FUNCTIONS=$(dirname $0)/functions
if [ ! -f $FUNCTIONS ]
then
    echo "Can't find functions file: $FUNCTIONS"
    exit 2
else
    . $FUNCTIONS
fi



PREVENT_REMOVAL="false"



#
# find and remove old dirs
#
clean_up_old_dirs() 
{
    for i in $(find ${CAM_DEST_DIR_BASE} -mtime +${DAYS_OLD_WHEN_REMOVED} -type d)
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



read_conf_file $1
shift
if [ ! -d $CAM_DEST_DIR ]
then
    mkdir -p $CAM_DEST_DIR 
    RET=$?
    if [ "$RET" != "0" ]
	then
	echo "Failed creating dir...."
	exit $RET
    fi
fi


clean_up_old_dirs

PHOTO_NAME=$CAM_DEST_DIR/$DATE.jpg
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



