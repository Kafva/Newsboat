#import "ViewController.h"

@implementation ViewController
    // The ViewController is respsoible for displaying the different views of the app
    // (Usually there are several) and inherits from the UIViewController class

    - (void)loadView 
    {
        
        // Call the mainScreen method of UIScreen
        // NOTE that we need to connect each view with the rectangle created with
        // the application frame
        //CGRect rect = [UIScreen mainScreen].applicationFrame;
        CGRect rect = [UIScreen mainScreen].bounds;
        self.view = [[UIView alloc] initWithFrame:rect];
        self.view.backgroundColor = [UIColor blackColor];

        // We can techincally just place all of our views in the same controller and manage them
        // from here (Bring the "subview" forward on the stack when accessing it and delete it on back press)

        [self addImageView];
        [self addLabelView];
    }

    - (void)viewDidLoad {
        
        // The super keyword will go up the class hierachy and execute the specified method (viewDidLoad)
        // once a superclass which implements it is encountered
        [super viewDidLoad];

        // Initalise sqlite database in /Documents/ unless one already exists
    }


    -(void)addLabelView
    {
        // Create a label UI element
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(5,5,200,50)];
        
        NSArray *arr = @[ @"wow", @"xDD", @"Zzz" ];

        // Set the text attributes of the UILabel
        labelView.text = arr[2];
        labelView.textColor = [UIColor whiteColor];
        
        [self.view addSubview:labelView];
    }

    -(void)addImageView
    {

        UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,480,720)  ];
        
        [imgview setImage:[UIImage imageNamed:@"opera"] ];

        [imgview setContentMode:UIViewContentModeScaleAspectFit];
        
        // %@ is the format specifier for Objective C objects
        //NSLog(@"something %@\n", imgview.image);
    
        [self.view addSubview:imgview];
    }


    @end
