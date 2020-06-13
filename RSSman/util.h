#include <Foundation/Foundation.h>

@interface RequestHandler : NSObject

    // https://medium.com/@dsrijan/objective-c-properties-901e8a1f82ac
    // The 'nonatomic' keyword denotes that we do not need to worry about race condition ('atomic' is default)
    // The 'assign'/'weak' keyword creates a mutator (setName) and getter (name) for the property
    // The 'retain'/'strong' keyword avoids the attribute being deallocated until the parent object is

    // (Methods in ObjC are public by default but instance variables are private)
    // NOTE that we still need to give a @synthesize decleration for the attribute
    // in the implementation for the methods to get the names described above

    // We utilise 'strong' to keep the data recieved from the request(s)    
    @property (strong,nonatomic) NSString* response;
    
    // Mehtod decleration
    -(void) httpRequest: (NSString*) url, (void (^)(NSString *response)) success, (void(^)(NSError* error)) failure ;

    -(NSMutableArray*) getDataFromTag:(NSString*)tag;

@end