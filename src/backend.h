#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define VIDEOS_PER_CHANNEL 8
#define VARCHAR_SIZE 255
#define SQL_ROW_BUFFER 400
#define ALL_TITLE "*"

#define FULL_FLAG 1
#define SINGLE_FLAG 0

#define SINGLE_NOTE "Video"
#define FULL_NOTE "Channel"

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
   -(void) setAllViewedAttr: (BOOL) newState;
@end

//**********************************************************//

@interface Handler : NSObject <NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
    
    //***** DB *****// 
    @property (strong, nonatomic) NSString* dbPath;
    @property (nonatomic) sqlite3* db;

    //**** WEB FETCHES ****//
    @property (nonatomic) int noteFlag;
    @property (nonatomic) int channelCnt;

    //*************** BASIC ****************//
    -(id) initWithDB: (NSString*)dbPath;
    -(int) openDatabase;
    -(int) closeDatabase;
    -(int) channelIdFromName: (const char*)name;
    -(int) queryStmt: (const char*)stmt;
    
    //************** Utility *******************//
    -(int) getChannels: (NSMutableArray*)channels;
    -(int) getChannels: (NSMutableArray*)channels name:(NSString*)name;
    -(int) getVideosFrom: (const char*)channel count:(int)count videos:(NSMutableArray*) videos;
    -(int) setAllViewedInDatabase;
    -(int) setAllViewedInDatabase: (int)owner_id;
    -(int) toggleViewedInDatabase: (NSString*)title owner_id:(int)owner_id;

    //*************** Adding Videos ****************//
    -(int) importRSS: (const char*)channel;
    -(int) handleRSS: (char**)columnValues;
    -(int) addVideo: (const char* )timestamp title:(const char* )title owner_id:(const char*)owner_id link:(const char*) link;

@end

//*************** XML PARSING *******************//
void getDataFromTag( NSString* tag, NSString* response, NSMutableArray* tagData);
void getHrefFromTag( NSString* tag, NSString* response, NSMutableArray* tagData);

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
