//
//  ViewClassesTableViewController.m
//  studywithme
//
//  Created by Alice J. Liu on 2014-10-25.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "ViewStudyGroupsTableViewController.h"
#import "StudyGroupsTableViewCell.h"
#import <BuiltIO/BuiltIO.h>
#import "ViewStudyGroupTabBarController.h"

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
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:studyGroupCellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:defaultCellIdentifier];
    if (defaultCell == nil) {
        defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIdentifier];
    }
    
    NSDictionary *data;
    
    if (indexPath.section == 0) {
        if ([_myStudyGroups count] == 0) {
            defaultCell.textLabel.text = @"You haven't created any study groups yet.";
            return defaultCell;
        }
        data = [_myStudyGroups objectAtIndex:indexPath.row];
        cell.editButton.hidden = NO;
        [cell.editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        if ([_otherStudyGroups count] == 0) {
            defaultCell.textLabel.text = @"There are no study groups happening now.";
            return defaultCell;
        }
        data = [_otherStudyGroups objectAtIndex:indexPath.row];
        cell.editButton.hidden = YES;
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
         cell.timeLabel.text = [NSString stringWithFormat:@"%@ to %@", [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
    } else {
        cell.timeLabel.text = [NSString stringWithFormat:@"%@ to %@ (+1)", [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Can only edit your own study groups.
    if(indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
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
    }
}

# pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StudyGroupsTableViewCell *cell = (StudyGroupsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *description = [NSString stringWithFormat:@"%@ - %@", cell.classNameLabel.text, cell.timeLabel.text];
    [[NSUserDefaults standardUserDefaults] setObject:description forKey:@"study_group_title"];
    NSString *uid;
    
    if (indexPath.section == 0) {
        uid = [[_myStudyGroups objectAtIndex:indexPath.row] objectForKey:@"uid"];
    } else {
        uid = [[_otherStudyGroups objectAtIndex:indexPath.row] objectForKey:@"uid"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"study_group_uid"];
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
    }
}

# pragma mark - Actions

- (void)editButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"create" sender:sender];
}

@end
