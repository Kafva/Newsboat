#import "frontend.h"

@implementation CellButton : UIButton
    
    -(NSString*)description
    {
        return [NSString stringWithFormat:@"<CellButton:%p> %@ %d %d", self, self.title, self.viewed, self.owner_id ]; 
    }
    
    -(void) setStatusImage: (CGFloat) height
    // Set the corresponding image and color based upon the 'viewed' attribute
    {
        NSString* btnName = @VIEWED_IMAGE;
        if (self.viewed == FALSE) {  btnName = @UNVIEWED_IMAGE;  } 
    
        UIImage* btnImage = [UIImage imageNamed:btnName];
        btnImage = imageWithImage( btnImage, CGSizeMake(CELL_BTN_WIDTH, height));
        
        [self setImage: btnImage forState:UIControlStateNormal];
        
        if (self.viewed == FALSE)
        {  
            self.tintColor = [[UIColor alloc] initWithRed:(CGFloat)RED green:(CGFloat)GREEN blue:(CGFloat)BLUE alpha:(CGFloat)1.0 ];
        } 
        else { self.tintColor = [[UIColor alloc] initWithWhite:1 alpha:0.6 ]; }
    }
    
    -(void) setChannelImage: (CGFloat) height
    // Set the corresponding image and color based upon the 'viewed' attribute
    {
        NSString* btnName = @OK_IMAGE;
    
        UIImage* btnImage = [UIImage imageNamed:btnName];
        btnImage = imageWithImage( btnImage, CGSizeMake(CELL_BTN_WIDTH, height));
        self.tintColor = [[UIColor alloc] initWithWhite:1 alpha:0.6 ];
        [self setImage: btnImage forState:UIControlStateNormal];
    }
    
@end

@implementation Cell : UITableViewCell
    
    -(UILabel*) getUnviewedCounter:(NSString*) str width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset textColor:(UIColor*)textColor font:(UIFont*)font
    {
        // Setting a frame is essential for an element to be displayed
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(x_offset, y_offset, width, height)];

        label.textColor = textColor;
        label.text = str;
        [label setFont:font];
        return label; 
    }

    -(NSString*)description
    {
        return [NSString stringWithFormat:@"<Cell:%p> %@", self, self.title ]; 
    }
    
@end

UILabel* getLabel(NSString* str, int width, int height, int x_offset, int y_offset, UIColor* textColor,  UIFont* font)
{
    // Setting a frame is essential for an element to be displayed
    UILabel* label = [[UILabel alloc] init];
    [label setFrame:CGRectMake(x_offset, y_offset, width, height)];

    label.textColor = textColor;
    label.text = str;
    [label setFont:font];
    return label; 
}

UIImage* imageWithImage(UIImage* image, CGSize size) 
// Helper to scale UIImage objects
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return destImage;
}

UIImage* getImage(NSString* imageName, int width, int height)
{
    // Create a UIImage object of the back icon and create a rect with the same dimensions
    // as the smallest version in the imageset
    UIImage* img = [UIImage imageNamed:imageName];
    return imageWithImage(img, CGSizeMake(width, height));
}

void initPositioning(NSMutableDictionary* positions, NSInteger width, NSInteger height)
{
    // Note that when accessing elements from a NSDictionary `id` values will be returned,
    // to access the actual value one must use (for floats) [dict['num1'] floatValue]
    // Also note that floating point division needs to be made explicit with x./y

    [positions setObject: [NSNumber numberWithInteger: width] forKey: @"screen_width"];
    [positions setObject: [NSNumber numberWithInteger: height] forKey: @"screen_height"];

    // Height: 667 Width: 375 (iPhone 6s)
    // With this setup a scaling factor is determined for some of the offsets to enable a
    // usable interface on different sized screens

    // Y-axis
    [positions setObject: [NSNumber numberWithFloat: 50./667 ] forKey: @"y_offset"];
    [positions setObject: [NSNumber numberWithFloat: 20./667 ] forKey: @"btn_y_offset"];
    [positions setObject: [NSNumber numberWithFloat: 20./667 ] forKey: @"error_y_label"];
    [positions setObject: [NSNumber numberWithFloat: 90./667 ] forKey: @"error_y_code"];
    [positions setObject: [NSNumber numberWithFloat: 15./667 ] forKey: @"label_y_offset"];

    // Heights
    [positions setObject: [NSNumber numberWithFloat: 70./667 ] forKey: @"row_height"];
    [positions setObject: [NSNumber numberWithFloat: 28./667 ] forKey: @"cell_btn_height"];

    // X-axis
    [positions setObject: [NSNumber numberWithFloat: 350./375 ] forKey: @"btn_x_offset"];
    [positions setObject: [NSNumber numberWithFloat: 60./375 ] forKey: @"error_x_label"];
    [positions setObject: [NSNumber numberWithFloat: 150./375 ] forKey: @"error_x_code"];
    [positions setObject: [NSNumber numberWithFloat: 300./375 ] forKey: @"right_label_x"];
    [positions setObject: [NSNumber numberWithFloat: 16./375 ] forKey: @"left_label_x"];
    [positions setObject: [NSNumber numberWithFloat: 100./375 ] forKey: @"search_x_offset"];
    [positions setObject: [NSNumber numberWithFloat: 10./375 ] forKey: @"loading_x_offset"];

    // Widths
    [positions setObject: [NSNumber numberWithFloat: 70./375 ] forKey: @"loading_width"];
    [positions setObject: [NSNumber numberWithFloat: 50./375 ] forKey: @"right_label_width"];
    [positions setObject: [NSNumber numberWithFloat: 300./375 ] forKey: @"left_label_width"];
    [positions setObject: [NSNumber numberWithFloat: 200./375 ] forKey: @"search_width"];
    [positions setObject: [NSNumber numberWithFloat: 200./375 ] forKey: @"error_code_width"];
    [positions setObject: [NSNumber numberWithFloat: 280./375 ] forKey: @"error_label_width"];

}