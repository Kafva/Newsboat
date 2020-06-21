#import "ViewController.h"
// TODO
//  Back-button
//  Load-all button
//  Show new video count on channel view
//  Hide links on video view
//  Rename + new icon with magick

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
    }

    - (void)viewDidLoad 
    {
        
        // The super keyword will go up the class hierachy and execute the specified method (viewDidLoad)
        // once a superclass which implements it is encountered
        [super viewDidLoad];

    }

    -(void)addButtonView
    {
        // https://stackoverflow.com/questions/227078/creating-a-left-arrow-button-like-uinavigationbars-back-style-on-a-uitoolba
        
        UIButton *backButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        [backButton setFrame:CGRectMake(0, 0, 20, 40)];
        
        // sets title for the button
        [backButton setTitle:@"Back" forState: UIControlStateNormal];
        [self.view addSubview:backButton];

    }

    -(void)addImageView
    {
        UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGTH)  ];
        [imgview setImage:[UIImage imageNamed:@"opera"] ];
        [imgview setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.view addSubview:imgview];
    }
    
    -(void) addChannelView
    {
        //-----------------------------------------------//
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        CGRect tableFrame = CGRectMake(0, Y_OFFSET, width, height);

        self.channelView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.channelView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        
        self.channelView.backgroundColor = [UIColor clearColor];
        self.channelView.delegate = self;
        self.channelView.dataSource = self;
        [self.view addSubview: self.channelView];
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
        CGRect tableFrame = CGRectMake(0, Y_OFFSET, width, height);

        self.videoView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.videoView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        
        self.videoView.backgroundColor = [UIColor clearColor];
        self.videoView.delegate = self;
        self.videoView.dataSource = self;
        [self.view addSubview: self.videoView];
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
                NSLog(@"%@: %@ (%@)", channel , [self.videos[i] title] , [self.videos[i] link]  );
            }

            [handler closeDatabase]; 
        }

    }

    //------------ TABLE -------------------//
    // https://gist.github.com/keicoder/8682867 

    // Required functions for the dataSource and delegate implemntations of the 
    // <UITableViewDataSource, UITableViewDelegate>  protocols
    // Note that both the videoView and channelView utilise the same tableView() functions
    // when adding new cells etc.
    
    -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    // Called when adding a new cell to the tableView
    {
        // Deque an unusued cell object based on the static cellIdentifier
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        // Set the style value to enable the use of detailTextLabels        
        [cell initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];


        // Clear background and white text
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
        // TODO
        cell.selectedBackgroundView.backgroundColor = [UIColor systemPinkColor];

        // Populate with the datasource corresponding to the active tableView
        if ( self.channelView == tableView ) { cell.textLabel.text = [[self.channels objectAtIndex:indexPath.row] name ]; }
        else 
        { 
            // The detailTextLabel isn't displayed but holds the video link
            cell.textLabel.text = [[self.videos objectAtIndex:indexPath.row] title]; 
            cell.detailTextLabel.text = [[self.videos objectAtIndex:indexPath.row] link]; 
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
            
            //[self addButtonView];
            [self addVideoView: channel];
        }
        else
        {
            NSString* link = [ tableView cellForRowAtIndexPath: indexPath ].detailTextLabel.text;
            NSLog(@"Tapped entry[%ld]: %@", indexPath.row, link);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:NULL completionHandler:^(BOOL success) { NSLog(@"opened url %d", success); } ];
        } 
        
        //else
        //{
        //    // Exit
        //    [ tableView removeFromSuperview ];
        //    self.channelView.hidden = NO;
        //    //[self.view setNeedsDisplay];
        //}

    }        

    -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    // Returns the desired height of each row
    {
        return 70;
    }

@end
