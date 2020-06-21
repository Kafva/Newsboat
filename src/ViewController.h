#import <UIKit/UIKit.h>
#import "util.h"
#define TABLE_ROWS 5


static NSString *cellIdentifier = @"newCell";

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
    // The <...> objects are protocols used for the implementation of the tableView

    @property (strong, nonatomic) UITableView *tableView;
    @property (nonatomic, strong) NSMutableArray *tableData; // holds the table data (title)
    @property (nonatomic, strong) NSMutableArray *tableDetailData; // holds the table data (detail text)

    -(void)loadView;
    -(void)viewDidLoad;
    -(void)addImageView;
    -(void)addTableView;
    
@end



