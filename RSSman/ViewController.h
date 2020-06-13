#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ViewController : UIViewController

    // Datebase attributes
    @property (strong, nonatomic) NSString *databasePath;
    @property (nonatomic) sqlite3 *contactDB;

@end

