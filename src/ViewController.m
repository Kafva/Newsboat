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
        [self addTableView];
    }

    - (void)viewDidLoad 
    {
        
        // The super keyword will go up the class hierachy and execute the specified method (viewDidLoad)
        // once a superclass which implements it is encountered
        [super viewDidLoad];

        NSString* home = NSHomeDirectory();
        NSMutableString* dbPath =[[NSMutableString alloc] initWithCString: DB_PATH encoding:NSASCIIStringEncoding];
        [dbPath insertString: home atIndex:(NSUInteger)0];

        DBHandler* handler = [[DBHandler alloc] initWithDB: dbPath];
        if ( [handler openDatabase] == SQLITE_OK )
        {
            [handler importRSS];
            
            self.tableData = [[NSMutableArray alloc] init];
            NSMutableArray* videos = [[NSMutableArray alloc] init];

            [handler getVideosFrom: "Eye" count:TABLE_ROWS videos:videos];

            for (int i=0; i<videos.count; i++)
            {
                NSLog(@"%@", videos[i]);
                [self.tableData addObject: [videos[i] description] ];
                //[self.tableDetailData addObject:tableDetailData];
            }

            [handler closeDatabase]; 
        }
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
    
    -(void)addTableView
    {
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height - 50;
        CGRect tableFrame = CGRectMake(0, 0, width, height);

        self.tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newCell"];
        

        //tableView.rowHeight = 45;
        //tableView.sectionFooterHeight = 22;
        //tableView.sectionHeaderHeight = 22;
        //tableView.scrollEnabled = YES;
        //tableView.showsVerticalScrollIndicator = YES;
        //tableView.userInteractionEnabled = YES;
        //tableView.bounces = YES;

        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview: self.tableView];
    }

    //------------ TABLE -------------------//
    // https://gist.github.com/keicoder/8682867 

    // Required functions for the dataSource and delegate implemntations of the 
    // <UITableViewDataSource, UITableViewDelegate>  protocols
    -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    // Called when adding a new cell to the tableView
    {
        // Deque an unusued cell object based on the static cellIdentifier
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }

        // Clear background
        cell.backgroundColor = [UIColor clearColor];

        cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor whiteColor];

        cell.detailTextLabel.text = [self.tableDetailData objectAtIndex:indexPath.row]; 
        cell.detailTextLabel.textColor = [UIColor whiteColor]; 

        
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
        return [self.tableData count];
    }

    -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    // Called when a row is selected
    {
        NSLog(@"Table row %ld has been tapped", indexPath.row);
    }        

    -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    // Returns the desired height of each row
    {
        return 70;
    }

@end
