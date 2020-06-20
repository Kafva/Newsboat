#import "AppDelegate.h"
#import "ViewController.h"
#import "SubViewController.h"
#import "util.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
// Method of the AppDelegate class to run on startup
{
    // Model: Get backend data from database and issue HTTP requsts for RSS feed data
    
    // Set the window property by allocating a new window 

    //  self.window = UIWindow.alloc().initWithFrame( UIScreen.mainScreen(), bounds )
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // self.rootController
    self.rootController = [[ViewController alloc] init];

    // Set the UIApplication's 
    [self.window addSubview:self.rootController.view];
    [self.window setRootViewController:self.rootController];

    [self.window makeKeyAndVisible];

    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerCalled) userInfo:nil repeats:NO];

    //-----------------------------------------------------------//
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

    NSString* dbPath = @"/Documents/rss.db";
    DBHandler* handler = [[DBHandler alloc] initWithDB: dbPath];
    
    if ( handler.db ){ sqlite3_close( *(handler.db) ); }


    //-----------------------------------------------------------//


    return YES;
}

-(void)timerCalled
{
    NSLog(@"Timer Called");


    UIViewController *new = [[SubViewController alloc] init];
    
    self.rootController = new;

    // Set the UIApplication's 
    [self.window addSubview:self.rootController.view];
    [self.window setRootViewController:self.rootController];

    [self.window makeKeyAndVisible];

}


//#pragma mark - UISceneSession lifecycle
//
//
//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
