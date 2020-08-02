#include "backend.h"
// Global function can be defined and called with default C syntax

// Nearly all methods should act upon the created object and not the entire class
// Class methods:    +(void) foo {}
// Instance methods: -(void) foo {}

@implementation Channel : NSObject
    
    // Create a getter/setter for the attributes which don't inherit from NSObject
    @synthesize unviewedCount;
   
   -(NSString*) description { return [NSString stringWithFormat:@"<Channel:%p> %@ (%d) [id:%d]", self, self.name, self.unviewedCount, self.id ]; }
@end

@implementation Video : NSObject
    @synthesize viewed;
    
    -(NSString*) description { return [NSString stringWithFormat:@"<Video:%p> title: %@", self, self.title ]; }
    -(void)setAllViewedAttr: (BOOL)newState { self.viewed = newState; }
@end

@implementation Handler : NSObject

    //*************** BASIC ****************//
    
    -(id) init 
    { 
        self.dbPath = @"";
        self.db = nil;
        return self;
    }

    -(id) initWithDB: (NSString*)dbPath
    //**** Note that the database is opened here, and only here *****//
    {
        // Alternative constructor
        self.dbPath = dbPath;
        [self openDatabase];
        return self;
    }

    -(int) openDatabase
    {
        // Create a seperate db_ object pointer for the open() call
        sqlite3* db_;

        int ret = sqlite3_open( [self.dbPath cStringUsingEncoding:NSUTF8StringEncoding ], &db_ );
        if ( ret != SQLITE_OK  )
        {
            NSLog(@"Error opening database: %d", ret);
        }
        else
        { 
            NSLog(@"Database open!"); 
            self.db = db_; 
        }

        return ret;
    }

    -(int) closeDatabase
    {
        if ( self.db ){ return sqlite3_close(self.db); } else { return 0; }
    }

    -(int) channelIdFromName: (const char*)name
    {
        NSMutableArray* channels = [[NSMutableArray alloc] init];
        char* err_msg;
        char* stmt = malloc(sizeof(char)*VARCHAR_SIZE);
        sprintf(stmt, "SELECT * FROM `Channels` WHERE `name` LIKE \"%s\";", name); 
        //NSLog(@"STMT: %s", stmt);

        // The callback method will create a channel object from which we can extract the ID
        int ret = sqlite3_exec( self.db , stmt, callbackChannelObjects, (__bridge void*)channels, &err_msg );
        
        if ( ret != SQLITE_OK  ) {  NSLog(@"%s", err_msg);  }
        else
        // Set the return value to -1 if no channels were found
        {
            ret = -1;
            if ( channels.count > 0 ) { ret = [[channels objectAtIndex:0] id]; }
        }
        
        free(stmt);
        return ret; 
    }


    -(int) queryStmt: (const char*)stmt
    {
        char* err_msg;
        // The callback function prints the result of the query
        int ret = sqlite3_exec( self.db , stmt, callbackPrint, NULL, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        return ret;
    }

    //************** Utility *******************//

    -(int) getUnviewedCount: (const char*)channel count:(int)count
    {
        int unviewedCount = VIDEOS_PER_CHANNEL;
        NSMutableArray* vids = [[NSMutableArray alloc] init];
        [self getVideosFrom: channel count:count videos: vids];

        // Edge case if the channel has less than the limit uploaded
        if (vids.count < unviewedCount) { unviewedCount = (int)vids.count; }

        // Set the channel objects unviewed count based upon the number derived after the RSS fetch
        // True: 1      False: 0
        for (int i=0; i<vids.count; i++) { unviewedCount = unviewedCount - [[vids objectAtIndex:i] viewed]; }

        return unviewedCount;
    }


    -(int) getVideosFrom: (const char*)channel count:(int)count videos:(NSMutableArray*) videos
    {
        char* err_msg;
        char* stmt = malloc(sizeof(char)*VARCHAR_SIZE); 

        // NOTE that if channels have similar names the wrong vidoes could be returned with a greedy RegEx
        sprintf(stmt, "SELECT * FROM `Videos` WHERE `owner` = (SELECT `id` FROM `Channels` WHERE `name` LIKE \"%s\") ORDER BY `timestamp` DESC LIMIT %d;", channel, count); 
        //NSLog(@"Video FETCH STMT: %s", stmt);

        // The callback function creates Video objects which are returned to the paramater passed to the method 
        int ret = sqlite3_exec( self.db , stmt, callbackVideoObjects, (__bridge void*)videos, &err_msg );
        //ret = sqlite3_exec( self.db , stmt, callbackPrint, NULL, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }

        free(stmt);

        return ret;
    }
    
    -(int) getChannels: (NSMutableArray*)channels name:(NSString*)name
    // Return all the channel objects from the database
    {
        char* err_msg;
        char* stmt = malloc(sizeof(char)*VARCHAR_SIZE);
        sprintf(stmt, "SELECT * FROM `Channels` WHERE `name` LIKE \"%%%s%%\" ORDER BY `name` ASC", [name cStringUsingEncoding: NSUTF8StringEncoding]); 

        // The callback function creates Video objects which are returned to the paramater passed to the method 
        int ret = sqlite3_exec( self.db , stmt, callbackChannelObjects, (__bridge void*)channels, &err_msg );
        //int ret = sqlite3_exec( self.db , stmt, callbackPrint, (__bridge void*)channels, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        
        free(stmt);
        return ret;
    }

    -(int) getChannels: (NSMutableArray*)channels
    // Return all the channel objects from the database
    {
        char* err_msg;
        char* stmt = "SELECT * FROM `Channels` ORDER BY `name` ASC"; 

        // The callback function creates Video objects which are returned to the paramater passed to the method 
        int ret = sqlite3_exec( self.db , stmt, callbackChannelObjects, (__bridge void*)channels, &err_msg );
        //int ret = sqlite3_exec( self.db , stmt, callbackPrint, (__bridge void*)channels, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        
        return ret;

    }
    
    -(int) setAllViewedInDatabase
    {
        char* err_msg;
        char* stmt = malloc(sizeof(char)*SQL_ROW_BUFFER); 
        strcpy(stmt,"UPDATE `Videos` SET `viewed` = TRUE ;");
        //NSLog(@"Set all STMT: %s", stmt); 
        
        int ret = sqlite3_exec( self.db , stmt, NULL, NULL, &err_msg );
        if (ret != SQLITE_OK) {  NSLog(@"%s", err_msg);  }
        
        free(stmt);
        return ret;
    }
    
    -(int) setAllViewedInDatabase: (int)owner_id
    {
        char* err_msg;
        char* stmt = malloc(sizeof(char)*SQL_ROW_BUFFER); 
        strncpy(stmt, [[NSString stringWithFormat: @"UPDATE `Videos` SET `viewed` = TRUE WHERE `owner` = %d ;",owner_id] cStringUsingEncoding:NSUTF8StringEncoding], SQL_ROW_BUFFER );
        //NSLog(@"Set all STMT: %s", stmt); 
        
        int ret = sqlite3_exec( self.db , stmt, NULL, NULL, &err_msg );
        if (ret != SQLITE_OK) {  NSLog(@"%s", err_msg);  }
        
        free(stmt);
        return ret;
    }

    -(int) toggleViewedInDatabase: (NSString*)title owner_id:(int)owner_id
    // Toggle the viewed attribute for the video matching the given title and owner_id
    {
        char* err_msg;
        char* stmt = malloc(sizeof(char)*SQL_ROW_BUFFER); 

        if ( [title isEqual: @ALL_TITLE] )
        // Toggle the viewed attribute of all videos
        {
            strncpy(stmt, [[NSString stringWithFormat: @"UPDATE `Videos` SET `viewed` = NOT `viewed` WHERE `owner` = %d ;",owner_id] cStringUsingEncoding:NSUTF8StringEncoding], SQL_ROW_BUFFER );
        }
        else
        {
            // Due to issues with escaping single quotes the name is enclosed in double quotes
            strncpy(stmt, [[NSString stringWithFormat: @"UPDATE `Videos` SET `viewed` = NOT `viewed` WHERE `owner` = %d AND `title` = \"%@\"; ",owner_id, title ] cStringUsingEncoding:NSUTF8StringEncoding], SQL_ROW_BUFFER);
        }

        int ret = sqlite3_exec( self.db , stmt, NULL, NULL, &err_msg );
        
        if (ret != SQLITE_OK) {  NSLog(@"%s", err_msg);  }
        
        free(stmt);
        return ret;
    }
    
    //*************** Adding Videos ****************//
    // Note that addVideo() adds to the database and getVideosFrom() fetches from the database
    // when used inside the ViewController

    // rightBtn() --> fullReload() --> importRSS() --> callbackImportRSS --> 
    // handleRSS() --> downloadVideos() --> [async] --> addVideo()

    // tableView() --> fetchVideos() --> importRSS() --> callbackImportRSS -->
    // handleRSS() --> downloadVideos() --> [async] --> addVideo()


    -(int) importRSS: (const char*)channel 
    {
        int ret = -1; 
        char* stmt = malloc(sizeof(char)*VARCHAR_SIZE); 
        sprintf(stmt, "SELECT `id`,`rssLink` FROM `Channels` WHERE `name` = '%s';", channel ); 
        char* err_msg;
        
        // The callback function works as a lambda function in that each row in
        // the result is processed individually
        
        // Fetch each channelId and its corresponding RSS link with the callback function
        // handling the addition of videos via a request for the RSS Feed for each channel
        // Note that the callback in turn calls a member function of the Handler (possible by passing self as result)
        ret = sqlite3_exec( self.db , stmt, callbackImportRSS,  (__bridge void *)self, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        
        free(stmt);
        return ret;
    }

    -(int) handleRSS: (char**)columnValues
    // Import the most recent videos (not already in the database) from each channel given from the RSS feed
    // The function is ran once per output row from the sqlite3_exec() statement
    {
        // BUG occured when reloading all videos since the self.channelId value was overwritten in each
        // call, making all videos owned by the last channel, solved by scrapping the channelId attribute

        // We can safely set the RSS link since this value will be sent to each seperate call of downloadVideos()
        NSString* rssLink = @(columnValues[1]);

        // Call the downloadVideos() function to download the RSS document using the 
        // methods required for the <NSURLSessionDataDelegate> protocol
        [self downloadVideos: rssLink];
        
        return 0;
    }

    -(void) addVideo: (const char* )timestamp title:(const char* )title owner_id:(const char*)owner_id link:(const char*) link
    {
        int currentCnt = -1;
        char* err_msg;

        char** results = malloc(sizeof(char*)*(VIDEOS_PER_CHANNEL+1));
        for (int i=0; i < VIDEOS_PER_CHANNEL+1; i++) { results[i] = malloc(sizeof(char)*SQL_ROW_BUFFER); }

        char* title_ = malloc(sizeof(char)*SQL_ROW_BUFFER);
        strncpy(title_, "", 1);
        
        // 1. Check if the video already exists
        const char* stmt = [[NSString stringWithFormat: @"SELECT `title` FROM `Videos` WHERE `title` = \"%s\" AND `owner` = %s ;", title, owner_id] cStringUsingEncoding:NSUTF8StringEncoding];
        
        if ( sqlite3_exec(self.db, stmt, callbackGetTitle, (void*)title_, &err_msg) != SQLITE_OK ) {  NSLog(@"%s", err_msg);  }

        if ( strcmp(title_,"") == 0 )
        // If the title_ variable is empty the video doesn't exist
        // and we therefore check if any videos need to be removed before adding it
        {
            // 2. Check if the number of videos exceed the VIDEOS_PER_CHANNEL value
            // By fetching the number of videos owned by the channel
            stmt = [[NSString stringWithFormat: @"SELECT COUNT(*) FROM `Videos` WHERE owner = %s ; ", owner_id] cStringUsingEncoding:NSUTF8StringEncoding];

            if ( sqlite3_exec(self.db, stmt, callbackColumnValues, (void*)results, &err_msg) != SQLITE_OK ) {  NSLog(@"%s", err_msg);  }
            
            // Holds the number of videos for the current channel
            currentCnt = atoi(results[0]);

            if ( currentCnt == VIDEOS_PER_CHANNEL )
            // 3. If the current number of videos is equal to the limit we need to remove a video,
            // provided that the oldest video is older than the new video            
            {
                // Issue a select statement for videos older than the current video
                stmt = [[NSString stringWithFormat: @"SELECT COUNT(*) FROM `Videos` WHERE owner = %s AND `timestamp` < DATETIME(\"%s\"); ", owner_id, timestamp] cStringUsingEncoding:NSUTF8StringEncoding];
                if ( sqlite3_exec(self.db, stmt, callbackColumnValues, (void*)results, &err_msg) != SQLITE_OK ) {  NSLog(@"%s", err_msg);  }
                
                if ( atoi(results[0]) > 0 )
                // 4. If at least one video older than the current video to add exists delete the oldest video
                {
                    stmt = [[NSString stringWithFormat: @"DELETE FROM `Videos` WHERE owner = %s ORDER BY `timestamp` ASC LIMIT 1;", owner_id] cStringUsingEncoding:NSUTF8StringEncoding];
                    //if ( atoi(owner_id) == TEST_ID ) { NSLog(@"addVideo(): %s", stmt); }
                    if ( sqlite3_exec(self.db, stmt, NULL,NULL, &err_msg) == SQLITE_OK ) {  NSLog(@"%s", err_msg); }

                    // 5. And add the new video
                    stmt = [[NSString stringWithFormat: @"INSERT INTO `Videos` (`timestamp`, `title`, `viewed`, `owner`, `link`) VALUES (DATETIME(\"%s\"), \"%s\", FALSE , %s, \"%s\"); ",timestamp, title, owner_id, link ] cStringUsingEncoding:NSUTF8StringEncoding];
                    //if ( atoi(owner_id) == TEST_ID ) { NSLog(@"addVideo(): %s", stmt); }
                    if ( sqlite3_exec(self.db, stmt, NULL,NULL, &err_msg) == SQLITE_OK ) {  NSLog(@"%s", err_msg); }
                }
                else { NSLog(@"No video older than \"%s\" to delete exists", title); }
            }
            else
            // If the limit hasn't been reached simply add the new video
            {
                stmt = [[NSString stringWithFormat: @"INSERT INTO `Videos` (`timestamp`, `title`, `viewed`, `owner`, `link`) VALUES (DATETIME(\"%s\"), \"%s\", FALSE , %s, \"%s\"); ",timestamp, title, owner_id, link ] cStringUsingEncoding:NSUTF8StringEncoding];
                //if ( atoi(owner_id) == TEST_ID) { NSLog(@"addVideo(): %s", stmt); }
                if ( sqlite3_exec(self.db, stmt, NULL,NULL, &err_msg) == SQLITE_OK ) {  NSLog(@"%s", err_msg); }
            }
        }
        else 
        { 
            //if ( atoi(owner_id) == TEST_ID) { NSLog(@"The video: \"%s\" already exists", title); } 
        }

        free(title_);
        for (int i=0; i < VIDEOS_PER_CHANNEL+1; i++) { free(results[i]); }
        free(results);
    }


    -(void)downloadVideos: (NSString*) url 
    {
        NSLog(@"Begin download of: %@", url);
        // Create a session with the default configuration and download the data from the given URL
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForResource = 10;

        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString: url]];
        [downloadTask resume];
    }

    //******* SESSION DELEGATE PROTOCOL ***********//

    -(void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
    // Handler for failed requests
    {
        if ( task.state != NSURLSessionTaskStateRunning && error.code != 0 )
        {
            // Dispatch to the main thread since we are going to issue a UI update
            dispatch_async(dispatch_get_main_queue(), 
            ^{
                NSLog(@"************* Task state: %ld Error: %ld *********************", task.state, error.code);
                NSDictionary* dict = @{@"error": error};
                
                if ( self.noteFlag == SINGLE_FLAG )
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName: @SINGLE_NOTE object:self userInfo:dict];

                }
                else if ( self.noteFlag == FULL_FLAG )
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName: @FULL_NOTE object:self userInfo:dict];
                }
            }); 
        }
        
    }

    -(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
    // Handler for completed requests
    {
        // Important assignment
        NSData* data = [NSData dataWithContentsOfURL:location];
        
        // Dispatch to the main thread when handling the response
        dispatch_async(dispatch_get_main_queue(), 
        ^{
            // All the UI updates inisde the ViewController would need to go here instead
            NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            // Fetch the titles and timestamps for the perticular feed
            // the first entry will be the channel name and its creation date
            NSMutableArray* titles = [[NSMutableArray alloc] init];
            NSMutableArray* timestamps = [[NSMutableArray alloc] init];
            NSMutableArray* links = [[NSMutableArray alloc] init];
            
            getDataFromTag(@"title", response, titles);
            getDataFromTag(@"published", response, timestamps);
            getHrefFromTag(@"link", response, links);

            if (titles.count > 0)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:3];
                
                // The first title will be the channelName which we can use to get the owner_id without the use
                // of a member variable (that would be overwritten in every iteration in fullReload()) in the Handler
                int channelId = [self channelIdFromName: [titles[0] cStringUsingEncoding: NSUTF8StringEncoding] ];

                int cnt = VIDEOS_PER_CHANNEL + 1;
                if ( titles.count < cnt ){ cnt = (int)titles.count; }

                if ( channelId == -1 )
                { 
                    NSLog(@"No channel found by the name: %@ (make sure the ~Name and YT name match)", titles[0]); 
                    NSError* err = [[NSError alloc] initWithDomain:@"UserDefined" code: (NSUInteger)1 userInfo:nil];
                    [dict setObject: err forKey:@"error"];
                }
                else
                {
                    for (int i=1; i < cnt; i++)
                    // NOTE that we only attempt to add the number of videos set by the global constant
                    // incremented by 1 to take the inital value of i=1 into account
                    {
                        // addVideo() adds to the database not to the videos datasource
                        [self addVideo: [ timestamps[i] cStringUsingEncoding:NSUTF8StringEncoding ] title: [titles[i] cStringUsingEncoding:NSUTF8StringEncoding] owner_id: [[NSString stringWithFormat: @"%d", channelId] cStringUsingEncoding: NSUTF8StringEncoding] link: [links[i] cStringUsingEncoding:NSUTF8StringEncoding]];
                    }
                }

                // Use seperate notication handlers for clicking an entry and pressing the full reload button
                if ( self.noteFlag == SINGLE_FLAG )
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName: @SINGLE_NOTE object:self userInfo:dict];
                }
                else if ( self.noteFlag == FULL_FLAG )
                {
                    // For all the fetches to get the correct number of unviewed videos we need to fetch
                    // the 'viewed' status of each video from the database BEFORE sending the notification
                    if (channelId != -1)
                    {
                        int unviewedCount = [self getUnviewedCount: [titles[0] cStringUsingEncoding: NSUTF8StringEncoding] count:cnt];
                        
                        // Send the unviewedCount and channel name with the notification inisde the 'userInfo' dict
                        [dict setObject: [NSNumber numberWithInt: unviewedCount] forKey:@"unviewedCount"]; 
                        [dict setObject: titles[0] forKey:@"channel"]; 
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName: @FULL_NOTE object:self userInfo:dict];
                }
            }
            else { NSLog(@"No response data extracted"); }

        });
    }

@end


//*************** XML PARSING *******************//

void getDataFromTag( NSString* tag, NSString* response, NSMutableArray* tagData)
{
    if (response != nil)
    {
        // Init the neccessary variables
        NSMutableString* fullTag = [[NSMutableString alloc] init];
        NSRange range1;
        NSRange range2;

        // Copy the response into a mutable string 
        NSMutableString* res = [[NSMutableString alloc] init ];
        [res setString: response];

        while (true)
        {
            // Create the full tag: <tag>
            [fullTag setString:@"<>"];
            [fullTag insertString: tag atIndex:(NSUInteger)1 ];

            // Find the first occurence of the fullTag in the response and exit if non exist
            range1 = [res rangeOfString: fullTag ];
            if ( range1.location == NSNotFound ) { break; }
            
            // Create the full closing tag: </tag>
            [fullTag setString:@"</>"];
            [fullTag insertString: tag atIndex:(NSUInteger)2 ];

            // Find the first occurence of the closing tag in the response
            range2 = [res rangeOfString: fullTag ];
            
            // Get number of characters in selection from vi: <g ctrl-g>
            // The location refers to the first character of the match, we want to extract the
            // data in between [ location1+length, location2 ] 
            
            // Note: NSMakeRange(start,length)
            NSRange dataRange = NSMakeRange( range1.location + range1.length , range2.location - (range1.location + range1.length)  );
            
            // Allocate a new object for each string
            NSMutableString* tagData_ = [[NSMutableString alloc] init];
            
            // Insert the data substring into tagData_
            [tagData_  insertString: [res substringWithRange: dataRange ] atIndex:0  ];
            
            // Append a \0 character and add it to the array
            [tagData_ insertString: [[NSString alloc] initWithCharacters:(const unichar*)"\0" length:1 ] atIndex: dataRange.length ];
            
            // Add the tagData_ to the array after sanitizing it
            [tagData addObject: sanitize(tagData_) ];

            // Remove all data in the response up until the end of range2 </tag>
            [res deleteCharactersInRange: NSMakeRange(0,range2.location + range2.length) ];
        }
    }
}

void getHrefFromTag( NSString* tag, NSString* response, NSMutableArray* tagData)
{
    // <link rel="alternate" href="https://www.youtube.com/watch?v=hVYzc2Xpup0"/>
    // ==> https://www.youtube.com/watch?v=hVYzc2Xpup0 
    
    if (response != nil)
    {
        // Init the neccessary variables
        NSMutableString* search = [[NSMutableString alloc] init];
        NSRange range1;
        NSRange range2;

        // Copy the response into a mutable string 
        NSMutableString* res = [[NSMutableString alloc] init ];
        [res setString: response];

        while (true)
        {
            // Set the search string for the start of the URL
            [search setString:@"<link rel=\"alternate\" href=\""];

            // Find the first occurence of the search string
            range1 = [res rangeOfString: search ];
            if ( range1.location == NSNotFound ) { break; }
            
            // Set the search string for the closing part of the <link/>
            [search setString:@"\"/>"];

            // Find the first occurence of the closing tag in the response AFTER the first range
            range2 = [res rangeOfString: search options:(NSStringCompareOptions)0 range: NSMakeRange( range1.location +  range1.length, SQL_ROW_BUFFER ) ];
            
            // Get number of characters in selection from vi: <g ctrl-g>
            // The location refers to the first character of the match, we want to extract the
            // data in between [ location1+length, location2 ] 
            
            // Note: NSMakeRange(start,length)
            NSRange dataRange = NSMakeRange( range1.location + range1.length , range2.location - (range1.location + range1.length)  );
            
            // Allocate a new object for each string
            NSMutableString* tagData_ = [[NSMutableString alloc] init];
            
            // Insert the data substring into tagData_
            [tagData_  insertString: [res substringWithRange: dataRange ] atIndex:0  ];
            
            // Append a \0 character and add it to the array
            [tagData_ insertString: [[NSString alloc] initWithCharacters:(const unichar*)"\0" length:1 ] atIndex: dataRange.length ];
            [ tagData addObject: tagData_ ];

            // Remove all data in the response up until the end of range2 </tag>
            [ res deleteCharactersInRange: NSMakeRange(0,range2.location + range2.length) ];
        }
    }

}

//*************** MISC *********************//

NSMutableString* sanitize(NSMutableString* str)
// Note that the SQL statements enclose titles in "..." meaning " is strcitly illegal in input
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[’“”]" options:NSRegularExpressionCaseInsensitive error:NULL];
    [regex replaceMatchesInString: str options:0 range:NSMakeRange(0, str.length) withTemplate:@"'"];

    str = (NSMutableString*)[str stringByReplacingOccurrencesOfString: @ALL_TITLE withString: @""];
    str = (NSMutableString*)[str stringByReplacingOccurrencesOfString: @"\"" withString: @"'"];
    str = (NSMutableString*)[str stringByReplacingOccurrencesOfString: @"&amp;" withString: @"&"];
    str = (NSMutableString*)[str stringByReplacingOccurrencesOfString: @"&quot;" withString: @"'"];
    str = (NSMutableString*)[str stringByReplacingOccurrencesOfString: @"…" withString: @"..."];

    for (int i=0; i < str.length; i++)
    // Remove all non standard ASCII characters
    {  
        if ([str characterAtIndex:i] > 127 || [str characterAtIndex:i] < 32)  
        { 
            [str deleteCharactersInRange:NSMakeRange(i,1)]; i--; 
        }  
    }
    
    return str;
}

int getIndexByNameAndOwnerId(NSMutableArray* videos, NSString* title, int owner_id )
{
    for (int i=0; i<videos.count; i++)
    { 
        if( [ [[videos objectAtIndex:i ] title] isEqual: title] && [[videos objectAtIndex:i ] owner_id] == owner_id  ) 
        {  
            return i;  
        } 
    } 
    return -1;
}


//*************** SQLITE CALLBACKS ********************//

static int callbackVideoObjects(void* context, int columnCount, char** columnValues, char** columnNames)
{
    // The context object passed is an NSMutableArray to which we add a Video object for each iteration
    // called from sqlite3_exec()
    // Note that we never import the timestamp at columnValues[0]

    Video* video = [[Video alloc] init];
    video.title = [[ NSString alloc ] initWithCString: columnValues[1] encoding:NSUTF8StringEncoding];  
    //NSLog(@"callbackVideo(): %@", video.title);

    // Note that the boolean attribute is given as a string and thus can't simply be casted 
    video.viewed = false;
    //NSLog(@"Strcmp: %s [ret=%d]", columnValues[2], strcmp("0",columnValues[2]));
    if ( strcmp("0",columnValues[2])!=0 ){ video.viewed = true; }

    video.owner_id = atoi(columnValues[3]); 
    video.link = [[ NSString alloc ] initWithCString: columnValues[4] encoding:NSUTF8StringEncoding];  

    [(__bridge NSMutableArray*)context addObject: video];
    return 0;
}

static int callbackChannelObjects(void* context, int columnCount, char** columnValues, char** columnNames)
{
    Channel* channel = [[Channel alloc] init];
    channel.id = atoi(columnValues[0]); 
    channel.name = [[ NSString alloc ] initWithCString: columnValues[1] encoding:NSUTF8StringEncoding];  
    channel.rssLink = [[ NSString alloc ] initWithCString: columnValues[2] encoding:NSUTF8StringEncoding];; 
    
    // Initalise every channel object with -1 viewed videos to indicate that the channel hasn't been updated
    // This attribute isn't saved in the database and is kept in sync with the most recent RSS update which
    // is saved in the channelCache attribute in the ViewController
    channel.unviewedCount = -1;

    //NSLog(@"Search found: %@", channel);
    [(__bridge NSMutableArray*)context addObject: channel];
    return 0;

}

static int callbackColumnValues(void* context, int columnCount, char** columnValues, char** columnNames)
// COPYS the columnValues into the result paramater in sqlite3_exec()
// We can't simply reassign the pointer since the columnValues object gets freed after exiting the handler
{
    for (int i=0; i < columnCount; i++)
    { 
        strncpy( ((char**)context)[i], columnValues[i], SQL_ROW_BUFFER );
    } 

    return 0; 
}

static int callbackGetTitle(void* context, int columnCount, char** columnValues, char** columnNames)
{
    strncpy( (char*)context, columnValues[0], SQL_ROW_BUFFER );
    return 0;
}

static int callbackPrint(void* context, int columnCount, char** columnValues, char** columnNames)
{
    for (int i = 0; i < columnCount; i++) 
    {
        NSLog(@"column[%d] = %s = %s", i, columnNames[i], columnValues[i] ? columnValues[i] : "NULL");
    }
    return 0;
}

static int callbackImportRSS(void* context, int columnCount, char** columnValues, char** columnNames) 
// https://stackoverflow.com/questions/38825480/c-mfc-sqlite-sqlite3-exec-callback
{
    Handler* handler = (__bridge Handler*)context;

    // Delegate callback to class member implementation
    return [handler handleRSS: columnValues];
}