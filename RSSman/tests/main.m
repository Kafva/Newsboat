#import "../util.h"
#import <stdlib.h>

int TEST=2;


int main (int argc, char * argv[])
{
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
            NSString* url = @"https://www.youtube.com/feeds/videos.xml?channel_id=UCtGoikgbxP4F3rgI9PldI9g"; 
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


        }

	}

	return 0;
} 

