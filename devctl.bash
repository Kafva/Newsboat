#!/bin/bash
# For the provisioing profile to update automatically (as in the Xcode GUI) 
# the -allowProvisiongUpdates flag is neccessary
# The profiles are stored under ~/Library/MobileDevice/Provisioning\ Profiles
PROJECT=RSSman
SRC_DIR=src
DBNAME=rss.db
BUNDLE_ID=com..RSSman
URLS=~/.newsboat/urls

if [ "$1" = test ]; then
    [ -f test ] && rm test
    [ -d test.dSYM ] && rm -rf test.dSYM
    clang -g -framework Foundation -lsqlite3 $SRC_DIR/tests/main.m $SRC_DIR/util.m -o test && ./test $2
elif [ "$1" = ls ]; then
    # NOTE that the path shown is the root of the app which is mounted at NSHomeDirectory()
    [ -z $(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p') ] && echo "No iOS device connected" && exit 1
    ios-deploy --bundle_id $BUNDLE_ID --list=/
elif [ "$1" = listen ]; then
    [ -z $(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p') ] && echo "No iOS device connected" && exit 1
    idevicesyslog -p $PROJECT
elif [ "$1" = build ]; then
    iphone_id=$(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p')
    [ -z $iphone_id ] && echo "No iOS device connected" && exit 1
    xcodebuild build -destination "id=$iphone_id" -allowProvisioningUpdates OTHER_CFLAGS="-Xclang -Wno-unused-function"
elif [ "$1" = clean ]; then 
    [ -f test ] && rm test
    [ -d test.dSYM ] && rm -rf test.dSYM
    xcodebuild clean
elif [ "$1" = download ]; then
    [ -z $(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p') ] && echo "No iOS device connected" && exit 1
    ios-deploy --bundle_id $BUNDLE_ID --download=/Documents/$DBNAME --to . && mv Documents/$DBNAME ./$DBNAME && rmdir Documents
elif [ "$1" = deploy ]; then
    
    # Same as `idevice_id`
    iphone_id=$(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p')
    [ -z $iphone_id ] && echo "No iOS device connected" && exit 1

    # Create the database anew
    ./createDatabase.bash $DBNAME $URLS

    #   xcodebuild -showBuildSettings
    xcodebuild build -destination "id=$iphone_id" -allowProvisioningUpdates OTHER_CFLAGS="-Xclang -Wno-unused-function" && 
    ideviceinstaller -i build/Release-iphoneos/${PROJECT}.app &&

    # Upload the sqlite database to NSHomeDirectory()/Documents/
    ios-deploy --bundle_id $BUNDLE_ID --upload $DBNAME --to /Documents/$DBNAME

fi

