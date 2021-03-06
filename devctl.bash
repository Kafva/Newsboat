#!/bin/bash
# For the provisioing profile to update automatically (as in the Xcode GUI) 
# the -allowProvisiongUpdates flag is neccessary
# The profiles are stored under ~/Library/MobileDevice/Provisioning\ Profiles
PROJECT=Newsboat
SRC_DIR=src
DBNAME=rss.db
BUNDLE_ID=com..Newsboat
URLS=~/.newsboat/urls

function deploy()
{
    # Same as `idevice_id`
    iphone_id=$(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p')
    [ -z "$iphone_id" ] && echo "No iOS device connected" && exit 1

    # Create the database anew
    ./createDatabase.bash $DBNAME $URLS

    # Remove unused function warnings since all the sqlite callbacks are listed as unused
    # [-allowProvisioningUpdates] is essential for a new provisioning profile to be created once the
    # one has expired (after 7 days)
    #   xcodebuild -showBuildSettings
    xcodebuild build -destination "id=$iphone_id" -allowProvisioningUpdates OTHER_CFLAGS="-Xclang -Wno-unused-function" && 
    ideviceinstaller -i build/Release-iphoneos/${PROJECT}.app &&

    # Upload the sqlite database to NSHomeDirectory()/Documents/
    ios-deploy --bundle_id $BUNDLE_ID --upload $DBNAME --to /Documents/$DBNAME
    return $?
}


if [ "$1" = test ]; then
    [ -f test ] && rm test
    [ -d test.dSYM ] && rm -rf test.dSYM
    clang -g -framework Foundation -lsqlite3 $SRC_DIR/tests/main.m $SRC_DIR/backend.m -o test && ./test $2
elif [ "$1" = ls ]; then
    # NOTE that the path shown is the root of the app which is mounted at NSHomeDirectory()
    [ -z $(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p') ] && echo "No iOS device connected" && exit 1
    ios-deploy --bundle_id $BUNDLE_ID --list=/
elif [ "$1" = listen ]; then
    [ -z "$(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p')" ] && echo "No iOS device connected" && exit 1
    idevicesyslog -p $PROJECT
elif [ "$1" = build ]; then
    iphone_id=$(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p')
    [ -z "$iphone_id" ] && echo "No iOS device connected" && exit 1
    xcodebuild build -destination "id=$iphone_id" -allowProvisioningUpdates OTHER_CFLAGS="-Xclang -Wno-unused-function"
elif [ "$1" = clean ]; then 
    [ -f test ] && rm test
    [ -d test.dSYM ] && rm -rf test.dSYM
    xcodebuild clean
elif [ "$1" = download ]; then
    [ -z "$(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p')" ] && echo "No iOS device connected" && exit 1
    ios-deploy --bundle_id $BUNDLE_ID --download=/Documents/$DBNAME --to . && mv Documents/$DBNAME ./$DBNAME && rmdir Documents
elif [ "$1" = upload ]; then
    [ -z "$(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p')" ] && echo "No iOS device connected" && exit 1
    ios-deploy --bundle_id $BUNDLE_ID --upload $DBNAME --to /Documents/$DBNAME
elif [ "$1" = deploy ]; then
    deploy 
elif [ "$1" = run ]; then
    deploy &&
    idevicedebug run $BUNDLE_ID
elif [ "$1" = debug ]; then
    deploy && 

    # The [-m] flag avoids reinstalling the app and starts debugging immediatelly
    ios-deploy -m -b build/Release-iphoneos/${PROJECT}.app 

elif [ "$1" = archive ]; then
    # Generate an .ipa file by first creating an intermediary .xcarchive

    [ -d  ./$PROJECT.xcarchive ] && rm -rf $PROJECT.xcarchive
    xcodebuild -project $PROJECT.xcodeproj -scheme $PROJECT -archivePath ./$PROJECT.xcarchive OTHER_CFLAGS="-Xclang -Wno-unused-function" archive &&
    xcodebuild -exportArchive -archivePath ./$PROJECT.xcarchive -exportPath ./$PROJECT.ipa.d -exportOptionsPlist src/exportOptions.plist &&
    rm -rf $PROJECT.xcarchive

fi

