#import <UIKit/UIKit.h>

#define SCREEN_WIDTH 480
#define SCREEN_HEIGTH 720
#define Y_OFFSET 50

// Note that char* can be used as NSStrings with an '@'
#define FONT_SIZE 18
#define REGULAR_FONT "Arial"
#define BOLD_FONT "Arial-BoldMT"

// BTN_X_OFFSET = SCREEN_WIDTH - BTN_Y_OFFSET*6 - 10;
#define BTN_X_OFFSET 350
#define BTN_Y_OFFSET 20

#define BACK_WIDTH 21
#define BACK_HEIGHT 28

#define RIGHT_LABEL_X_OFFSET 300
#define LEFT_LABEL_X_OFFSET 16
#define LABEL_Y_OFFSET 15

#define CELL_BTN_WIDTH 21
#define CELL_BTN_HEIGHT 28

#define LEFT_LABEL_WIDTH 300
#define RIGHT_LABEL_WIDTH 50
#define LABEL_HEIGHT 20

#define RELOAD_WIDTH 21
#define RELOAD_HEIGHT 28

#define OK_WIDTH 42
#define OK_HEIGHT 56

#define CHANNEL_VIEW "0"

//** IMAGES **//
#define VIEWED_IMAGE "plus"
#define UNVIEWED_IMAGE "star"
#define BACK_IMAGE "back"
#define RELOAD_IMAGE "refresh"
#define OK_IMAGE "ok"
#define BKG_IMAGE "sea"

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
    -(void)setStatusImage;
    -(NSString*)description;

@end

@interface Cell : UITableViewCell
    // Create a subclass of the table cell elements to store additional information
    @property (strong,nonatomic) NSString* title;
    @property (strong,nonatomic) NSString* link;
    @property (strong,nonatomic) CellButton* toggleBtn;

    @property (strong,nonatomic) UILabel* leftLabel;
    @property (strong,nonatomic) UILabel* rightLabel;
    
    -(UILabel*) getUnviewedCounter:(NSString*) str width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset textColor:(UIColor*)textColor font:(UIFont*)font;
    -(NSString*)description;
@end

UIImage* imageWithImage( UIImage* image, CGSize size); 
UIImage* getImage(NSString* imageName, int width, int height);
