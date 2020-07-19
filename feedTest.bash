#!/bin/bash

if [ "$1" = start ]; then
	# Start the web-server for the RSS feed with the original entries
	cp testing/rss_original.xml testing/public/rss.xml
	pgrep node || http-server testing/public/ 2> /dev/null 

elif [ "$1" = update ]; then
	# Update the test feed with a new video entry
	pgrep node &> /dev/null && cp testing/rss_updated.xml testing/public/rss.xml

elif [ "$1" = rollback ]; then
	pgrep node &> /dev/null && cp testing/rss_original.xml testing/public/rss.xml

elif [ "$1" = stop ]; then
	pkill node
fi