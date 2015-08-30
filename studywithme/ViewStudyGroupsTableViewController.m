#import <BuiltIO/BuiltIO.h>

#import "ViewStudyGroupsTableViewController.h"
#import "StudyGroupsTableViewCell.h"
#import "ViewStudyGroupTabBarController.h"
#import "MessagesViewController.h"

@interface ViewStudyGroupsTableViewController ()
@property (strong, nonatomic) NSArray *otherStudyGroups;
@property (strong, nonatomic) NSArray *myStudyGroups;
@property (strong, nonatomic) NSArray *futureStudyGroups;
@property (strong, nonatomic) NSArray *sectionsData;

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
    _myStudyGroups = tabVC.myStudyGroups;
    _otherStudyGroups = tabVC.otherStudyGroups;
    _futureStudyGroups = tabVC.futureStudyGroups;
    _sectionsData = @[_myStudyGroups, _otherStudyGroups, _futureStudyGroups];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return MAX(1, [(NSArray *)[_sectionsData objectAtIndex:section] count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *studyGroups = [_sectionsData objectAtIndex:indexPath.section];
    if ([studyGroups count] == 0) {
        return [self createDefaultCellForIndexPath:indexPath tableView:tableView];
    } else {
        return [self createStudyGroupCellForIndexPath:indexPath tableView:tableView];
    }
}

- (UITableViewCell *)createDefaultCellForIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    static NSString *defaultCellIdentifier = @"DefaultCell";
    // Show default message
    UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:defaultCellIdentifier];
    if (defaultCell == nil) {
        defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIdentifier];
        defaultCell.selectionStyle = UITableViewCellSelectionStyleNone;
        defaultCell.textLabel.numberOfLines = 2;
    }
    
    if (indexPath.section == 0) {
        defaultCell.textLabel.text = @"You haven't created any study groups yet.";
    } else if (indexPath.section == 1) {
        defaultCell.textLabel.text = @"No other study groups are happening today.";
    } else {
        defaultCell.textLabel.text = @"No upcoming study groups.";
    }
    return defaultCell;

}

- (StudyGroupsTableViewCell *)createStudyGroupCellForIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    static NSString *studyGroupCellIdentifier = @"StudyGroupCell";
    StudyGroupsTableViewCell *cell = (StudyGroupsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:studyGroupCellIdentifier];
    
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    
    NSArray *studyGroups = [_sectionsData objectAtIndex:indexPath.section];
    NSDictionary *data = [studyGroups objectAtIndex:indexPath.row];

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
    
    NSString *dateTimeFormatString;
    
    if ([[data objectForKey:@"start_date"] isEqualToString:[data objectForKey:@"end_date"]]) {
        dateTimeFormatString = @"%@ %@ - %@";
    } else {
        dateTimeFormatString = @"%@ %@ - %@ (+1)";
    }

    NSDate *startDate = [dateFormatter dateFromString:[data objectForKey:@"start_date"]];
    
    cell.timeLabel.text = [NSString stringWithFormat:dateTimeFormatString, [Helper getShortWeekdayFromDate:startDate], [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"My study groups";
    } else if (section == 1) {
        return @"Other study groups happening today";
    } else {
        return @"Upcoming study groups";
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

- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.35 green:0.54 blue:0.83 alpha:1.0]
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
    
    [self performSegueWithIdentifier: @"messages" sender: self];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"%@", self.tableView.indexPathForSelectedRow);
    
    if ([segue.identifier isEqualToString:@"create"]) {
        CreateStudyGroupTableViewController *vc = [segue destinationViewController];
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        vc.presenter = (ViewStudyGroupTabBarController *)self.tabBarController;
         NSDictionary *studyGroup = [[_sectionsData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        vc.studyGroup = studyGroup;
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
