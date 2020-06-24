#import "ViewController.h"
// TODO
//  Move reload to right side (avoid the need to unload it but will require handling on both scenes)
//  Landscape mode background
//  Load button
//  Show new video count on channel view    (emoji on the side of cells?)
//  Sort by new
//  Hide links on video view

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
        [self addChannelView];

        // Positioning of reload button is not well made
        [self addButtonView: @"reload.png" selector: @selector(reloadRSS:) width: RELOAD_WIDTH height: RELOAD_HEIGHT x_offset: SCREEN_WIDTH - BTN_Y_OFFSET*6 - 10 y_offset: BTN_Y_OFFSET ];
    }

    - (void)viewDidLoad 
    {
        
        // The super keyword will go up the class hierachy and execute the specified method (viewDidLoad)
        // once a superclass which implements it is encountered
        [super viewDidLoad];

    }

    -(void)addButtonView:(NSString*)btn selector:(SEL)selector width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset
    // To reuset the button function we pass the selector method which defines the
    // action on-tap for the button
    {
        UIButton *backButton = [UIButton buttonWithType: UIButtonTypeSystem];
        backButton.tintColor = [UIColor whiteColor];
        
        // Create a UIImage object of the back icon and create a rect with the same dimensions
        // as the smallest version in the imageset
        UIImage* backImage = [UIImage imageNamed:btn];
        backImage = [self imageWithImage: backImage convertToSize: CGSizeMake(width, height) ];
        
        [backButton setFrame:CGRectMake(x_offset, y_offset, width, height)];
        [backButton setImage: backImage forState:UIControlStateNormal];
        //[backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside ];
        [backButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside ];

        [self.view addSubview:backButton];
    }

    -(void)addImageView
    {
        UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGTH)  ];
        [imgview setImage:[UIImage imageNamed:@"sea"] ];

        // AspectFill will ensure that the whole screen is filled
        [imgview setContentMode:UIViewContentModeScaleAspectFill];
        
        [self.view addSubview:imgview];
    }
    
    -(void) addChannelView
    {
        //-----------------------------------------------//
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        CGRect tableFrame = CGRectMake(0, Y_OFFSET, width, height);

        self.channelView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.channelView registerClass:[Cell class] forCellReuseIdentifier:cellIdentifier];
        
        self.channelView.backgroundColor = [UIColor clearColor];
        self.channelView.delegate = self;
        self.channelView.dataSource = self;
        [self.view addSubview: self.channelView];

        self.currentViewName = @"channel";

        //----------------------------------------------// 
    
        NSString* home = NSHomeDirectory();
        NSMutableString* dbPath =[[NSMutableString alloc] initWithCString: DB_PATH encoding:NSASCIIStringEncoding];
        [dbPath insertString: home atIndex:(NSUInteger)0];

        DBHandler* handler = [[DBHandler alloc] initWithDB: dbPath];

        if ( [handler openDatabase] == SQLITE_OK )
        {
            self.channels = [[NSMutableArray alloc] init];
            NSMutableArray* channels = [[NSMutableArray alloc] init];
            
            [handler getChannels: channels];
            
            for (int i=0; i<channels.count; i++)
            {
                //NSLog(@"%@", channels[i]);
                [self.channels addObject: channels[i] ];
            }

            [handler closeDatabase]; 



        }
    }

    -(void) addVideoView: (NSString*) channel
    {
        //-----------------------------------------------//
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        CGRect tableFrame = CGRectMake(0, Y_OFFSET*1.5, width, height);

        self.videoView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.videoView registerClass:[Cell class] forCellReuseIdentifier:cellIdentifier];
        
        self.videoView.backgroundColor = [UIColor clearColor];
        self.videoView.delegate = self;
        self.videoView.dataSource = self;
        [self.view addSubview: self.videoView];

        self.currentViewName = @"video";

        //----------------------------------------------// 
    
        NSString* home = NSHomeDirectory();
        NSMutableString* dbPath =[[NSMutableString alloc] initWithCString: DB_PATH encoding:NSASCIIStringEncoding];
        [dbPath insertString: home atIndex:(NSUInteger)0];

        DBHandler* handler = [[DBHandler alloc] initWithDB: dbPath];

        if ( [handler openDatabase] == SQLITE_OK )
        {
            self.videos = [[NSMutableArray alloc] init];
            //NSMutableArray* videos = [[NSMutableArray alloc] init];

            [handler importRSS: [channel cStringUsingEncoding: NSASCIIStringEncoding]];
            [handler getVideosFrom: [channel cStringUsingEncoding: NSASCIIStringEncoding] count: VIDEOS_PER_CHANNEL videos:self.videos ];

            for (int i=0; i<self.videos.count; i++)
            {
                NSLog(@"addVideoView(): %@: %@ (%@)", channel , [self.videos[i] title] , [self.videos[i] link]  );
            }

            [handler closeDatabase]; 
        }

    }

    //------------ TABLES -------------------//
    // https://gist.github.com/keicoder/8682867 

    // Required functions for the dataSource and delegate implemntations of the 
    // <UITableViewDataSource, UITableViewDelegate>  protocols
    // Note that both the videoView and channelView utilise the same tableView() functions
    // when adding new cells etc.
    
    -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    // Called when adding a new cell to the tableView
    {
        // Deque an unusued cell object based on the static cellIdentifier
        Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        // Set the style value to enable the use of detailTextLabels        
        [cell initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];


        // Clear background and white text
        cell.backgroundColor = [UIColor clearColor];
        
        //cell.textLabel.font =   [UIFont fontWithName:@"AppleColorEmoji" size:16.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
        // TODO
        cell.selectedBackgroundView.backgroundColor = [UIColor redColor];

        // Populate with the datasource corresponding to the active tableView
        if ( self.channelView == tableView ) { cell.textLabel.text = [[self.channels objectAtIndex:indexPath.row] name ]; }
        else 
        { 
            // Set the text of the cell and store the link to the video in a custom property of the cell subclass
            cell.textLabel.text = [[self.videos objectAtIndex:indexPath.row] title]; 
            cell.link = [[self.videos objectAtIndex:indexPath.row] link];
            
            //cell.detailTextLabel.text = [[self.videos objectAtIndex:indexPath.row] link]; 
        }

        return cell;
    }

    -(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    // Returns the number of sections in the tableView
    {
        return 1;
    }
    
    -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    // Returns the number of cells in the tableView section
    {
        if ( tableView == self.channelView ){ return [self.channels count]; }
        else { return [self.videos count]; }
    }

    -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    // Called when a row is selected
    {
        
        if ( self.channelView == tableView )
        // If an entry is tapped from the channel view
        {
            NSString* channel = [ tableView cellForRowAtIndexPath: indexPath ].textLabel.text;
            NSLog(@"Tapped entry[%ld]: %@", indexPath.row, channel);
            
            self.channelView.hidden = YES;
            
            [self addVideoView: channel];
            [self addButtonView: @"back.png" selector: @selector(goBack:) width: BACK_WIDTH height: BACK_HEIGHT x_offset:0 y_offset:BTN_Y_OFFSET ];
        }
        else
        {
            NSString* link = [[tableView cellForRowAtIndexPath: indexPath ] link];
            NSLog(@"Tapped entry[%ld]: %@", indexPath.row, link);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:NULL completionHandler:^(BOOL success) { NSLog(@"opened url %d", success); } ];
        } 
    }        

    -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    // Returns the desired height of each row
    {
        return 70;
    }

    -(UIImage*) imageWithImage:(UIImage *)image convertToSize:(CGSize)size 
    // Helper to scale UIImage objects
    {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();    
        UIGraphicsEndImageContext();
        return destImage;
    }
    
    //------ BUTTONS -------// 
    
    -(void) reloadRSS: (UIButton*)sender
    {
        if ( [ self.currentViewName isEqual: @"channel"] )
        {
            NSLog(@"chan!");

        } else { NSLog(@"vid!"); }
        
    }

    -(void) goBack: (UIButton*)sender 
    // When the back button is tapped from a video view
    // unhide the channels view and delete the button and video view (for the specific channel)
    {
        [self.videoView removeFromSuperview];
        [sender removeFromSuperview];
        self.currentViewName = @"channel";
        self.channelView.hidden = NO;
    }

@end

