#import "AppDelegate.h"
#import "ViewController.h"
#import "SubViewController.h"
#import "util.h"

@implementation AppDelegate


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
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

    //--------------------------------------------//

    NSString* home = NSHomeDirectory();
    NSMutableString* dbPath =[[NSMutableString alloc] initWithCString: DB_PATH encoding:NSASCIIStringEncoding];
    [dbPath insertString: home atIndex:(NSUInteger)0];

    DBHandler* handler = [[DBHandler alloc] initWithDB: dbPath];
    if ( [handler openDatabase] == SQLITE_OK )
    {
        [handler importRSS];
        
        NSMutableArray* videos = [[NSMutableArray alloc] init];

        [handler getVideosFrom: "Eye" count:5 videos:videos];

        for (int i=0; i<videos.count; i++)
        {
            NSLog(@"%@", videos[i]);
        }

        [handler closeDatabase]; 
    }


    //-----------------------------------------------------------//

    // [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerCalled) userInfo:nil repeats:NO];

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

@end
