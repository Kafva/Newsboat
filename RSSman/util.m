#include "util.h"
// Global function can be defined and called with default C syntax

@implementation RequestHandler

    @synthesize response;

    // Blocks work similarly to functions and 

    -(void) httpRequest: (NSString*) url,  (void (^)(NSString *response)) success, (void(^)(NSError* error)) failure
    // Async https://stackoverflow.com/questions/26174692/how-to-get-data-from-blocks-using-nsurlsession
    // Both sets the attribute and returns the string
    // Blocks: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/WorkingwithBlocks/WorkingwithBlocks.html
    {
        // Create a sharedSession object
        NSURLSession *session = [NSURLSession sharedSession];
        
        // Call the 'dataTaskWithURL' method of the session object ot fetch data
        // the 'resume' is called on the dataTaskWithURL output to start the task
        // '^' denotes a block, a portion of code that can be treated as a value
        // similiar to the use of 'lambda'

        [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler: 
            ^(NSData *data, NSURLResponse *response, NSError *error)
            {
                //NSLog(@"error: %ld\n", error.code);
                
                if (error.code == 0)
                {
                    // Call the implicitly created setter method (same as assigning to self.res)
                    //[ self setRes: [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] ];
                    self.response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]; 
                    
                    //NSLog(@"This: %@", self.response );
                }
            }
        ] resume];

        return self.response; 
    }

    -(NSMutableArray*) getDataFromTag:(NSString*)tag
    {
        NSLog(@"lol %@", self.response);
        if (self.response != nil)
        {
            NSMutableArray* tagData = [[NSMutableArray alloc] init];
            unichar uniFoundTag[256]; 

            NSMutableString* fullTag = [[NSMutableString alloc] init];
            [fullTag setString:@"<>"];
            [fullTag insertString: tag atIndex:(NSUInteger)1 ];

            NSRange range = [self.response rangeOfString: fullTag ];
            [self.response getCharacters: uniFoundTag range:range ];
            
            NSString* foundTag = [NSString stringWithUTF8String:uniFoundTag];

            NSLog(@"Found %@", tag);
            NSLog(@"Found %s", foundTag);
            
            if ( foundTag == tag )
            {
                NSLog(@"AAA Found %@", tag);
            }

        }

        return nil;
    }



//    -(void)getJsonResponse:(NSString *)urlStr success:(void (^)(NSDictionary *responseDict))success failure:(void(^)(NSError* error))failure
//    {
//        NSURLSession *session = [NSURLSession sharedSession];
//        NSURL *url = [NSURL URLWithString:urlStr];   
//
//        // Asynchronously API is hit here
//        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
//                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) 
//                                                {            
//                                                    NSLog(@"%@",data);
//                                                    if (error)
//                                                        failure(error);
//                                                    else {                                               
//                                                        NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                                        NSLog(@"%@",json);
//                                                        success(json);                                               
//                                                    }
//                                                }];
//        [dataTask resume];    // Executed First
//    }
//
//[self getJsonResponse:@"Enter your url here" success:^(NSDictionary *responseDict) 
//{   
//        NSLog(@"%@",responseDict);
//} failure:^(NSError *error) {
//        // error handling here ... 
//}];

@end