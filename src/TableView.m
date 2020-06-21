@interface TableViewController () <UITableViewDataSource, UITableViewDelegate>
    @property (strong, nonatomic) UITableView *tableView;
@end

@implementation TableViewController

    -(UITableView *)makeTableView
    {
        CGFloat x = 0;
        CGFloat y = 50;
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height - 50;
        CGRect tableFrame = CGRectMake(x, y, width, height);

        UITableView *tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];

        tableView.rowHeight = 45;
        tableView.sectionFooterHeight = 22;
        tableView.sectionHeaderHeight = 22;
        tableView.scrollEnabled = YES;
        tableView.showsVerticalScrollIndicator = YES;
        tableView.userInteractionEnabled = YES;
        tableView.bounces = YES;

        tableView.delegate = self;
        tableView.dataSource = self;

        return tableView;
    }

    - (void)viewDidLoad
    {
        [super viewDidLoad];
        self.tableView = [self makeTableView];
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"newFriendCell"];
        [self.view addSubview:self.tableView];
    }

    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        static NSString *CellIdentifier = @"newFriendCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

        if (cell == nil) 
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }

        Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];

        //THIS DATA APPEARS**
        cell.textLabel.text = friend.name;
        cell.textLabel.font = [cell.textLabel.font fontWithSize:20];
        cell.imageView.image = [UIImage imageNamed:@"icon57x57"];

        //THIS DATA DOES NOT APPEAR**
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Games", friend.gameCount];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];

        return cell;
    }

    -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    {
        [self performSegueWithIdentifier:@"detailsView" sender:self];
    }
@end