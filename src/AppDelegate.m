#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
// Method of the AppDelegate class to run on startup
{
    // NOTE that to change the text color of the status bar we use a few lines in .plist
    //    <key>UIStatusBarStyle</key>
    //    <string>UIStatusBarStyleLightContent</string>
    //    <key>UIViewControllerBasedStatusBarAppearance</key>
    //    <false/>	
    
    
    // Set the window property by allocating a new window 
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.rootController = [[ViewController alloc] init];
    
    //self.window.tintColor = [UIColor whiteColor];
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Set the rootViewcontroller and make the window visible 
    [self.window addSubview:self.rootController.view];
    [self.window setRootViewController:self.rootController];

    [self.window makeKeyAndVisible];

    return YES;
}

@end
