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

        [self addTableView];
    }

    - (void)viewDidLoad 
    {
        
        // The super keyword will go up the class hierachy and execute the specified method (viewDidLoad)
        // once a superclass which implements it is encountered
        [super viewDidLoad];

        self.tableData = [[NSMutableArray alloc] init];
        self.tableDetailData = [[NSMutableArray alloc] init];
        
        for (NSUInteger i=0; i < 10; i++) 
        {
            NSString *tableData = [NSString stringWithFormat:@"Item %lu", i];
            NSString *tableDetailData = [NSString stringWithFormat:@"Detail Item %lu", i];
            [self.tableData addObject:tableData];
            [self.tableDetailData addObject:tableDetailData];
        }
        NSLog(@"The tableData array contains %@", self.tableData);
        NSLog(@"The tableDetailData array contains %@", self.tableData);
        
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
    
    -(void)addTableView
    {
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height - 50;
        CGRect tableFrame = CGRectMake(0, 60, width, height);

        self.tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newCell"];
        

        //tableView.rowHeight = 45;
        //tableView.sectionFooterHeight = 22;
        //tableView.sectionHeaderHeight = 22;
        //tableView.scrollEnabled = YES;
        //tableView.showsVerticalScrollIndicator = YES;
        //tableView.userInteractionEnabled = YES;
        //tableView.bounces = YES;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview: self.tableView];
    }

    //------------ TABLE -------------------//
    // https://gist.github.com/keicoder/8682867 

    // Required functions for the dataSource and delegate implemntations of the 
    // <UITableViewDataSource, UITableViewDelegate>  protocols
    -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }

        cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row]; 
        cell.detailTextLabel.text = [self.tableDetailData objectAtIndex:indexPath.row]; 
        
        return cell;
    }

    -(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    {
        return 1;
    }
    
    -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        return [self.tableData count];
    }

    -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    {
        NSLog(@"Table row %ld has been tapped", indexPath.row);
        
        //NSString *messageString = [NSString stringWithFormat:@"You tapped row %ld",indexPath.row];
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row tapped"
        //                                                message:messageString
        //                                            delegate:nil
        //                                    cancelButtonTitle:@"OK"
        //                                    otherButtonTitles: nil];
        //[alert show];
    }

    -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        return 80;
    }

@end
