#import <BuiltIO/BuiltIO.h>

#import "ViewStudyGroupsTableViewController.h"
#import "StudyGroupsTableViewCell.h"
#import "ViewStudyGroupTabBarController.h"
#import "MessagesViewController.h"

@interface ViewStudyGroupsTableViewController ()
@property (strong, nonatomic) NSArray *otherStudyGroups;
@property (strong, nonatomic) NSArray *myStudyGroups;

@end

@implementation ViewStudyGroupsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StudyGroupCell" bundle:nil] forCellReuseIdentifier:@"StudyGroupCell"];
    
    // Listens for notifications from ViewStudyGroupTabBarController to get data.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpData) name:@"MyDataChangedNotification" object:nil];
    
    // In case we miss the notification.
    [self setUpData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUpData {
    ViewStudyGroupTabBarController *tabVC = (ViewStudyGroupTabBarController *)self.tabBarController;
    _otherStudyGroups = tabVC.otherStudyGroups;
    _myStudyGroups = tabVC.myStudyGroups;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        if ([_myStudyGroups count] == 0) {
            return 1;
        }
        return [_myStudyGroups count];
    }
    if ([_otherStudyGroups count] == 0) {
        return 1;
    }
    return [_otherStudyGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *studyGroupCellIdentifier = @"StudyGroupCell";
    static NSString *defaultCellIdentifier = @"DefaultCell";
    
    StudyGroupsTableViewCell *cell = (StudyGroupsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:studyGroupCellIdentifier];
    
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    
    UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:defaultCellIdentifier];
    if (defaultCell == nil) {
        defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIdentifier];
        defaultCell.selectionStyle = UITableViewCellSelectionStyleNone;
        defaultCell.textLabel.numberOfLines = 2;
    }
    
    NSDictionary *data;
    
    if (indexPath.section == 0) {
        if ([_myStudyGroups count] == 0) {
            defaultCell.textLabel.text = @"You haven't created any study groups yet.";
            return defaultCell;
        }
        data = [_myStudyGroups objectAtIndex:indexPath.row];
    } else {
        if ([_otherStudyGroups count] == 0) {
            defaultCell.textLabel.text = @"No other study groups are happening now.";
            return defaultCell;
        }
        data = [_otherStudyGroups objectAtIndex:indexPath.row];
    }
    
    if (indexPath.row % 2 == 0) {
        cell.classNameLabel.backgroundColor = [UIColor colorWithRed:1 green:0.8 blue:0.43 alpha:1.0];
        cell.classNameLabel.textColor = [UIColor blackColor];
    } else {
        cell.classNameLabel.backgroundColor = [UIColor colorWithRed:0.35 green:0.54 blue:0.83 alpha:1.0];
        cell.classNameLabel.textColor = [UIColor whiteColor];
    }
    
    cell.classNameLabel.text = [data objectForKey:@"course"];
    cell.locationLabel.text = [data objectForKey:@"location"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if ([[dateFormatter stringFromDate:[NSDate date]] isEqualToString:[data objectForKey:@"end_date"]]) {
        if ([[dateFormatter stringFromDate:[NSDate date]] isEqualToString:[data objectForKey:@"start_date"]]) {
            cell.timeLabel.text = [NSString stringWithFormat:@"%@ - %@", [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
        } else {
            cell.timeLabel.text = [NSString stringWithFormat:@"%@ (-1) - %@", [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
        }
    } else {
        cell.timeLabel.text = [NSString stringWithFormat:@"%@ - %@ (+1)", [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"My study groups";
    } else {
        return @"Other study groups";
    }
}

// prevent cell(s) from displaying left/right utility buttons
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state {
    // Can only edit your own study groups.
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if([_myStudyGroups count] != 0 && indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self editButtonPressed];
            break;
        case 1:
        {
            // Delete the row from the data source
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

            BuiltObject *obj = [BuiltObject objectWithClassUID:@"study_group"];
            [obj setUid:[[_myStudyGroups objectAtIndex:indexPath.row] objectForKey:@"uid"]];
            
            [obj destroyOnSuccess:^{
                ViewStudyGroupTabBarController *tabVC = (ViewStudyGroupTabBarController *)self.tabBarController;
                [tabVC updateBuiltQuery];
            } onError:^(NSError *error) {
                // there was an error in deleting the object
                // error.userinfo contains more details regarding the same
                [Helper alertToCheckInternet];
                NSLog(@"%@", error.userInfo);
            }];
            break;
        }
        default:
            break;
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.40f green:0.60f blue:0.89f alpha:1.0]
                                                title:@"Edit"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

# pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tableView cellForRowAtIndexPath:indexPath].selectionStyle == UITableViewCellSelectionStyleNone) {
        return;
    }
    
    NSString *uid;
    NSDictionary *data;
    
    if (indexPath.section == 0) {
        uid = [[_myStudyGroups objectAtIndex:indexPath.row] objectForKey:@"uid"];
        data = [_myStudyGroups objectAtIndex:indexPath.row];
    } else {
        uid = [[_otherStudyGroups objectAtIndex:indexPath.row] objectForKey:@"uid"];
        data = [_otherStudyGroups objectAtIndex:indexPath.row];
    }
    
    NSString *description = [NSString stringWithFormat:@"%@ from %@ to %@", [data objectForKey:@"course"], [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
    
    [self performSegueWithIdentifier: @"messages" sender: self];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"create"]) {
        CreateStudyGroupTableViewController *vc = [segue destinationViewController];
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        vc.presenter = (ViewStudyGroupTabBarController *)self.tabBarController;
        if (indexPath.section == 0) {
            vc.studyGroup = [_myStudyGroups objectAtIndex:indexPath.row];
        } else {
            vc.studyGroup = [_otherStudyGroups objectAtIndex:indexPath.row];
        }
    } else if ([segue.identifier isEqualToString:@"messages"]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        NSDictionary *studyGroupData;
        if (indexPath.section == 0) {
            studyGroupData = [_myStudyGroups objectAtIndex:indexPath.row];
        } else {
            studyGroupData = [_otherStudyGroups objectAtIndex:indexPath.row];
        }
        
        MessagesViewController *controller = (MessagesViewController *)segue.destinationViewController;
        controller.studyGroup = studyGroupData;
    }
}

# pragma mark - Actions

- (void)editButtonPressed {
    [self performSegueWithIdentifier:@"create" sender:nil];
}

@end
