#import "backend.h"
#import "frontend.h"
#define CELL_IDENTIFIER "newCell"

@interface ViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
    // The <...> objects are protocols used for the implementation of the tableView and the searchbar

    //*********** ELEMENT POSITIONING *****//
    @property (strong, nonatomic) NSMutableDictionary* positions;

    //*********** UI ELEMENTS **************//
    @property (strong, nonatomic) UIActivityIndicatorView* spinner;
    @property (strong, nonatomic) UILabel *loadingLabel;
    @property (strong, nonatomic) UILabel *errorLabel;
    @property (strong, nonatomic) UILabel *errorCode;
    @property (strong, nonatomic) UIButton *backBtn;
    @property (strong, nonatomic) UIButton *reloadBtn;
    @property (strong, nonatomic) UIButton *debugBtn;
    @property (strong, nonatomic) UISearchBar *searchBar;
    
    //********** CORE VIEWS *************//
    @property (strong, nonatomic) UITableView *videoView;
    @property (strong, nonatomic) UITableView *channelView;
    
    //*********** BACK END ***************//
    @property (strong, nonatomic) Handler* handler;
    @property (strong, nonatomic) NSString* currentViewFlag;

    // The cache is updated when pressing the backButton and when pressing the fullReload button
    @property (strong, nonatomic) NSMutableArray *channelsCache; 
    @property (strong, nonatomic) NSMutableArray *channels; 
    @property (strong, nonatomic) NSMutableArray *videos; 


    //************* BASICS ******************************//

    -(void) loadView;
    -(void) viewDidLoad;
    -(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

    //************ NOTIFICATIONS *****************//
    -(void) presentVideos: (NSNotification*)notification;
    -(void) finishFullReload: (NSNotification*)notification;

    //************* ADDING VIEWS **********************//
    -(UIButton*)getButtonView:(NSString*)btnStr selector:(SEL)selector width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset;
    -(void) addImageView;
    -(void) addChannelView;
    -(void) addVideoView: (NSString*) channel;
    -(void) addSearchBar;
    -(void) addVideoBtn: (Cell*)cell viewed:(bool)viewed owner_id:(int)owner_id;
    -(void) addChannelBtn: (Cell*)cell;

    //************* MISC ********************//
    -(void) fetchVideos: (NSString*)channel;
    -(void) updateCache: (NSString*)name;
    -(void) getUnviewedCountFromCache;
    -(void) initSpinner;
    -(void) markAllViewed: (NSString*)name;
    
    //************ TABLES *******************//
    // Required functions for the dataSource and delegate implemntations of the 
    // <UITableViewDataSource, UITableViewDelegate>  protocols
    // Note that both the videoView and channelView utilise the same tableView() functions
    // when adding new cells etc.

    //********** BUTTONS ******************//
    -(void) toggleViewed: (CellButton*)btn;
    -(void) channelRightBtn: (CellButton*)btn;
    -(void) rightBtn: (UIButton*)sender;
    -(void) goBack:(UIButton*) sender; 
    -(void) fullReload;

    //*********** SEARCHBAR *****************//
    -(void) channelSearch:(NSString*) searchText;
@end



