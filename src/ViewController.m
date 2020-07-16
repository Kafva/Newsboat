#import "ViewController.h"

@implementation ViewController 
    //************* BASICS ******************************//

    - (void)loadView 
    {
        // Call the mainScreen method of UIScreen
        // NOTE that we need to connect each view with the rectangle created with
        // the application frame
        CGRect rect = [UIScreen mainScreen].bounds;
        
        self.view = [[UIView alloc] initWithFrame:rect];
        self.view.backgroundColor = [UIColor blackColor];
        
        //*** Initialise properties ***//
        NSString* home = NSHomeDirectory();
        NSMutableString* dbPath =[[NSMutableString alloc] initWithCString: DB_PATH encoding:NSUTF8StringEncoding];
        [dbPath insertString: home atIndex:(NSUInteger)0];
        
        self.dbHandler = [[Handler alloc] initWithDB: dbPath];
        self.videos = [[NSMutableArray alloc] init];
        self.channels = [[NSMutableArray alloc] init];

        [self initSpinner];
        //******************************//

        // Register the ViewController as an observer for notifcations with the name in SINGLE_NOTE, thanks to this
        // we can send out a notification from the Handler after an RSS fetch completes and the datasource 
        // has become populated, letting the ViewController take care of the corresponding UI changes 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentVideos:) name:@SINGLE_NOTE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishFullReload:) name:@FULL_NOTE object:nil];

        // Note the order in which the views are added (they stack on top of each other)
        [self addImageView];
        [self addChannelView];

        // Positioning of the reload button is not well made
        self.reloadBtn = [self getButtonView: @RELOAD_IMAGE selector: @selector(rightBtn:) width: RELOAD_WIDTH height: RELOAD_HEIGHT x_offset: BTN_X_OFFSET y_offset: BTN_Y_OFFSET ];
        [self.view addSubview: [self reloadBtn]];

        [self addSearchBar];

        // Loading label
        self.loadingLabel = getLabel(@"(?)", LOADING_WIDTH, LABEL_HEIGHT, LOADING_LABEL_X, BTN_Y_OFFSET, [[UIColor alloc] initWithWhite:1 alpha:0.6 ], [UIFont fontWithName: @BOLD_FONT size:FONT_SIZE]  );
        self.loadingLabel.hidden = YES;
        [self.view addSubview: [self loadingLabel]];

        // Spinner    
        self.spinner.hidden = YES;
        [self.view addSubview: [self spinner]];

        // Back button
        self.backBtn = [self getButtonView: @BACK_IMAGE selector: @selector(goBack:) width: BACK_WIDTH height: BACK_HEIGHT x_offset:0 y_offset:BTN_Y_OFFSET ];
        self.backBtn.hidden = YES; 
        [self.view addSubview: [self backBtn]];
    }
    
    -(void) viewDidLoad 
    {
        // The super keyword will go up the class hierachy and execute the specified method (viewDidLoad)
        // once a superclass which implements it is encountered
        [super viewDidLoad];
    }
    
    -(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
        // ViewController method to resign the first responder status of the searchbar
        // when touching any area of the view which will hide the keyboard
        [self.searchBar resignFirstResponder];
    }
    
    //************ NOTIFICATIONS *****************//

    -(void) finishFullReload: (NSNotification*)notification
    {
        NSLog(@"Reload: (%d / %lu)", self.dbHandler.channelCnt, self.channels.count);
        self.loadingLabel.text = [NSString stringWithFormat: @"(%d/%lu)", self.dbHandler.channelCnt, self.channels.count];
        
        if ( self.dbHandler.channelCnt == self.channels.count )
        {
            NSLog(@"Finished full reload!");
            NSLog(@"CACHE: %@\nCount: %lu", self.channelsCache, self.channelsCache.count);
            
            [self.channelView reloadData];

            self.loadingLabel.hidden = YES;
            self.reloadBtn.hidden = NO;
            self.spinner.hidden = YES;

            self.searchBar.userInteractionEnabled = YES;   
            self.channelView.userInteractionEnabled = YES;
        }
    }

    -(void) presentVideos:(NSNotification*)notification
    {
        // Fetch video objects from the given channel from the database
        //NSLog(@"BEFORE FETCH VIDS: %@", self.videos);
        [self.dbHandler getVideosFrom: [self.currentViewFlag cStringUsingEncoding: NSUTF8StringEncoding] count: VIDEOS_PER_CHANNEL videos:self.videos ];
        NSLog(@"AFTER getVideosFrom() VIDS: %@", self.videos);
        
        self.channelView.userInteractionEnabled = YES;
        self.searchBar.userInteractionEnabled = YES;   
        
        self.searchBar.hidden = YES;
        self.channelView.hidden = YES;
        [self.reloadBtn setImage: getImage( @OK_IMAGE, RELOAD_WIDTH, RELOAD_HEIGHT ) forState:UIControlStateNormal];

        [self addVideoView: self.currentViewFlag];
        
        self.backBtn.hidden = NO;
        self.reloadBtn.hidden = NO; 
        self.spinner.hidden = YES;

    }

    //************* ADDING VIEWS **********************//

    -(UIButton*) getButtonView:(NSString*)btnStr selector:(SEL)selector width:(int)width height:(int)height x_offset:(int)x_offset y_offset:(int)y_offset
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
        // Decrement the tableframe slightly to avoid having the last entry partially obscured
        CGRect tableFrame = CGRectMake(0, Y_OFFSET, self.view.frame.size.width, self.view.frame.size.height - 50);

        self.channelView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.channelView registerClass:[Cell class] forCellReuseIdentifier:@CELL_IDENTIFIER];
        
        self.channelView.backgroundColor = [UIColor clearColor];
        self.channelView.delegate = self;
        self.channelView.dataSource = self;
        [self.view addSubview: self.channelView];
        self.currentViewFlag = @CHANNEL_VIEW;

        [self.channelView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        
        // Populate the datasource
        [self channelSearch: @ALL_TITLE];
    }
    
    -(void) addVideoView: (NSString*) channel
    {
        CGRect tableFrame = CGRectMake(0, Y_OFFSET*1.5, self.view.frame.size.width, self.view.frame.size.height);

        self.videoView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.videoView registerClass:[Cell class] forCellReuseIdentifier:@CELL_IDENTIFIER];

        self.videoView.backgroundColor = [UIColor clearColor];
        self.videoView.delegate = self;
        self.videoView.dataSource = self;
        [self.view addSubview: self.videoView];
        
        [self.videoView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    }

    -(void) addSearchBar
    {
        self.searchBar = [[UISearchBar alloc] init]; 
        
        // Minimal style gives transparancy
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchBar.barStyle = UIBarStyleBlack;
        
        // Without setting the delegate the bar won't call the delegate functions defined
        // for the <UISearchBarDelegate> protocol
        self.searchBar.delegate = self;
        
        [self.searchBar setFrame: CGRectMake(SEARCH_X_OFFSET,BTN_Y_OFFSET,SEARCH_WIDTH,RELOAD_HEIGHT)];
        self.searchBar.tintColor = [[UIColor alloc] initWithRed:(CGFloat)RED green:(CGFloat)GREEN blue:(CGFloat)BLUE alpha:(CGFloat)1.0 ];
        
        [self.view addSubview: [self searchBar]];
    }

    -(void) addVideoBtn: (Cell*)cell viewed:(bool)viewed owner_id:(int)owner_id
    {
        // Create the 'viewed' toggle button depending on the viewed attribute from the videos array
        if (cell.videoBtn == nil)
        // Only create and add a new toggle button to the cells view if the reused cell doesn't have one
        {
            NSLog(@"Adding new button: %@", cell.videoBtn);

            cell.videoBtn = [CellButton buttonWithType: UIButtonTypeSystem];
            [cell.videoBtn setFrame:CGRectMake(BTN_X_OFFSET, BTN_Y_OFFSET, CELL_BTN_WIDTH, CELL_BTN_HEIGHT)];
            
            //**** NOTE **** that the target needs to be the ViewController (self)
            [cell.videoBtn addTarget:self action:@selector(toggleViewed:) forControlEvents:UIControlEventTouchUpInside ];
            
            [cell.contentView addSubview: [cell videoBtn]];
        }
        
        NSLog(@"Setting new button: %@ (viewed: %d)", cell.videoBtn, viewed);
        
        cell.videoBtn.title = cell.title;
        cell.videoBtn.owner_id = owner_id;
        
        
        cell.videoBtn.viewed = viewed;

        // Set the image depending on the videoBtn 'viewed' attribute
        [cell.videoBtn setStatusImage];

    }
    
    -(void) addChannelBtn: (Cell*)cell
    {
        if (cell.channelBtn == nil)
        // Only create and add a new toggle button to the cells view if the reused cell doesn't have one
        {
            NSLog(@"Adding new button: %@", cell.channelBtn);

            cell.channelBtn = [CellButton buttonWithType: UIButtonTypeSystem];
            [cell.channelBtn setFrame:CGRectMake(BTN_X_OFFSET, BTN_Y_OFFSET, CELL_BTN_WIDTH, CELL_BTN_HEIGHT)];
            
            //**** NOTE **** that the target needs to be the ViewController (self)
            [cell.channelBtn addTarget:self action:@selector(channelRightBtn:) forControlEvents:UIControlEventTouchUpInside ];
            [cell.contentView addSubview: [cell channelBtn]];
        }
        
        NSLog(@"Setting new button: %@", cell.channelBtn);
        
        cell.channelBtn.title = cell.title;
        [cell.channelBtn setChannelImage];
    }
    
    //******************** MISC *************************//

    -(void) fetchVideos: (NSString*)channel
    {
        [self.videos removeAllObjects];
        
        self.dbHandler.noteFlag = SINGLE_FLAG;

        // Import videos for the given channel into the database ( implicit calls to addVideo() )
        [self.dbHandler importRSS: [channel cStringUsingEncoding: NSUTF8StringEncoding]];
    }

    -(void) updateCache: (NSString*)name
    // Called after setting the currentViewFlag to the corresponding channel name and passing it as an argument
    {
        if ( self.channelsCache == nil )
        // If the cache hasn't been created yet (i.e. no fullReload() has been done) create it 
        { 
            self.channelsCache = [[NSMutableArray alloc] init]; 
        }
        
        NSUInteger index = [[self.channels valueForKey:@"name"] indexOfObject: name];
        NSUInteger cache_index = [[self.channelsCache valueForKey:@"name"] indexOfObject: name];
        
        if ( cache_index == NSNotFound )
        // If the channel doesn't exist in the cache add it
        {
            [self.channelsCache addObject: self.channels[index] ];
            NSLog(@"Added to cache: %@", self.channelsCache);
        }
        else if ( index != NSNotFound )
        // Otherwise use the index of the current channel and update its unviewedCount in the existing cache
        // provided that the search didn't fail
        {
            [self.channelsCache[cache_index] setUnviewedCount: [self.channels[index] unviewedCount] ];
            NSLog(@"Update single: channels[%lu] =  %@: cache[%lu] = %@", index, self.channels[index], cache_index , self.channelsCache[cache_index]); 

        }
    }

    -(void) getUnviewedCountFromCache
    // Go through each channel object and retain the unviewedCount attribute from the cache if one exists 
    {
        if ( self.channelsCache != nil )
        {
            NSUInteger cache_index = NSNotFound;

            for (int i=0; i < self.channels.count; i++)
            {
                if( [self.channels[i] unviewedCount] == -1)
                // If the channel object has an unset view count search for the channel with the same name
                // in the cache and retain the value (if one exists)
                {
                    cache_index = [[self.channelsCache valueForKey:@"name"] indexOfObject: [self.channels[i] name]];
                    NSLog(@"Update all: %@: %lu", [self.channels[i] name], cache_index);
                    if (cache_index != NSNotFound)
                    {
                        [self.channels[i] setUnviewedCount: [self.channelsCache[cache_index] unviewedCount] ];
                        NSLog(@"Setting count of %@ to %d", [self.channels[i] name], [self.channelsCache[cache_index] unviewedCount] );
                    }
                }
            }
        }
    }
    
    -(void) initSpinner
    {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.spinner.frame = CGRectMake(BTN_X_OFFSET, BTN_Y_OFFSET, RELOAD_WIDTH, RELOAD_HEIGHT);
        self.spinner.color = [UIColor whiteColor];
    }
    
    -(void) markAllViewed: (NSString*)name
    {
        // Deduce the channel owner_id from the channel name
        NSUInteger owner_index = [[self.channels valueForKey:@"name"] indexOfObject: name];

        if ( [self.currentViewFlag isEqual: @CHANNEL_VIEW] )
        //*** CHANNEL VIEW ***//
        {
            if ( [[self.channels objectAtIndex: owner_index] unviewedCount] != -1 )
            // Only mark videos as unviewed in the channel interface when a remote fetch has been issued
            // i.e. do nothing on '(?)' entries
            {
                // Update the backend status
                [self.dbHandler setAllViewedInDatabase: [[self.channels objectAtIndex: owner_index] id] ];
                
                // Change the unviewedCount attribute to zero in the datasource
                // provided that the number of viewed videos is known
                // and reload the channel view
                [[self.channels objectAtIndex: owner_index] setUnviewedCount: 0 ];
                
                // Update the cached channel entry
                [self updateCache: name];

                [self.channelView reloadData];
            }
        }
        else
        //*** VIDEO VIEW ***//
        {
            // Update the backend status
            [self.dbHandler setAllViewedInDatabase: [[self.channels objectAtIndex: owner_index] id] ];
            
            for (int i = 0; i < self.videos.count; i++)
            // Update the UI
            {
                [[self.videos objectAtIndex:i] setAllViewedAttr: YES];
            }

            [self.videoView reloadData];
        }
    }

    //************** PROTOCOL IMPLEMENTATIONS ****************************//

    //************ TABLES *******************//
    
    -(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    // Called when adding a new cell to the tableView (i.e. on scrolling the tableview)
    {
        // Deque an unusued cell object based on the static @CELL_IDENTIFIER
        // Note that after iOS 5 the method will never return nil but we can check wheter or
        // not a title already exists in which case we DONT want to add more subviews
        // and instead simply change the text being displayed
        Cell *cell = [tableView dequeueReusableCellWithIdentifier:@CELL_IDENTIFIER];
        cell.userInteractionEnabled = YES; 
        
        NSLog(@"Fetching new cell:  %@",cell);
        
        if (cell.title == nil)
        {
            // Set the style value to enable the use of detailTextLabels with 'Value1' instead of 'Default' 
            cell = [cell initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@CELL_IDENTIFIER];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

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
            int unviewedCount = -1;
            
            cell.title = [[self.channels objectAtIndex:indexPath.row] name ]; 
            unviewedCount = [[self.channels objectAtIndex:indexPath.row] unviewedCount];
            
            cell.leftLabel.text = cell.title;
            cell.rightLabel.textColor = [[UIColor alloc] initWithWhite:1 alpha:0.6 ]; 
            
            if ( unviewedCount == -1 ) { cell.rightLabel.text = @"(?)"; }
            else { cell.rightLabel.text = [NSString stringWithFormat: @"(%d/%d)", unviewedCount, VIDEOS_PER_CHANNEL]; }

            // Highlight color when there is at least one new video 
            if ( unviewedCount > 0 )  { cell.rightLabel.textColor = [[UIColor alloc] initWithRed:(CGFloat)RED green:(CGFloat)GREEN blue:(CGFloat)BLUE alpha:(CGFloat)1.0 ]; }

            // Add the 'viewToggle' button for each channel
            [self addChannelBtn: cell];

        }
        else 
        //*** Cell configuration for video view ****//
        { 
            // Set the text of the cell and store the link to the video in a custom property of the cell subclass
            cell.title = [[self.videos objectAtIndex:indexPath.row] title ]; 
            cell.link = [[self.videos objectAtIndex:indexPath.row] link];
            cell.leftLabel.text = cell.title;

            [self addVideoBtn: cell viewed:[[self.videos objectAtIndex:indexPath.row] viewed ] owner_id:[[self.videos objectAtIndex:indexPath.row] owner_id ] ];
        }

        return cell;
    }

    -(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
    // Returns the number of sections in the tableView
    {
        return 1;
    }
    
    -(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    // Returns the number of cells in the tableView section
    {
        if ( tableView == self.channelView )
        { 
            return [self.channels count];
        }
        else { return [self.videos count]; }
    }


    -(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    // Returns the desired height of each row
    {
        return ROW_HEIGHT;
    }

    -(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    //****** Called when a row is selected *******//
    {
        if ( self.channelView == tableView )
        //*** If an entry is tapped from the channel view ***//
        {
            // Disable interactions while loading content
            self.channelView.userInteractionEnabled = NO;
            self.searchBar.userInteractionEnabled = NO;   
            
            // Hide the keyboard if its up
            if( [self.searchBar isFirstResponder] ) { [self.searchBar resignFirstResponder]; }

            // Display the spinner while waiting to enter the video view
            self.reloadBtn.hidden = YES;
            self.spinner.hidden = NO;
            [self.spinner startAnimating];
            
            NSString* channel = [[ tableView cellForRowAtIndexPath: indexPath ] title];
            NSLog(@"Tapped entry[%ld]: %@", indexPath.row, channel);

            // Set the currentViewFlag before entering the view since it is required
            // by the noftication handler. It is also used on exit from a Video view
            // to update the cache
            self.currentViewFlag = channel;

            [self fetchVideos: channel];
        }
        else
        {
            NSString* link = [[tableView cellForRowAtIndexPath: indexPath ] link];
            NSLog(@"Tapped entry[%ld]: %@", indexPath.row, link);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:NULL completionHandler:^(BOOL success) { NSLog(@"opened URL (%d)", success); } ];
        } 
    }        
    
    //*************** BUTTONS ********************// 
    -(void) toggleViewed: (CellButton*) btn 
    {
        if( [self.searchBar isFirstResponder] ) { [self.searchBar resignFirstResponder]; }
        
        // Update the viewed status in the database
        [self.dbHandler toggleViewedInDatabase: btn.title owner_id: btn.owner_id];

        // Update the state of the button in the cell
        btn.viewed = !btn.viewed;

        // Update the viewed status in the videos array
        [[self.videos objectAtIndex: getIndexByNameAndOwnerId( self.videos, btn.title, btn.owner_id ) ] setAllViewedAttr: btn.viewed];
        
        [btn setStatusImage];
    }
    
    -(void) channelRightBtn: (CellButton*) btn
    {
        [self markAllViewed: btn.title];
    }
        
    -(void) rightBtn: (UIButton*)sender
    // Hide button on video view
    {
        if( [self.searchBar isFirstResponder] ) { [self.searchBar resignFirstResponder]; }
        
        if ( [self.currentViewFlag isEqual: @CHANNEL_VIEW] )
        //*** Reload all RSS feeds ***//
        {
            // Disable interactions while loading content
            self.channelView.userInteractionEnabled = NO;
            self.searchBar.userInteractionEnabled = NO;   
            
            // Unhide the spinner and hide the reload button
            self.loadingLabel.text = [NSString stringWithFormat: @"(0/%lu)", self.channels.count];
            self.loadingLabel.hidden = NO;

            self.reloadBtn.hidden = YES;
            self.spinner.hidden = NO;
            [self.spinner startAnimating];
            
            [self fullReload];
        } 
        else
        // Mark all videos as viewed
        { 
            [self markAllViewed: self.currentViewFlag];
        }
        
    }

    -(void) goBack: (UIButton*)sender 
    // When the back button is tapped from a video view
    // unhide the channels view and delete the button and video view (for the specific channel)
    {
        if( [self.searchBar isFirstResponder] ) { [self.searchBar resignFirstResponder]; }
        
        //*** Update the number of unviewed videos for the channel datasource ***//
        int unviewedCount = VIDEOS_PER_CHANNEL;
        for (int i=0; i<self.videos.count; i++) { unviewedCount = unviewedCount - [[self.videos objectAtIndex:i] viewed]; }

        NSUInteger channel_index = [  [self.channels valueForKey:@"name"] indexOfObject: self.currentViewFlag];
        //NSLog(@"currentView:channel_index - %@:%lu", self.currentViewFlag, channel_index);
        
        [[self.channels objectAtIndex: channel_index] setUnviewedCount: unviewedCount]; 
        
        // Update the channels cache with unviewedCount information
        [self updateCache: self.currentViewFlag];

        // Sort the datasource
        NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"unviewedCount" ascending:NO]];
        self.channels = (NSMutableArray*)[self.channels sortedArrayUsingDescriptors:descriptor];
        
        //***********************************************************************//

        // Remove the video view from the View controller 
        [self.videoView removeFromSuperview];
        sender.hidden = YES;
        
        self.currentViewFlag = @CHANNEL_VIEW;
        [self.reloadBtn setImage: getImage( @RELOAD_IMAGE, RELOAD_WIDTH, RELOAD_HEIGHT ) forState:UIControlStateNormal];
        self.channelView.hidden = NO;
        self.searchBar.hidden = NO;

        // Reload the datasource on going back to display potential changes of the number of viewed videos
        [self.channelView reloadData];
    }

    -(void) fullReload
    // Executed as a background task
    {
        // Set the channel count and dbHandler notifcation flag
        // to update the UI only when neccessary
        self.dbHandler.channelCnt = 0;
        self.dbHandler.noteFlag = FULL_FLAG;

        int unviewedCount = -1;
        
        // Descriptor array for sorting purposes
        NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"unviewedCount" ascending:NO]];
        
        for (int i = 0; i < self.channels.count; i++)
        {
            unviewedCount = VIDEOS_PER_CHANNEL; 
            
            self.videos = [[NSMutableArray alloc] init];

            // Import videos for the given channel into the database ( implicit calls to addVideo() )
            [self.dbHandler importRSS: [ [[self.channels objectAtIndex:i] name] cStringUsingEncoding: NSUTF8StringEncoding]];

            // Fetch video objects from the given channel from the database
            [self.dbHandler getVideosFrom: [ [[self.channels objectAtIndex:i] name] cStringUsingEncoding: NSUTF8StringEncoding] count: VIDEOS_PER_CHANNEL videos:self.videos ];

            // Set the channel objects unviewed count based upon the number derived
            // after the RSS fetch
            // True: 1      False: 0
            for (int j=0; j<self.videos.count; j++) { unviewedCount = unviewedCount - [[self.videos objectAtIndex:j] viewed]; }

            [[self.channels objectAtIndex:i] setUnviewedCount: unviewedCount];
            
        }
        
        // Sort the video array based upon the highest number of unviewed videos
        self.channels = (NSMutableArray*)[self.channels sortedArrayUsingDescriptors:descriptor];

        // Lastly, save the results of the RSS fetch in the channels cache memory
        self.channelsCache = [NSMutableArray arrayWithArray:self.channels];
    }

    //*********** SEARCH BAR **************//
    // The search functionality doesn't save fetched RSS data, this looks bad when using the app
    // but also ensures that old reads are never made

    -(void) searchBar:(UISearchBar*) searchBar textDidChange:(NSString*) searchText 
    {
        // Empty the datasource before filling it agian
        self.channels = [[NSMutableArray alloc] init];
        [self.channelView reloadData];

        // Sanitize input before issuing the database query
        [self channelSearch: sanitize( (NSMutableString*)searchText) ];
    }

    -(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
    {
        if( [self.searchBar isFirstResponder] ) { [self.searchBar resignFirstResponder]; }
        
        // Query for all the channels when cancelling
        self.channels = [[NSMutableArray alloc] init]; 
        [self channelSearch: @ALL_TITLE];
    }

    -(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
    {
        // Since we issue a search automatically on each new character we don't need to issue one agian
        // when the searchbutton is pressed
        if( [self.searchBar isFirstResponder] ) { [self.searchBar resignFirstResponder]; } 
    }
    
    -(void) channelSearch:(NSString*) searchText
    // Search for the given channel(s) in the database and update the UI accordingly
    {
        
        if ([searchText isEqual: @ALL_TITLE]) { [self.dbHandler getChannels: self.channels]; }
        else
        { 
            [self.dbHandler getChannels: self.channels name: searchText]; 
        }

        // Update the newly fetched channels with the unviewedCount attributes from the cache
        [self getUnviewedCountFromCache];
        
        // Sort the datasource
        NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"unviewedCount" ascending:NO]];
        self.channels = (NSMutableArray*)[self.channels sortedArrayUsingDescriptors:descriptor];
        
        [self.channelView reloadData];
    }

@end
