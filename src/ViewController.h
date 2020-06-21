#import <UIKit/UIKit.h>

static NSString *cellIdentifier = @"newCell";

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
    // The <...> objects are protocols used for the implementation of the tableView

    @property (strong, nonatomic) UITableView *tableView;
    @property (nonatomic, strong) NSMutableArray *tableData; // holds the table data (title)
    @property (nonatomic, strong) NSMutableArray *tableDetailData; // holds the table data (detail text)

    -(void)loadView;
    -(void)viewDidLoad;
    -(void)addLabelView;
    -(void)addImageView;
    -(void)addTableView;
    
@end



