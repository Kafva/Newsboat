#import "SubViewController.h"

@implementation SubViewController

- (void)loadView 
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:rect];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad {
    // The super keyword will go up the class hierachy and execute the specified method (viewDidLoad)
    // once a superclass which implements it is encountered
    [super viewDidLoad];
}

@end
