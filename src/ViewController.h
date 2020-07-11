#import "backend.h"
#import "frontend.h"
#define CELL_IDENTIFIER "newCell"

@interface ViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
    // The <...> objects are protocols used for the implementation of the tableView and the searchbar

    @property (strong,nonatomic) UIActivityIndicatorView* spinner;
    
    @property (strong,nonatomic) NSString* currentViewFlag;
    @property (strong,nonatomic) DBHandler* handler;

    @property (strong, nonatomic) UIButton *backBtn;
    @property (strong, nonatomic) UIButton *reloadBtn;
    @property (strong, nonatomic) UITableView *channelView;
    @property (strong, nonatomic) NSMutableArray *channels; 
    
    // The cache is updated when pressing the backButton and when pressing the fullReload button
    @property (strong, nonatomic) NSMutableArray *channelsCache; 
    
    @property (strong, nonatomic) UITableView *videoView;
    @property (strong, nonatomic) NSMutableArray *videos; 

    @property (strong, nonatomic) UISearchBar *searchBar;

    //************* BASICS ******************************//

    -(void) loadView;
    -(void) viewDidLoad;
    -(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
    
    //************* ADDING VIEWS **********************//
    -(UIButton*)getButtonView:(NSString*)btnStr selector:(SEL)selector width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset;
    -(void) addImageView;
    -(void) addChannelView;
    -(void) addVideoView: (NSString*) channel;
    -(void) addSearchBar;
    -(void) addToggleBtn: (Cell*)cell viewed:(bool)viewed owner_id:(int)owner_id;

    //************* MISC ********************//
    -(void) fetchVideos: (NSString*)channel;
    -(void) updateCache;
    -(void) getUnviewedCountFromCache;
    -(void) initSpinner;
    
    //************ TABLES *******************//
    // https://gist.github.com/keicoder/8682867 

    // Required functions for the dataSource and delegate implemntations of the 
    // <UITableViewDataSource, UITableViewDelegate>  protocols
    // Note that both the videoView and channelView utilise the same tableView() functions
    // when adding new cells etc.

    //********** BUTTONS ******************//
    -(void) toggleViewed: (CellButton*)sender;
    -(void) rightBtn: (UIButton*)sender;
    -(void) goBack:(UIButton*) sender; 
    -(void) fullReload;

    //*********** SEARCHBAR *****************//
    -(void) channelSearch:(NSString*) searchText;
@end



