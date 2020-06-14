#include "util.h"
// Global function can be defined and called with default C syntax

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
                
                //self.response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]; 
            }
            else {  failure( error ); }
        }];

        [task resume];
        NSLog(@"State: %ld", task.state);

        while (task.state == 0)
        // Ugly hack to wait for request to complete
        {
            // NSURLSessionTaskStateRunning = 0,                     /* The task is currently being serviced by the session */
            // NSURLSessionTaskStateCanceling = 2,                   /* The task has been told to cancel.  The session will receive a URLSession:task:didCompleteWithError: message. */
            // NSURLSessionTaskStateCompleted = 3,                   /* The task has completed and the session will receive no more delegate notifications */
            
            usleep(1000000);
            NSLog(@"State: %ld", task.state);
        }

    }

    -(void) getDataFromTag: (NSString*)tag response:(NSString*)response tagData:(NSMutableArray*)tagData
    {
        if (response != nil)
        {
            // Init an array of all the tag data
            NSMutableArray* tagData = [[NSMutableArray alloc] init];

            // Create the full tag: <tag>
            NSMutableString* fullTag = [[NSMutableString alloc] init];
            [fullTag setString:@"<>"];
            [fullTag insertString: tag atIndex:(NSUInteger)1 ];
            NSLog(@"tag1: %@", fullTag);

            // Find the first occurence of the fullTag in the response
            NSRange range1 = [response rangeOfString: fullTag ];
            
            // Create the full tag: </tag>
            [fullTag setString:@"</>"];
            [fullTag insertString: tag atIndex:(NSUInteger)2 ];
            NSLog(@"tag2: %@", fullTag);

            // Find the first occurence of the fullTag in the response
            NSRange range2 = [response rangeOfString: fullTag ];
            
            // Get number of characters in selection from vi: <g ctrl-g>

            // The location refers to the first character of the match, we want to extract the
            // data in between [ location1+length, location2 ] 
            NSLog(@"location1: %ld -- %ld", range1.location, range1.length);
            NSLog(@"location2: %ld -- %ld", range2.location, range2.length);
            NSRange dataRange = NSMakeRange( range1.location + range1.length , range2.location );
            NSLog(@"location2: %ld -- %ld", dataRange.location, dataRange.length);
            
            char* tagData_ = malloc(sizeof(char)*600); 

            for (int i= range1.location + range1.length; i < range2.location; i++)
            // Extract the data 
            {
                tagData_[  i   -   (range1.location + range1.length) ] = [response characterAtIndex:i ];
            }
            tagData_[range2.location] = '\0';

            NSLog(@"found data: %s", tagData_);
            free(tagData_);
        }
    }


@end