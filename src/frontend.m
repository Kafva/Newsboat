#import "frontend.h"


@implementation CellButton : UIButton
    
    -(NSString*)description
    {
        return [NSString stringWithFormat:@"<CellButton:%p> %@ %d %d", self, self.title, self.viewed, self.owner_id ]; 
    }
    
    -(void) setStatusImage
    // Set the corresponding image and color based upon the 'viewed' attribute
    {
        NSString* btnName = [NSString stringWithFormat:@"%s", VIEWED_IMAGE];
        if (self.viewed == FALSE)
        {  
            btnName = [NSString stringWithFormat:@"%s", UNVIEWED_IMAGE]; 
        } 
    
        UIImage* btnImage = [UIImage imageNamed:btnName];
        btnImage = imageWithImage( btnImage, CGSizeMake(CELL_BTN_WIDTH, CELL_BTN_HEIGHT));
        
        [self setImage: btnImage forState:UIControlStateNormal];
        
        if (self.viewed == FALSE)
        {  
            self.tintColor = [[UIColor alloc] initWithRed:(CGFloat)RED green:(CGFloat)GREEN blue:(CGFloat)BLUE alpha:(CGFloat)1.0 ];
        } 
        else { self.tintColor = [[UIColor alloc] initWithWhite:1 alpha:0.6 ]; }
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

UIImage* imageWithImage(UIImage* image, CGSize size) 
// Helper to scale UIImage objects
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return destImage;
}

