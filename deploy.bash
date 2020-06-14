#!/bin/bash
# For the provisioing profile to update automatically (as in the Xcode GUI) 
# the -allowProvisiongUpdates flag is neccessary
# The profiles are stored under ~/Library/MobileDevice/Provisioning\ Profiles
PROJECT=RSSman

if [ "$1" = test ]; then
    clang -framework Foundation $PROJECT/tests/main.m $PROJECT/util.m -o test && ./test $2
elif [ "$1" = clean ]; then 
    [ -f test ] && rm test
    xcodebuild clean && exit 0
else
    # Same as `idevice_id`
    iphone_id=$(system_profiler SPUSBDataType | sed -n 's/^[ ]\{1,\}Serial Number: \(.*\)/\1/p')

    [ -z $iphone_id ] && echo "No iPhone device connected" && exit 1

    # The ideviceinstaller tool from the libimobiledevice project is preferred over ios-deploy
    xcodebuild build -destination "id=$iphone_id" -allowProvisioningUpdates && ideviceinstaller -i build/Release-iphoneos/${PROJECT}.app
fi

