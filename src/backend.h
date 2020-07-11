#import <Foundation/Foundation.h>
#import <stdlib.h>
#import <sqlite3.h>

#define VIDEOS_PER_CHANNEL 8
#define VARCHAR_SIZE 255
#define SQL_ROW_BUFFER 400
#define ALL_TITLE "*"

#define TEST_DB_PATH "/Users/jonas/XcodeX/iPK/Newsboat/rss.db"
#define DB_PATH "/Documents/rss.db"

@interface Channel : NSObject
   @property (assign,nonatomic) int id;
   @property (assign,nonatomic) int unviewedCount;
   @property (strong,nonatomic) NSString* name;
   @property (strong,nonatomic) NSString* rssLink;
   @property (strong,nonatomic) NSString* channelLink;
   -(NSString*) description;

@end

@interface Video : NSObject
   // Important for NSObject properties to have a strong property so that they aren't freed
    @property (strong,nonatomic) NSString* title;
    @property (strong,nonatomic) NSString* link;  
    @property (assign,nonatomic) bool viewed;
    @property (assign,nonatomic) int owner_id;

   // The function called when printing NSObjects with NSLog()
   -(NSString*) description;
   -(void) setAllViewedAttr: (BOOL) viewed;
@end

//**********************************************************//

@interface DBHandler : NSObject
    
    @property (strong, nonatomic) NSString* dbPath;
    @property (nonatomic) sqlite3* db;

    //*************** BASIC ****************//
    -(id) initWithDB: (NSString*)dbPath;
    -(int) openDatabase;
    -(int) closeDatabase;
    -(int) queryStmt: (const char*)stmt;
    
    //************** Utility *******************//
    -(int) getChannels: (NSMutableArray*)channels;
    -(int) getChannels: (NSMutableArray*)channels name:(NSString*)name;
    -(int) getVideosFrom: (const char*)channel count:(int)count videos:(NSMutableArray*) videos;
    -(int) setAllViewedInDatabase: (int)owner_id;
    -(int) toggleViewedInDatabase: (NSString*)title owner_id:(int)owner_id;

    //*************** Adding Videos ****************//
    -(int) importRSS: (const char*)channel;
    -(int) handleRSS: (char**)columnValues;
    -(int) addVideo: (const char* )timestamp title:(const char* )title owner_id:(const char*)owner_id link:(const char*) link;

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
    -(void) httpRequest: (NSString*) url success:(void (^)(NSString *response)) success failure:(void (^)(NSError* error)) failure; 
    -(void) getDataFromTag: (NSString*) tag  response: (NSString*) response  tagData: (NSMutableArray*)tagData;
    -(void) getHrefFromTag: (NSString*) tag response: (NSString*) response tagData: (NSMutableArray*)tagData;

@end


//*************** MISC *********************//

NSMutableString* sanitize(NSMutableString* str);
int getIndexByNameAndOwnerId(NSMutableArray* videos, NSString* title, int owner_id );

//*************** SQLITE CALLBACKS ********************//

static int callbackVideoObjects(void* context, int columnCount, char** columnValues, char** columnNames);
static int callbackGetTitle(void* context, int columnCount, char** columnValues, char** columnNames);
static int callbackChannelObjects(void* context, int columnCount, char** columnValues, char** columnNames);
static int callbackColumnValues(void* context, int columnCount, char** columnValues, char** columnNames);
static int callbackPrint(void* context, int columnCount, char** columnValues, char** columnNames);
static int callbackImportRSS(void* context, int columnCount, char** columnValues, char** columnNames);
