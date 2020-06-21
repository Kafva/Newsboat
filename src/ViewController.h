#import <UIKit/UIKit.h>
#import "util.h"

static NSString *cellIdentifier = @"newCell";

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
    // The <...> objects are protocols used for the implementation of the tableView

    @property (strong, nonatomic) UITableView *channelView;
    @property (nonatomic, strong) NSMutableArray *channels; 
    
    @property (strong, nonatomic) UITableView *videoView;
    @property (nonatomic, strong) NSMutableArray *videos; 


    -(void)loadView;
    -(void)viewDidLoad;
    -(void)addImageView;
    
    -(void)addChannelView;
    -(void)addVideoView: (NSString*) channel;
@end



