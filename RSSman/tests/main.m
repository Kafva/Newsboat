#import "../util.h"
#import <time.h>

int TEST=4;


int main (int argc, char * argv[])
{
    srand(time(NULL));

    if (argc == 2){ TEST = atoi(argv[1]); }

	@autoreleasepool 
	{
		if (TEST == 1)
        // Blocks
        {
            NSString* str1=@"wow1";
            NSString* str2=@"wow2";

            // A block can be assigned to a variable and executed like any other function
            // The righthand side specifies the parameters after ^
            // The type for the block pointer  (^printMessage) reflects the return value from the block
            NSString* (^printMessage)(NSString*, NSString*) = ^(NSString* str1, NSString* str2) { NSLog (@"%@, %@", str1, str2); return @"return value"; } ;
            NSString* str = printMessage (str1,str2);
            NSLog(@"%@",str);
        }
        else if (TEST == 2)
        // XML fetching
        {
            NSString* url = @"https://www.youtube.com/feeds/videos.xml?channel_id=UCZaT_X_mc0BI-djXOlfhqWQ";
            //NSString* url = @"https://www.youtube.com/feeds/videos.xml?channel_id=UCtGoikgbxP4F3rgI9PldI9g"; 
            NSString* tag = @"title";
            RequestHandler* re = [[RequestHandler alloc] init];
        
            NSMutableArray* tagData = [[NSMutableArray alloc] init];

            [re httpRequest: url  success: ^(NSString* response) { [re getDataFromTag:tag response:response tagData:tagData  ]; }  failure: ^(NSError* error){ NSLog(@"Error: %@", error); }  ];

            NSLog(@"---- Content of <%@>...</%@>  ----", tag, tag);
            for ( NSMutableString* str in tagData )
            {
                NSLog(@"\t%@",str);
            }
            
            NSLog(@"-------------------------");

            NSMutableArray* dates = [[NSMutableArray alloc] init];
            tag = @"published";
            [re httpRequest: url  success: ^(NSString* response) { [re getDataFromTag:tag response:response tagData:dates  ]; }  failure: ^(NSError* error){ NSLog(@"Error: %@", error); }  ];
            NSLog(@"---- Content of <%@>...</%@>  ----", tag, tag);
            for ( NSMutableString* str in dates )
            {
                NSLog(@"\t%@",str);
            }



            
        }
        else if (TEST == 3)
        // Conccurency execution with dispatch queues
        {
            //NSString* url = @"https://www.youtube.com/feeds/videos.xml?channel_id=UCtGoikgbxP4F3rgI9PldI9g"; 
            //RequestHandler* re = [[RequestHandler alloc] init];
            //NSMutableArray* tagData = [[NSMutableArray alloc] init];
            
            //// A program per default has 4 global dispatch queues
            //// Begin by creating an object to access one with default priorty for tasks
            
            //dispatch_queue_t queue = dispatch_queue_create("com.example.MyCustomQueue", NULL);
            //NSURLSession *session = [NSURLSession sharedSession];
            
            //dispatch_sync(queue,  
            //            ^{  
            //                [re httpRequest: url  
            //                    success: ^(NSString* response) { NSLog(@"response!");  } 
            //                    failure: ^(NSError* error){ NSLog(@"Error: %@", error); }  ];
            //                
            //                
            //            });
            
            //printf("Here\n");

            //dispatch_sync(queue, ^{
            //    printf("Do some more work here. 2\n");
            //});


            //printf("Both blocks have completed.\n");


            //dispatch_queue_t myCustomQueue;
            //myCustomQueue = dispatch_queue_create("com.example.MyCustomQueue", NULL);
            
            //dispatch_async(myCustomQueue, ^{
            //    printf("Do some work here. 1\n");
            //});
            
            //printf("The first block may or may not have run.\n");
            
            //dispatch_sync(myCustomQueue, ^{
            //    printf("Do some more work here. 2\n");
            //});


            //printf("Both blocks have completed.\n");


        }
        else if (TEST == 4)
        // SQL lite
        {   
            // Note that the sqlite3 library must be manually included with -lsqlite3
            // https://stackoverflow.com/questions/59525583/xcode-build-error-implicit-declaration-of-function-sqlite3-key-is-invalid-i

            // https://stackoverflow.com/questions/28279701/ios-sqlite-misuse-error-code-21


            NSString* dbPath = [[NSString alloc] initWithCString: DB_PATH encoding:NSASCIIStringEncoding];
            DBHandler* handler = [[DBHandler alloc] initWithDB: dbPath];
            //NSLog(@"This: %s", [ handler.dbPath cStringUsingEncoding:NSASCIIStringEncoding]);
            
            [handler openDatabase];

            //char* timestamp = "DATE(\"2015-12-18T15:33:22+00:00\")";
            //char title[256]; sprintf(title, "uWu%d", rand() % 2000);
            //char* owner = "Contra";
            //[handler addVideo: timestamp title:title owner:owner];
            
            //char* stmt = "SELECT * FROM Videos;"; 
            //[handler queryStmt: stmt];

            [handler importRSS];
            
            //char* stmt = "SELECT * FROM Videos;"; 
            //[handler queryStmt: stmt];

            if ( handler.db ){ sqlite3_close( handler.db); }
        }

	}

	return 0;
} 



