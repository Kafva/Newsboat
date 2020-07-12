#import "../backend.h"
#import <time.h>

int TEST=1;

int main (int argc, char * argv[])
{
    if (argc == 2){ TEST = atoi(argv[1]); }

	@autoreleasepool 
	{
        if (TEST == 1)
        {
            Requester* re = [[Requester alloc] init];

            [re download];
        }
        else if ( TEST == 2)
        {
            //NSString* str1=@"wow1";
            //NSString* str2=@"wow2";

            //// A block can be assigned to a variable and executed like any other function
            //// The righthand side specifies the parameters after ^
            //// The type for the block pointer  (^printMessage) reflects the return value from the block
            //NSString* (^printMessage)(NSString*, NSString*) = ^(NSString* str1, NSString* str2) { NSLog (@"%@, %@", str1, str2); return @"return value"; } ;
            //NSString* str = printMessage (str1,str2);
            //NSLog(@"%@",str);

            //RequestHandler* re = [[RequestHandler alloc] init];
            char* channelId = "14";

            //NSString* rssLink = [[NSString alloc] initWithCString: "heeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA" encoding:NSUTF8StringEncoding];
            NSString* rssLink = [[NSString alloc] initWithCString: "https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA" encoding:NSUTF8StringEncoding];
            
            NSURLSession *session = [NSURLSession sharedSession];
            
            NSURLSessionDataTask* task = [session dataTaskWithURL:[NSURL URLWithString:rssLink] 
            completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error)
            {
                if (error.code == 0)
                {
                NSString* res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"Done");

                // Fetch the titles and timestamps for the perticular feed
                // the first entry will be the channel name and its creation date
                NSMutableArray* titles = [[NSMutableArray alloc] init];
                NSMutableArray* timestamps = [[NSMutableArray alloc] init];
                NSMutableArray* links = [[NSMutableArray alloc] init];
                
                getDataFromTag(@"title", res, titles);
                getDataFromTag(@"published", res, timestamps);
                getHrefFromTag(@"link", res, links);

                for (int i=1; i < titles.count; i++)
                {
                    NSLog(@"%@", titles[i]);
                    //[self addVideo: [ timestamps[i] cStringUsingEncoding:NSUTF8StringEncoding ] title: [titles[i] cStringUsingEncoding:NSUTF8StringEncoding] owner_id:channelId link: [links[i] cStringUsingEncoding:NSUTF8StringEncoding]];
                }
                
                //// Dispatch back on the main thread (mandatory for UI updates)
                // dispatch_async(dispatch_get_main_queue(), 
                // ^{

                // });
                }
                else { NSLog(@"Error: %ld", error.code); }
            }];

            [task resume];
            
            //while (task.state == 0)
            //// Ugly hack to wait for request to complete
            //{
            //    // NSURLSessionTaskStateRunning = 0,                     /* The task is currently being serviced by the session */
            //    // NSURLSessionTaskStateCanceling = 2,                   /* The task has been told to cancel.  The session will receive a URLSession:task:didCompleteWithError: message. */
            //    // NSURLSessionTaskStateCompleted = 3,                   /* The task has completed and the session will receive no more delegate notifications */
            //    
            //    usleep(1000000);
            //    NSLog(@"State: %ld", task.state);
            //}
            
            //[re httpRequest: rssLink  success: ^(NSString* response) 
            //    { 
            //        // Dispatch back on the main thread (mandatory for UI updates)
            //        dispatch_async(dispatch_get_main_queue(), 
            //        ^{
            //            NSLog(@"Done");
            //        });
            //        
            //        // Fetch the titles and timestamps for the perticular feed
            //        // the first entry will be the channel name and its creation date
            //        NSMutableArray* titles = [[NSMutableArray alloc] init];
            //        NSMutableArray* timestamps = [[NSMutableArray alloc] init];
            //        NSMutableArray* links = [[NSMutableArray alloc] init];
            //        
            //        [re getDataFromTag:@"title" response:response tagData:titles  ];
            //        [re getDataFromTag:@"published" response:response tagData:timestamps  ];
            //        [re getHrefFromTag:@"link" response:response tagData:links  ];

            //        for (int i=1; i < titles.count; i++)
            //        {
            //            NSLog(@"%@", titles[i]);
            //            //[self addVideo: [ timestamps[i] cStringUsingEncoding:NSUTF8StringEncoding ] title: [titles[i] cStringUsingEncoding:NSUTF8StringEncoding] owner_id:channelId link: [links[i] cStringUsingEncoding:NSUTF8StringEncoding]];
            //        }

            //    }  
            //    failure: ^(NSError* error)
            //    { NSLog(@"Error: %@", error); }  
            //];

        }

        



    }
	return 0;
} 



