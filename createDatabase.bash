#!/bin/bash

# Upload to app's filesystem
#   ios-deploy --bundle_id com..RSSman --upload rss.db --to /Documents/rss.db

[ -n $1 ] && DBNAME=rss.db
[ -n $1 ] || DBNAME=$1
[ -n $2 ] && URLS=~/.newsboat/urls
[ -n $2 ] || URLS=$2

[ -f $DBNAME ] && rm $DBNAME

# Newsboat URLs format: 
#   RSS | Channel link | tag | name

if [ -f $URLS ]; then
    
    # Create the neccessary tables
    echo 'CREATE TABLE IF NOT EXISTS main.`Channels`
    ( 
        `id` INTEGER PRIMARY KEY AUTOINCREMENT, 
        `name` VARCHAR(255) UNIQUE, 
        `rssLink` VARCHAR(255),
        `channelLink` VARCHAR(255) 
    );
    
    CREATE TABLE IF NOT EXISTS main.`Videos`
    ( 
        `timestamp` TIMESTAMP,  
        `title` VARCHAR(255), 
        `viewed` BOOLEAN, 
        `owner` INTEGER,
        `link` VARCHAR(255),  
        FOREIGN KEY (`owner`) REFERENCES `Channels`(id),
        UNIQUE(title, owner) 
    );
    ' | sqlite3 $DBNAME

    cmd=""

    while IFS= read -r line; do
        
        if $(echo $line | grep -q "^https://www.you"); then
            name=$(echo $line | sed 's/.*"[~!]\{1\}\([-_.,0-9A-Za-z ]\{1,\}\)"$/\1/g' | tr -d '"')
            rssLink=$(echo $line | awk '{print $1}')
            channelLink=$(echo $line | awk '{print $2}')

            cmd="$cmd INSERT INTO main.\`Channels\` (\`name\`,\`rssLink\`,\`channelLink\`) VALUES (\"$name\",\"$rssLink\",$channelLink);" 
        fi

    done < $URLS

    echo $cmd | sqlite3 $DBNAME

else
    echo "Can't find: $URLS"
fi