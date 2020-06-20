#include "util.h"
// Global function can be defined and called with default C syntax

// Nearly all methods should act upon the created object and not the entire class
// Class methods:    +(void) foo {}
// Instance methods: -(void) foo {}

@implementation DBHandler : NSObject
    // https://books.google.se/books?id=CvD72eK1H28C&pg=PA453&lpg=PA453&dq=sqlite+3+objc&source=bl&ots=4FGE2sYr-X&sig=ACfU3U2Y64vzZncjzKzhuV6yZOJA2cnlHg&hl=sv&sa=X&ved=2ahUKEwjvx-XOg4fqAhWHwMQBHYBaA4EQ6AEwCXoECAkQAQ#v=onepage&q=sqlite%203%20objc&f=false

    -(id) init
    // Constructor
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

        int ret = sqlite3_open( [self.dbPath cStringUsingEncoding:NSASCIIStringEncoding ], &db_ );
        if ( ret != SQLITE_OK  )
        {
            NSLog(@"Error opening database: %d", ret);
        }
        else { self.db = db_; }

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

    -(int) execStmt: (const char*)stmt
    {
        char* err_msg;
        int ret = sqlite3_exec( self.db , stmt, NULL, NULL, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        return ret;
    }

    -(int) addVideo: (const char* )timestamp title:(const char* )title owner_id:(const char*)owner_id
    {
        // The method will throw an error when encountering already added videos due to the UNIQUE
        // constraint. When adding new videos the oldest one should be deleted if the count exceeds VIDEOS_PER_CHANNEL

        char* err_msg;

        char** results = malloc(sizeof(char)*(VIDEOS_PER_CHANNEL+1));
        for (int i=0; i < VIDEOS_PER_CHANNEL+1; i++) { results[i] = malloc(sizeof(char)*SQL_ROW_BUFFER); }

        char* stmt = [[NSString stringWithFormat: @"INSERT INTO `Videos` (`timestamp`, `title`,`viewed`,`owner`) VALUES (DATE(\"%s\"), \"%s\", 0 , %s); ",timestamp, title, owner_id] cStringUsingEncoding:NSASCIIStringEncoding];
        int ret = sqlite3_exec( self.db , stmt, NULL, NULL, &err_msg );
        
        if ( ret == SQLITE_OK  )
        // Only go through the process of potentially removing an old video if the insertion was successful
        {
            stmt = [[NSString stringWithFormat: @"SELECT COUNT(*) FROM `Videos` WHERE owner = %s; ",owner_id] cStringUsingEncoding:NSASCIIStringEncoding];

            if ( sqlite3_exec( self.db , stmt, callbackColumnValues, (void*)results, &err_msg ) == SQLITE_OK )
            // "The 4th argument to sqlite3_exec() is relayed as the first argument ot the callback()"
            // Check if the row count for the Channel exceeds VIDEOS_PER_CHANNEL
            {
                if ( atoi(results[0]) > VIDEOS_PER_CHANNEL )
                // If so find the oldest video(s) and delete it/them from the channel in question
                {
                    stmt = [[NSString stringWithFormat: @"DELETE FROM `Videos` WHERE (`title`,`owner`) IN (SELECT `title`,`owner` FROM `Videos` WHERE `owner` = %s ORDER BY `timestamp` ASC LIMIT %d);", owner_id,  atoi(results[0]) - VIDEOS_PER_CHANNEL ] cStringUsingEncoding:NSASCIIStringEncoding];
                    if ( sqlite3_exec(self.db, stmt, NULL,NULL, &err_msg) == SQLITE_OK ) { NSLog(@"Successfully deleted %d video(s) from owner_id:%s", atoi(results[0]) - VIDEOS_PER_CHANNEL, owner_id  ); }
                    else {  NSLog(@"%s", err_msg);  }
                }
                
            }
            else {  NSLog(@"%s", err_msg);  }    
        }
        else {  NSLog(@"%s", err_msg);  }
        
        for (int i=0; i < VIDEOS_PER_CHANNEL+1; i++) { free(results[i]); }
        free(results);

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
        int ret = sqlite3_exec( self.db , stmt, callbackImportRSS, self, &err_msg );
        
        if ( ret != SQLITE_OK  ){  NSLog(@"%s", err_msg);  }
        return ret;
    }

    -(int) handleRSS: (char**)columnValues
    // Import the most recent videos (not already in the database) from each channel given from the RSS feed
    // The function is ran once per output row from the sqlite3_exec() statement
    {
        RequestHandler* re = [[RequestHandler alloc] init];
        char* channelId = columnValues[0];

        if (0!=strcmp(channelId, "1")){ return 0; }

        NSString* rssLink = [[NSString alloc] initWithCString: columnValues[1] encoding:NSASCIIStringEncoding];
                
        [re httpRequest: rssLink  success: ^(NSString* response) 
            { 
                // Fetch the titles and timestamps for each feed
                // the first entry will be the channel name and its creation date
                NSMutableArray* titles = [[NSMutableArray alloc] init];
                NSMutableArray* timestamps = [[NSMutableArray alloc] init];
                
                [re getDataFromTag:@"title" response:response tagData:titles  ];
                [re getDataFromTag:@"published" response:response tagData:timestamps  ];

                [self addVideo: [ timestamps[1] cStringUsingEncoding:NSASCIIStringEncoding ] title: [titles[1] cStringUsingEncoding:NSASCIIStringEncoding] owner_id:channelId];
            }  
            failure: ^(NSError* error)
            { NSLog(@"Error: %@", error); }  
        ];

        return 0;
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
                success( [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]  ); 
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
                [ tagData addObject: tagData_ ];

                // Remove all data in the response up until the end of range2 </tag>
                [ res deleteCharactersInRange: NSMakeRange(0,range2.location + range2.length) ];
            }
        }
    }


@end

//--------------------------------------//

static int callbackColumnValues(void* context, int columnCount, char** columnValues, char** columnNames)
// COPYS the columnValues into the result paramater in sqlite3_exec()
// We can't simply reassign the pointer since the columnValues object gets freed after exiting the handler
{
    for (int i=0; i < columnCount; i++)
    { 
        strcpy( ((char**)context)[i], columnValues[i] );
    } 
    
    return 0; 
}

static int callbackPrint(void* context, int columnCount, char** columnValues, char** columnNames)
{
    for (int i = 0; i < columnCount; i++) 
    {
        printf("%s = %s\n", columnNames[i], columnValues[i] ? columnValues[i] : "NULL");
    }
    printf("\n");
    return 0;
}

static int callbackImportRSS(void* context, int columnCount, char** columnValues, char** columnNames) 
// https://stackoverflow.com/questions/38825480/c-mfc-sqlite-sqlite3-exec-callback
{
    DBHandler* handler = context;
    
    // Delegate callback to class member implementation
    return [handler handleRSS: columnValues];
}