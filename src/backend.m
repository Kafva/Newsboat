#include "backend.h"
// Global function can be defined and called with default C syntax

// Nearly all methods should act upon the created object and not the entire class
// Class methods:    +(void) foo {}
// Instance methods: -(void) foo {}

@implementation Channel : NSObject
    
    // Create a getter/setter for the attributes which don't inherit from NSObject
    @synthesize unviewedCount;
   
   -(NSString*) description { return [NSString stringWithFormat:@"<Channel:%p> %@", self, self.name ]; }
@end

@implementation Video : NSObject
   -(NSString*) description { return [NSString stringWithFormat:@"<Video:%p> title: %@", self, self.title ]; }
    -(void)toggleViewedAttr { self.viewed = !self.viewed; }
@end

//--------------------------------------------------//

@implementation DBHandler : NSObject

    // Constructor
    -(id) init 
    { 
        self.dbPath = @"";
        self.db = nil;
        return self;
    }

    -(id) initWithDB: (NSString*)dbPath
    // Alternative constructor
    {
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
        else { self.db = db_; }

        return ret;
    }

    -(int) closeDatabase
    {
        if ( self.db ){ return sqlite3_close(self.db); } else { return 0; }
    }
    
    -(int) queryStmt: (const char*)stmt
    {
        char* err_msg;

        // The callback function prints the result of the query
        int ret = sqlite3_exec( self.db , stmt, callbackPrint, NULL, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        return ret;
    }

    -(int) addVideo: (const char* )timestamp title:(const char* )title owner_id:(const char*)owner_id link:(const char*) link
    // Called in `handleRSS()`
    {
        // The method will throw an error when encountering already added videos due to the UNIQUE
        // constraint. When adding new videos the oldest one should be deleted if the count exceeds VIDEOS_PER_CHANNEL

        char* err_msg;
        char* delete_title = malloc(sizeof(char)*SQL_ROW_BUFFER);

        char** results = malloc(sizeof(char*)*(VIDEOS_PER_CHANNEL+1));
        for (int i=0; i < VIDEOS_PER_CHANNEL+1; i++) { results[i] = malloc(sizeof(char)*SQL_ROW_BUFFER); }

        // The IGNORE keyword will inhibit errors from not adhearing to the UNIQUE constraints
        // and instead simply ignore the perticular INSERT statement
        const char* stmt = [[NSString stringWithFormat: @"INSERT OR IGNORE INTO `Videos` (`timestamp`, `title`, `viewed`, `owner`, `link`) VALUES (DATE(\"%s\"), \"%s\", FALSE , %s, \"%s\"); ",timestamp, title, owner_id, link ] cStringUsingEncoding:NSUTF8StringEncoding];
        int ret = sqlite3_exec( self.db , stmt, NULL, NULL, &err_msg );
        
        if ( ret == SQLITE_OK  )
        // Only go through the process of potentially removing an old video if the insertion was successful
        {
            stmt = [[NSString stringWithFormat: @"SELECT COUNT(*) FROM `Videos` WHERE owner = %s; ",owner_id] cStringUsingEncoding:NSUTF8StringEncoding];

            if ( sqlite3_exec( self.db , stmt, callbackColumnValues, (void*)results, &err_msg ) == SQLITE_OK )
            // "The 4th argument to sqlite3_exec() is relayed as the first argument ot the callback()"
            // Check if the row count for the Channel exceeds VIDEOS_PER_CHANNEL
            {
                //NSLog(@"ROWS: %d , %d", atoi(results[0]), VIDEOS_PER_CHANNEL);

                if ( atoi(results[0]) > VIDEOS_PER_CHANNEL )
                // If so find the oldest video(s) and delete it/them from the channel in question
                {
                    stmt = [[NSString stringWithFormat: @"SELECT `title` FROM `Videos` WHERE (`title`,`owner`) IN (SELECT `title`,`owner` FROM `Videos` WHERE `owner` = %s ORDER BY `timestamp` ASC LIMIT %d);", owner_id,  atoi(results[0]) - VIDEOS_PER_CHANNEL ] cStringUsingEncoding:NSUTF8StringEncoding];
                    if ( sqlite3_exec(self.db, stmt, callbackGetTitle, (void*)delete_title, &err_msg) != SQLITE_OK ) {  NSLog(@"%s", err_msg);  }
                    
                    stmt = [[NSString stringWithFormat: @"DELETE FROM `Videos` WHERE (`title`,`owner`) IN (SELECT `title`,`owner` FROM `Videos` WHERE `owner` = %s ORDER BY `timestamp` ASC LIMIT %d);", owner_id,  atoi(results[0]) - VIDEOS_PER_CHANNEL ] cStringUsingEncoding:NSUTF8StringEncoding];
                    if ( sqlite3_exec(self.db, stmt, NULL,NULL, &err_msg) == SQLITE_OK ) { NSLog(@"Successfully deleted: \"%s\" from owner_id:%s", delete_title, owner_id  ); }
                    else {  NSLog(@"%s", err_msg);  }

                }
                
            }
            else {  NSLog(@"%s", err_msg);  }    
        }
        else {  NSLog(@"%s", err_msg);  }
        
        for (int i=0; i < VIDEOS_PER_CHANNEL+1; i++) { free(results[i]); }
        free(results);
        free(delete_title);

        return ret;
    }
    
    -(int) importRSS: (const char*)channel
    {
        char* stmt = malloc(sizeof(char)*VARCHAR_SIZE); 
        sprintf(stmt, "SELECT `id`,`rssLink` FROM `Channels` WHERE `name` = '%s';", channel ); 
        char* err_msg;
        
        // The callback function works as a lambda function in that each row in
        // the result is processed individually
        
        // Fetch each channelId and its corresponding RSS link with the callback function
        // handling the addition of videos via a request for the RSS Feed for each channel
        // Note that the callback in turn calls a member function of the DBHandler (possible by passing self as result)
        int ret = sqlite3_exec( self.db , stmt, callbackImportRSS,  (__bridge void *)self, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        
        free(stmt);
        return ret;
    }

    -(int) importRSS
    {
        char* stmt = "SELECT `id`,`rssLink` FROM `Channels`;";
        char* err_msg;

        // The callback function works as a lambda function in that each row in
        // the result is processed individually
        
        // Fetch each channelId and its corresponding RSS link with the callback function
        // handling the addition of videos via a request for the RSS Feed for each channel
        // Note that the callback in turn calls a member function of the DBHandler (possible by passing self as result)
        int ret = sqlite3_exec( self.db , stmt, callbackImportRSS,  (__bridge void *)self, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        return ret;
    }

    -(int)getVideosFrom: (const char*)channel count:(int)count
    {
        char* err_msg;
        char* stmt = malloc(sizeof(char)*VARCHAR_SIZE); 
        sprintf(stmt, "SELECT * FROM `Videos` WHERE `owner` = (SELECT `id` FROM `Channels` WHERE `name` LIKE '%s') ORDER BY `timestamp` DESC LIMIT %d;", channel, count); 

        // The callback function prints the result of the query
        int ret = sqlite3_exec( self.db , stmt, callbackPrint, NULL, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        free(stmt);
        return ret;

    }

    -(int) getVideosFrom: (const char*)channel count:(int)count videos:(NSMutableArray*) videos
    {
        char* err_msg;
        char* stmt = malloc(sizeof(char)*VARCHAR_SIZE); 

        // NOTE that if channels have similar names the wrong vidoes could be returned with a greedy RegEx
        sprintf(stmt, "SELECT * FROM `Videos` WHERE `owner` = (SELECT `id` FROM `Channels` WHERE `name` LIKE \"%s\") ORDER BY `timestamp` DESC LIMIT %d;", channel, count); 

        // The callback function creates Video objects which are returned to the paramater passed to the method 
        int ret = sqlite3_exec( self.db , stmt, callbackVideoObjects, (__bridge void*)videos, &err_msg );
        //ret = sqlite3_exec( self.db , stmt, callbackPrint, NULL, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        
        free(stmt);
        return ret;

    }

    -(int) handleRSS: (char**)columnValues
    // Import the most recent videos (not already in the database) from each channel given from the RSS feed
    // The function is ran once per output row from the sqlite3_exec() statement
    {
        RequestHandler* re = [[RequestHandler alloc] init];
        char* channelId = columnValues[0];

        NSString* rssLink = [[NSString alloc] initWithCString: columnValues[1] encoding:NSUTF8StringEncoding];
                
        [re httpRequest: rssLink  success: ^(NSString* response) 
            { 
                // Fetch the titles and timestamps for the perticular feed
                // the first entry will be the channel name and its creation date
                NSMutableArray* titles = [[NSMutableArray alloc] init];
                NSMutableArray* timestamps = [[NSMutableArray alloc] init];
                NSMutableArray* links = [[NSMutableArray alloc] init];
                
                [re getDataFromTag:@"title" response:response tagData:titles  ];
                [re getDataFromTag:@"published" response:response tagData:timestamps  ];
                [re getHrefFromTag:@"link" response:response tagData:links  ];

                for (int i=1; i < titles.count; i++)
                {
                    [self addVideo: [ timestamps[i] cStringUsingEncoding:NSUTF8StringEncoding ] title: [titles[i] cStringUsingEncoding:NSUTF8StringEncoding] owner_id:channelId link: [links[i] cStringUsingEncoding:NSUTF8StringEncoding]];
                }

            }  
            failure: ^(NSError* error)
            { NSLog(@"Error: %@", error); }  
        ];

        return 0;
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

    -(int) toggleViewedVideos: (NSString*)title owner_id:(int)owner_id
    // Toggle the viewed attribute for the video matching the given title and owner_id
    {
        char* err_msg;

        // Due to issues with escaping single quotes the name is enclosed in double quotes
        const char* stmt = [[NSString stringWithFormat: @"UPDATE `Videos` SET `viewed` = NOT `viewed` WHERE `owner` = %d AND `title` = \"%@\" ",owner_id, title ] cStringUsingEncoding:NSUTF8StringEncoding];
        //NSLog(@"STATEMENT: %s", stmt);
        
        int ret = sqlite3_exec( self.db , stmt, NULL, NULL, &err_msg );
        
        if (ret != SQLITE_OK) {  NSLog(@"%s", err_msg);  }
        return ret;
    }


@end

@implementation RequestHandler

    -(void) httpRequest: (NSString*) url  success: (void (^)(NSString *response)) success failure: (void(^)(NSError* error)) failure
    // The function takes two blocks of code as input arguments
    // The success() argument takes the response as an argument and enables us to access the
    // reply outside of the completionHandler().
    
    // Async https://stackoverflow.com/questions/26174692/how-to-get-data-from-blocks-using-nsurlsession
    // Blocks: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html
    // Web requests: https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory?language=objc
    {
        // Create a sharedSession object
        NSURLSession *session = [NSURLSession sharedSession];
        
        // Call the 'dataTaskWithURL' method of the session object ot fetch data
        // the 'resume' is called on the dataTaskWithURL output to start the task
        // '^' denotes a block, a portion of code that can be treated as a value
        // similiar to the use of 'lambda'
        
        NSURLSessionDataTask* task = [session dataTaskWithURL:[NSURL URLWithString:url] 
        completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error)
        {
            if (error.code == 0)
            {
                // Call the success block with the reply in string format as an argument
                success( [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]  ); 
            }
            else {  failure( error ); }
        }];

        [task resume];

        while (task.state == 0)
        // Ugly hack to wait for request to complete
        {
            // NSURLSessionTaskStateRunning = 0,                     /* The task is currently being serviced by the session */
            // NSURLSessionTaskStateCanceling = 2,                   /* The task has been told to cancel.  The session will receive a URLSession:task:didCompleteWithError: message. */
            // NSURLSessionTaskStateCompleted = 3,                   /* The task has completed and the session will receive no more delegate notifications */
            
            usleep(1000000);
            //NSLog(@"State: %ld", task.state);
        }

    }

    -(void) getDataFromTag: (NSString*)tag response:(NSString*)response tagData:(NSMutableArray*)tagData
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

    -(void) getHrefFromTag: (NSString*) tag response: (NSString*) response tagData: (NSMutableArray*)tagData;
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


@end

//---------------MISC---------------------//

NSMutableString* sanitize(NSMutableString* str)
{
    //NSLog(@"Before NSsan: %@", str);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\"'’“”]" options:NSRegularExpressionCaseInsensitive error:NULL];
    [regex replaceMatchesInString: str options:0 range:NSMakeRange(0, str.length) withTemplate:@"'"];

    str = (NSMutableString*)[str stringByReplacingOccurrencesOfString: @"&amp;" withString: @"&"];
    str = (NSMutableString*)[str stringByReplacingOccurrencesOfString: @"&quot;" withString: @"\""];
    str = (NSMutableString*)[str stringByReplacingOccurrencesOfString: @"…" withString: @"..."];

    // Remove all non standard ASCII characters
    for (int i=0; i < str.length; i++){  if ([str characterAtIndex:i] > 127 || [str characterAtIndex:i] < 32)  { [str deleteCharactersInRange:NSMakeRange(i,1)]; }  }
    
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

//--------------SQLITE CALLBACKS------------------//

static int callbackVideoObjects(void* context, int columnCount, char** columnValues, char** columnNames)
{
    // The context object passed is an NSMutableArray to which we add a Video object for each iteration
    // called from sqlite3_exec()
    // Note that we never import the timestamp at columnValues[0]

    Video* video = [[Video alloc] init];
    video.title = [[ NSString alloc ] initWithCString: columnValues[1] encoding:NSUTF8StringEncoding];  

    // Note that the boolean attribute is given as a string and thus can't simply be casted 
    video.viewed = false;
    //NSLog(@"Strcmp: %s [ret=%d]", columnValues[2], strcmp("0",columnValues[2]));
    if ( strcmp("0",columnValues[2])!=0 ){ video.viewed = true; }

    video.owner_id = atoi(columnValues[3]); 
    video.link = [[ NSString alloc ] initWithCString: columnValues[4] encoding:NSUTF8StringEncoding];  

    //NSLog(@"callbackVideo(): %@", video);
    [(__bridge NSMutableArray*)context addObject: video];
    return 0;
}

static int callbackChannelObjects(void* context, int columnCount, char** columnValues, char** columnNames)
{
    Channel* channel = [[Channel alloc] init];
    channel.id = atoi(columnValues[0]); 
    channel.name = [[ NSString alloc ] initWithCString: columnValues[1] encoding:NSUTF8StringEncoding];  
    channel.rssLink = [[ NSString alloc ] initWithCString: columnValues[2] encoding:NSUTF8StringEncoding];; 
    channel.channelLink = [[ NSString alloc ] initWithCString: columnValues[3] encoding:NSUTF8StringEncoding];  
    
    // Initalise every channel object with -1 viewed videos to indicate that the channel hasn't been updated
    channel.unviewedCount = -1;

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
    DBHandler* handler = (__bridge DBHandler*)context;

    // Delegate callback to class member implementation
    return [handler handleRSS: columnValues];
}
