#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
    // Give the AppDelegate class two global properties iin the form of a main window
    // and a rootController object

    @property (strong, nonatomic) UIWindow *window;
    @property (strong, nonatomic) UIViewController *rootController;

    -(BOOL)application: (UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
