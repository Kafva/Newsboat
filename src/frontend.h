#import <UIKit/UIKit.h>

#define SCREEN_WIDTH 480
#define SCREEN_HEIGTH 720
#define Y_OFFSET 50

// BTN_X_OFFSET = SCREEN_WIDTH - BTN_Y_OFFSET*6 - 10;
#define BTN_Y_OFFSET 20
#define BTN_X_OFFSET 350

#define BACK_WIDTH 21
#define BACK_HEIGHT 28

#define CELL_BTN_WIDTH 21
#define CELL_BTN_HEIGHT 28

#define RELOAD_WIDTH 21
#define RELOAD_HEIGHT 28

#define CHANNEL_VIEW 0
#define VIDEO_VIEW 1

#define VIEWED_IMAGE "plus"
#define UNVIEWED_IMAGE "star"

@interface CellButton : UIButton
    // The cell button is made into a seperate class since it needs to
    // react to touch events which depend on the 'viewed' status
    // as well as the title and owner_id (to uniquely identify the corresponding entry in the database)
    @property NSString* title;
    @property bool viewed;
    @property int owner_id;

    // Set the status image of the cell button in accordance with the 'viewed' attribute
    -(void)setStatusImage;
@end

@interface Cell : UITableViewCell
    // Create a subclass of the table cell elements to store additional information
    @property (strong,nonatomic) NSString* link;
    @property (strong,nonatomic) CellButton* toggleBtn;

    //-(void)setToggleButton: (const char*)title owner_id:(int)owner_id viewed:(int)viewed selector:(SEL)selector controller:(ViewController*) controller;

@end

UIImage* imageWithImage( UIImage* image, CGSize size); 
