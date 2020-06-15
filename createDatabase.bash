#!/bin/bash

# Upload to app's filesystem
#   ios-deploy --bundle_id com..RSSman --upload rss.db --to /Documents/rss.db

DBNAME=rss.db
[ -f $DBNAME ] && rm $DBNAME

sqlite3 $DBNAME -cmd '
CREATE TABLE IF NOT EXISTS main.`Channels`
( 
    `id` INTEGER PRIMARY KEY AUTOINCREMENT, 
    `name` VARCHAR(255), 
    `rssLink` VARCHAR(255) 
);

CREATE TABLE IF NOT EXISTS main.`Videos`
( 
    `timestamp` TIMESTAMP,  
    `title` VARCHAR(255), 
    `viewed` BOOLEAN, 
    `owner` INTEGER,  
    FOREIGN KEY (`owner`) REFERENCES `Channels`(id) 
);

INSERT INTO main.`Channels` (`name`,`rssLink`) VALUES ("eyepatch wolf", "https://www.youtube.com/feeds/videos.xml?channel_id=UCtGoikgbxP4F3rgI9PldI9g");

SELECT @last = last_insert_rowid();

INSERT INTO main.`Videos` (`title`,`viewed`,`owner`) VALUES ( "WOW title", 0 , @last );

'

