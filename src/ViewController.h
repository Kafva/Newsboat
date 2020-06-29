#import "backend.h"
#import "frontend.h"

static NSString *cellIdentifier = @"newCell";

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
    // The <...> objects are protocols used for the implementation of the tableView

    @property int currentViewFlag;
    @property (strong,nonatomic) DBHandler* handler;


    @property (strong, nonatomic) UIButton *reloadBtn;
    @property (strong, nonatomic) UITableView *channelView;
    @property (nonatomic, strong) NSMutableArray *channels; 
    
    @property (strong, nonatomic) UITableView *videoView;
    @property (nonatomic, strong) NSMutableArray *videos; 


    -(void)loadView;
    -(void)viewDidLoad;
    -(void)addImageView;
    
    -(void)addChannelView;
    -(void)addVideoView: (NSString*) channel;
    -(UIButton*)getButtonView:(NSString*)btnStr selector:(SEL)selector width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset;
    -(void) addToggleBtn: (Cell*)cell viewed:(bool)viewed owner_id:(int)owner_id;


    -(void) toggleViewed: (CellButton*)sender;
    -(void) goBack:(UIButton*) sender; 
    -(void) reloadRSS: (UIButton*)sender;

@end



