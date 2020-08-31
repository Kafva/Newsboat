#import <UIKit/UIKit.h>

// Note that char* can be used as NSStrings with an '@'
#define FONT_SIZE 18
#define REGULAR_FONT "Arial"
#define BOLD_FONT "Arial-BoldMT"
#define CHANNEL_VIEW "0"

//** CONSTANT OFFSETS **//
#define BACK_WIDTH 21
#define BACK_HEIGHT 28

#define ERROR_LABEL_HEIGHT 200

#define CELL_BTN_WIDTH 21

#define LABEL_HEIGHT 20
#define DEBUG_WIDTH 28

#define RELOAD_WIDTH 21
#define RELOAD_HEIGHT 28

#define OK_WIDTH 42
#define OK_HEIGHT 56

//** IMAGES **//
#define VIEWED_IMAGE "plus"
#define UNVIEWED_IMAGE "star"
#define BACK_IMAGE "back"
#define RELOAD_IMAGE "reload"
#define OK_IMAGE "ok"
#define BKG_IMAGE "sea"
#define CHECK_IMAGE "fullcheck"

//** COLORS **//
#define RED 1
#define GREEN 143/255
#define BLUE 231/255

@interface CellButton : UIButton
    // The cell button is made into a seperate class since it needs to
    // react to touch events which depend on the 'viewed' status
    // as well as the title and owner_id (to uniquely identify the corresponding entry in the database)
    @property NSString* title;
    @property bool viewed;
    @property int owner_id;

    // Set the status image of the cell button in accordance with the 'viewed' attribute
    -(void) setStatusImage: (CGFloat)height;
    -(void) setChannelImage: (CGFloat)height;
    -(NSString*) description;

@end

@interface Cell : UITableViewCell
    // Create a subclass of the table cell elements to store additional information
    @property (strong,nonatomic) NSString* title;
    @property (strong,nonatomic) NSString* link;
    
    @property (strong,nonatomic) CellButton* videoBtn;
    @property (strong,nonatomic) CellButton* channelBtn;

    @property (strong,nonatomic) UILabel* leftLabel;
    @property (strong,nonatomic) UILabel* rightLabel;
    
    -(UILabel*) getUnviewedCounter:(NSString*) str width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset textColor:(UIColor*)textColor font:(UIFont*)font;
    -(NSString*)description;
@end

UILabel* getLabel(NSString* str, int width, int height, int x_offset, int y_offset, UIColor* textColor,  UIFont* font);
UIImage* imageWithImage( UIImage* image, CGSize size); 
UIImage* getImage(NSString* imageName, int width, int height);
void initPositioning(NSMutableDictionary* positions, NSInteger width, NSInteger heigth);