#import "ViewController.h"
// TODO
//  Can't reach last element in tableview
//  Searchbar for channel view
//  Landscape mode background
//  https://stackoverflow.com/questions/38261248/how-to-impliment-search-bar-in-table-view-for-contacts-in-ios

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
        self.reloadBtn = [self getButtonView: @RELOAD_IMAGE selector: @selector(rightBtn:) width: RELOAD_WIDTH height: RELOAD_HEIGHT x_offset: BTN_X_OFFSET y_offset: BTN_Y_OFFSET ];
        [self.view addSubview: [self reloadBtn]];
    }

    - (void)viewDidLoad 
    {
        // The super keyword will go up the class hierachy and execute the specified method (viewDidLoad)
        // once a superclass which implements it is encountered
        [super viewDidLoad];
    }

    -(UIButton*)getButtonView:(NSString*)btnStr selector:(SEL)selector width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset
    // To reuset the button function we pass the selector method which defines the
    // action on-tap for the button
    {
        UIButton *btn = [UIButton buttonWithType: UIButtonTypeSystem];
        btn.tintColor = [UIColor whiteColor];

        [btn setFrame:CGRectMake(x_offset, y_offset, width, height)];
        [btn setImage: getImage( btnStr, width,height ) forState:UIControlStateNormal];

        // TARGET needs to be the ViewController 
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside ];

        return btn;
    }

    -(void)addImageView
    {
        UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGTH)  ];
        [imgview setImage:[UIImage imageNamed:@BKG_IMAGE] ];

        // AspectFill will ensure that the whole screen is filled
        [imgview setContentMode:UIViewContentModeScaleAspectFill];
        
        [self.view addSubview:imgview];
    }
    
    -(void) addChannelView
    {
        //-----------------------------------------------//
        CGRect tableFrame = CGRectMake(0, Y_OFFSET, self.view.frame.size.width, self.view.frame.size.height);

        self.channelView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.channelView registerClass:[Cell class] forCellReuseIdentifier:@CELL_IDENTIFIER];
        
        self.channelView.backgroundColor = [UIColor clearColor];
        self.channelView.delegate = self;
        self.channelView.dataSource = self;
        [self.view addSubview: self.channelView];

        self.currentViewFlag = @CHANNEL_VIEW;

        //----------------------------------------------// 
    
        NSString* home = NSHomeDirectory();
        NSMutableString* dbPath =[[NSMutableString alloc] initWithCString: DB_PATH encoding:NSUTF8StringEncoding];
        [dbPath insertString: home atIndex:(NSUInteger)0];

        //self.handler = [[DBHandler alloc] initWithDB: dbPath];
        if ( self.handler == nil ){ self.handler = [[DBHandler alloc] initWithDB: dbPath]; }

        if ( [self.handler openDatabase] == SQLITE_OK )
        {
            self.channels = [[NSMutableArray alloc] init];
            NSMutableArray* channels = [[NSMutableArray alloc] init];
            
            [self.handler getChannels: channels];
            
            for (int i=0; i<channels.count; i++)
            {
                [self.channels addObject: channels[i] ];
            }

            [self.handler closeDatabase]; 
        }
    }

    -(void) addVideoView: (NSString*) channel
    {
        //-----------------------------------------------//
        CGRect tableFrame = CGRectMake(0, Y_OFFSET*1.5, self.view.frame.size.width, self.view.frame.size.height);

        self.videoView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.videoView registerClass:[Cell class] forCellReuseIdentifier:@CELL_IDENTIFIER];

        self.videoView.backgroundColor = [UIColor clearColor];
        self.videoView.delegate = self;
        self.videoView.dataSource = self;
        [self.view addSubview: self.videoView];

        // Use the currentViewFlag to store the channel name for updating the correct datasource
        // when exiting the video view
        self.currentViewFlag = channel;
        //NSLog(@"this:%@", self.currentViewFlag);

        //----------------------------------------------// 

        // Fetch all the videos from the RSS feed for the given channel 
        NSString* home = NSHomeDirectory();
        NSMutableString* dbPath =[[NSMutableString alloc] initWithCString: DB_PATH encoding:NSUTF8StringEncoding];
        [dbPath insertString: home atIndex:(NSUInteger)0];

        if ( self.handler == nil ){ self.handler = [[DBHandler alloc] initWithDB: dbPath]; }

        if ( [self.handler openDatabase] == SQLITE_OK )
        {
            self.videos = [[NSMutableArray alloc] init];

            // Import videos for the given channel into the database ( implicit calls to addVideo() )
            [self.handler importRSS: [channel cStringUsingEncoding: NSUTF8StringEncoding]];

            // Fetch video objects from the given channel from the database
            [self.handler getVideosFrom: [channel cStringUsingEncoding: NSUTF8StringEncoding] count: VIDEOS_PER_CHANNEL videos:self.videos ];
            
            
            [self.handler closeDatabase]; 
        }

    }

    -(void) addToggleBtn: (Cell*)cell viewed:(bool)viewed owner_id:(int)owner_id
    {
        // Create the 'viewed' toggle button depending on the viewed attribute from the videos array
        if (cell.toggleBtn == nil)
        // Only create and add a new toggle button to the cells view if the reused cell doesn't have one
        {
            NSLog(@"Adding new button: %@", cell.toggleBtn);

            cell.toggleBtn = [CellButton buttonWithType: UIButtonTypeSystem];
            [cell.toggleBtn setFrame:CGRectMake(BTN_X_OFFSET, BTN_Y_OFFSET, CELL_BTN_WIDTH, CELL_BTN_HEIGHT)];
            
            //**** NOTE **** that the target needs to be the ViewController (self)
            [cell.toggleBtn addTarget:self action:@selector(toggleViewed:) forControlEvents:UIControlEventTouchUpInside ];
            
            [cell.contentView addSubview: [cell toggleBtn]];
        }
        
        NSLog(@"Setting new button: %@ (viewed: %d)", cell.toggleBtn, viewed);
        
        cell.toggleBtn.title = cell.title;
        cell.toggleBtn.owner_id = owner_id;
        
        
        cell.toggleBtn.viewed = viewed;

        // Set the image depending on the toggleBtn 'viewed' attribute
        [cell.toggleBtn setStatusImage];

    }

    //------------ TABLES -------------------//
    // https://gist.github.com/keicoder/8682867 

    // Required functions for the dataSource and delegate implemntations of the 
    // <UITableViewDataSource, UITableViewDelegate>  protocols
    // Note that both the videoView and channelView utilise the same tableView() functions
    // when adding new cells etc.
    
    
    -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    // Called when adding a new cell to the tableView (i.e. on scrolling the tableview)
    {
        // Deque an unusued cell object based on the static @CELL_IDENTIFIER
        // Note that after iOS 5 the method will never return nil but we can check wheter or
        // not a title already exists in which case we DONT want to add more subviews
        // and instead simply change the text being displayed
        Cell *cell = [tableView dequeueReusableCellWithIdentifier:@CELL_IDENTIFIER];
        
        NSLog(@"Fetching new cell:  %@",cell);
        
        if (cell.title == nil)
        {
            // Set the style value to enable the use of detailTextLabels with 'Value1' instead of 'Default' 
            cell = [cell initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@CELL_IDENTIFIER];
            
            // Clear background and white/pink text
            cell.backgroundColor = [UIColor clearColor];
            UIColor* pink = [[UIColor alloc] initWithRed:(CGFloat)RED green:(CGFloat)GREEN blue:(CGFloat)BLUE alpha:(CGFloat)1.0 ];            
            
            UIFont* bold = [UIFont fontWithName: @BOLD_FONT size:FONT_SIZE];
            UIFont* regular = [UIFont fontWithName: @REGULAR_FONT size:FONT_SIZE];

            cell.leftLabel = [cell getUnviewedCounter: @"" width: LEFT_LABEL_WIDTH height: LABEL_HEIGHT x_offset: LEFT_LABEL_X_OFFSET y_offset: LABEL_Y_OFFSET textColor:[UIColor whiteColor] font:regular ]; 
            cell.rightLabel = [cell getUnviewedCounter: @"" width: RIGHT_LABEL_WIDTH height: LABEL_HEIGHT x_offset: RIGHT_LABEL_X_OFFSET y_offset: LABEL_Y_OFFSET textColor:pink font:bold ]; 
            
            [cell.contentView addSubview: cell.leftLabel];
            [cell.contentView addSubview: cell.rightLabel];
        } 

        // Populate with the datasource corresponding to the active tableView
        if ( self.channelView == tableView ) 
        //*** Cell configuration for channel view ****//
        { 
            cell.title = [[self.channels objectAtIndex:indexPath.row] name ]; 
            cell.leftLabel.text = cell.title;
            int unviewedCount = [[self.channels objectAtIndex:indexPath.row] unviewedCount];
            cell.rightLabel.textColor = [[UIColor alloc] initWithWhite:1 alpha:0.6 ]; 
            
            if ( unviewedCount == -1 ) { cell.rightLabel.text = @"(?)"; }
            else { cell.rightLabel.text = [NSString stringWithFormat: @"(%d/%d)", unviewedCount, VIDEOS_PER_CHANNEL]; }

            // Highlight color when there is at least one new video 
            if ( unviewedCount > 0 )  { cell.rightLabel.textColor = [[UIColor alloc] initWithRed:(CGFloat)RED green:(CGFloat)GREEN blue:(CGFloat)BLUE alpha:(CGFloat)1.0 ]; }
        }
        else 
        //*** Cell configuration for video view ****//
        { 
            // Set the text of the cell and store the link to the video in a custom property of the cell subclass
            cell.title = [[self.videos objectAtIndex:indexPath.row] title ]; 
            cell.link = [[self.videos objectAtIndex:indexPath.row] link];
            cell.leftLabel.text = cell.title;

            [self addToggleBtn: cell viewed:[[self.videos objectAtIndex:indexPath.row] viewed ] owner_id:[[self.videos objectAtIndex:indexPath.row] owner_id ] ];
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
    //--- Called when a row is selected ----//
    {
        
        if ( self.channelView == tableView )
        // If an entry is tapped from the channel view
        {
            NSString* channel = [[ tableView cellForRowAtIndexPath: indexPath ] title];
            NSLog(@"Tapped entry[%ld]: %@", indexPath.row, channel);

            self.channelView.hidden = YES;
            [self.reloadBtn setImage: getImage( @OK_IMAGE, RELOAD_WIDTH, RELOAD_HEIGHT ) forState:UIControlStateNormal];

            [self addVideoView: channel];
            [self.view addSubview: [self getButtonView: @BACK_IMAGE selector: @selector(goBack:) width: BACK_WIDTH height: BACK_HEIGHT x_offset:0 y_offset:BTN_Y_OFFSET ]];
        }
        else
        {
            NSString* link = [[tableView cellForRowAtIndexPath: indexPath ] link];
            NSLog(@"Tapped entry[%ld]: %@", indexPath.row, link);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:NULL completionHandler:^(BOOL success) { NSLog(@"opened URL (%d)", success); } ];
        } 
    }        

    -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    // Returns the desired height of each row
    {
        return 70;
    }

    
    //--------------- BUTTONS --------------------// 
    -(void) toggleViewed: (CellButton*) btn 
    {
        if ( [self.handler openDatabase] == SQLITE_OK )
        {
            // Update the viewed status in the database
            [self.handler toggleViewedVideos: btn.title owner_id: btn.owner_id];
            [self.handler closeDatabase]; 
        }

        // Update the state of the button in the cell
        btn.viewed = !btn.viewed;

        // Update the viewed status in the videos array
        [[self.videos objectAtIndex: getIndexByNameAndOwnerId( self.videos, btn.title, btn.owner_id ) ] toggleViewedAttr];
        
        [btn setStatusImage];
    }
        
    -(void) rightBtn: (UIButton*)sender
    // Hide button on video view
    {
        if ( [self.currentViewFlag isEqual: @CHANNEL_VIEW] )
        //*** Reload all RSS feeds ***//
        {
            
            // Begin by either creating the loading spinner from scratch and adding it as a subview
            // or simply unhide it after hiding the reload button
            self.reloadBtn.hidden = YES;
            if(self.spinner == nil)
            {
                self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                self.spinner.frame = CGRectMake(BTN_X_OFFSET, BTN_Y_OFFSET, RELOAD_WIDTH, RELOAD_HEIGHT);
                self.spinner.color = [UIColor whiteColor];
                
                [self.view addSubview: self.spinner];
                [self.spinner startAnimating];
            }
            else { self.spinner.hidden = NO; }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), 
            ^{
                // Dispatch a global thread for the work of fetching data from each feed
                // UI updates are done in bulk once all the work is done
                [self fullReload];

                // Dispatch back on the main thread (mandatory for UI updates)
                dispatch_async(dispatch_get_main_queue(), 
                ^{
                    // Inside fullReload() the datasource (i.e. the channels array) is updated with the
                    // appropriate number of unviewed videos, with reloadData() this update is reflected in
                    // the UI by effectivly calling the tableview cell-adding functions anew
                    [self.channelView reloadData];
                    self.reloadBtn.hidden = NO;
                    self.spinner.hidden = YES;
                });
            });
        } 
        else
        // Make the marked videos in the view unmarked and vice versa
        { 
            if ( [self.handler openDatabase] == SQLITE_OK )
            {    
                // Deduce the channel owner_id from the channel name
                NSUInteger owner_index = [[self.channels valueForKey:@"name"] indexOfObject: self.currentViewFlag];
                
                // Update the backend status
                [self.handler toggleViewedVideos: @ALL_TITLE owner_id:  [[self.channels objectAtIndex: owner_index] id]  ];
                
                for (int i = 0; i < self.videos.count; i++)
                // Update the UI
                {
                    [[self.videos objectAtIndex:i] toggleViewedAttr];
                }

                [self.videoView reloadData];
            } 
        
            [self.handler closeDatabase]; 
        }
        
    }

    -(void) goBack: (UIButton*)sender 
    // When the back button is tapped from a video view
    // unhide the channels view and delete the button and video view (for the specific channel)
    {
        //--- Update the number of unviewed videos for the channel datasource ---//
        int unviewedCount = VIDEOS_PER_CHANNEL;
        for (int i=0; i<self.videos.count; i++) { unviewedCount = unviewedCount - [[self.videos objectAtIndex:i] viewed]; }

        NSUInteger channel_index = [  [self.channels valueForKey:@"name"] indexOfObject: self.currentViewFlag];
        NSLog(@"%@:%lu", self.currentViewFlag, channel_index);
        [[self.channels objectAtIndex: channel_index] setUnviewedCount: unviewedCount]; 
        
        // Sort the datasource
        NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"unviewedCount" ascending:NO]];
        self.channels = (NSMutableArray*)[self.channels sortedArrayUsingDescriptors:descriptor];
        
        //-----------------------------------------------------------------------//

        // Remove the video view from the View controller 
        [self.videoView removeFromSuperview];
        [sender removeFromSuperview];
        
        self.currentViewFlag = @CHANNEL_VIEW;
        [self.reloadBtn setImage: getImage( @RELOAD_IMAGE, RELOAD_WIDTH, RELOAD_HEIGHT ) forState:UIControlStateNormal];
        self.channelView.hidden = NO;

        // Reload the datasource on going back to display potential changes of the number of viewed videos
        [self.channelView reloadData];
    }

    -(void) fullReload
    // Executed as a background task
    {
        int unviewedCount = -1;
        
        // Descriptor array for sorting purposes
        NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"unviewedCount" ascending:NO]];
        
        if ( [self.handler openDatabase] == SQLITE_OK )
        {
            for (int i = 0; i < self.channels.count; i++)
            {
                unviewedCount = VIDEOS_PER_CHANNEL; 
                
                self.videos = [[NSMutableArray alloc] init];

                // Import videos for the given channel into the database ( implicit calls to addVideo() )
                [self.handler importRSS: [ [[self.channels objectAtIndex:i] name] cStringUsingEncoding: NSUTF8StringEncoding]];

                // Fetch video objects from the given channel from the database
                [self.handler getVideosFrom: [ [[self.channels objectAtIndex:i] name] cStringUsingEncoding: NSUTF8StringEncoding] count: VIDEOS_PER_CHANNEL videos:self.videos ];

                // Set the channel objects unviewed count based upon the number derived
                // after the RSS fetch
                // True: 1      False: 0
                for (int i=0; i<self.videos.count; i++) { unviewedCount = unviewedCount - [[self.videos objectAtIndex:i] viewed]; }

                [[self.channels objectAtIndex:i] setUnviewedCount: unviewedCount];
                
                // Sort the video array based upon the highest number of unviewed videos
                self.channels = (NSMutableArray*)[self.channels sortedArrayUsingDescriptors:descriptor];
            }

            [self.handler closeDatabase]; 
        }
    }

@end