#import "backend.h"
#import "frontend.h"
#define CELL_IDENTIFIER "newCell"

@interface ViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
    // The <...> objects are protocols used for the implementation of the tableView and the searchbar

    @property (strong,nonatomic) UIActivityIndicatorView* spinner;
    
    @property (strong,nonatomic) NSString* currentViewFlag;
    @property (strong,nonatomic) DBHandler* handler;

    @property (strong, nonatomic) UIButton *reloadBtn;
    @property (strong, nonatomic) UITableView *channelView;
    @property (strong, nonatomic) NSMutableArray *channels; 
    
    @property (strong, nonatomic) UITableView *videoView;
    @property (strong, nonatomic) NSMutableArray *videos; 

    @property (strong, nonatomic) UISearchBar *searchBar;


    -(void)loadView;
    -(void)viewDidLoad;
    -(void)addImageView;
    
    -(void)addChannelView;
    -(void)addVideoView: (NSString*) channel;
    -(UIButton*)getButtonView:(NSString*)btnStr selector:(SEL)selector width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset;
    -(void) addToggleBtn: (Cell*)cell viewed:(bool)viewed owner_id:(int)owner_id;
    -(void) addSearchBar;


    -(void) toggleViewed: (CellButton*)sender;
    -(void) goBack:(UIButton*) sender; 
    -(void) rightBtn: (UIButton*)sender;
    -(void) fullReload;

@end



