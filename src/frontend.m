#import "frontend.h"


@implementation CellButton : UIButton
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
            self.tintColor = [[UIColor alloc] initWithRed:(CGFloat)187/255 green:(CGFloat)146/255 blue:(CGFloat)172/255 alpha:(CGFloat)1.0 ];
        } 
        else { self.tintColor = [[UIColor alloc] initWithWhite:1 alpha:0.6 ]; }
    }

    // set channel view label
@end

@implementation Cell : UITableViewCell
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

