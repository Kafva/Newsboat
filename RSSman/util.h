#include <Foundation/Foundation.h>
#import <sqlite3.h>
#include <stdlib.h>

#define VIDEOS_PER_CHANNEL 0
#define SQL_ROW_BUFFER 255
#define DB_PATH "/Users/jonas/XcodeX/iPK/RSSman/rss.db" 

@interface DBHandler : NSObject
    
    @property (strong, nonatomic) NSString *dbPath;
    @property (nonatomic) sqlite3* db;

    -(id) initWithDB: (NSString*)dbPath;
    -(int) openDatabase;
    -(int) execStmt: (const char*)stmt;
    -(int) queryStmt: (const char*)stmt;
    
    -(int) addVideo: (const char* )timestamp title:(const char* )title owner_id:(const char*)owner_id;
    
    -(int) importRSS;
    -(int) handleRSS: (char**)columnValues;


@end

@interface RequestHandler : NSObject

    // https://medium.com/@dsrijan/objective-c-properties-901e8a1f82ac
    // The 'nonatomic' keyword denotes that we do not need to worry about race condition ('atomic' is default)
    // The 'assign'/'weak' keyword creates a mutator (setName) and getter (name) for the property
    // The 'retain'/'strong' keyword avoids the attribute being deallocated until the parent object is

    // (Methods in ObjC are public by default but instance variables are private)
    // NOTE that we still need to give a @synthesize decleration for the attribute
    // in the implementation for the methods to get the names described above

    // We utilise 'strong' to keep the data recieved from the request(s)    
    //@property (strong,nonatomic) NSString* response;
    
    // NOTE that ObjC doesn't have named parameters, success: and failure: simply extend the function name
    // with additional parameters
    -(void) httpRequest: 
        (NSString*) url 
        success:(void (^)(NSString *response)) success 
        failure:(void (^)(NSError* error)) failure; 

    -(void) getDataFromTag: (NSString*) tag   
        response: (NSString*) response   
        tagData: (NSMutableArray*)tagData;

@end

//-------------------------------------------------//

static int callbackColumnValues(void* context, int columnCount, char** columnValues, char** columnNames);
static int callbackPrint(void* context, int columnCount, char** columnValues, char** columnNames);
static int callbackImportRSS(void* context, int columnCount, char** columnValues, char** columnNames);

