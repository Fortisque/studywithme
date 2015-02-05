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
#import "ViewStudyGroupTabViewController.h"

@interface ViewStudyGroupsTableViewController ()
@property (strong, nonatomic) NSArray *otherStudyGroups;
@property (strong, nonatomic) NSArray *myStudyGroups;

@end

@implementation ViewStudyGroupsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setUpData:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // subscribe to a specific notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpData:) name:@"MyDataChangedNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // do not forget to unsubscribe the observer, or you may experience crashes towards a deallocated observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUpData:(NSNotification *)notification
{
    ViewStudyGroupTabViewController *tabVC = (ViewStudyGroupTabViewController *)self.tabBarController;
    _otherStudyGroups = tabVC.otherStudyGroups;
    _myStudyGroups = tabVC.myStudyGroups;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return [_myStudyGroups count];
    }
    return [_otherStudyGroups count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *studyGroupCellIdentifier = @"StudyGroupCell";
    
    StudyGroupsTableViewCell *cell = (StudyGroupsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:studyGroupCellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:studyGroupCellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *data;
    
    if (indexPath.section == 0) {
        data = [_myStudyGroups objectAtIndex:indexPath.row];
    } else {
        data = [_otherStudyGroups objectAtIndex:indexPath.row];
    }
    
    if (indexPath.row %2 == 0) {
        cell.classNameLabel.backgroundColor = [UIColor colorWithRed:1 green:0.8 blue:0.43 alpha:1.0];
        cell.classNameLabel.textColor = [UIColor blackColor];
    } else {
        cell.classNameLabel.backgroundColor = [UIColor colorWithRed:0.35 green:0.54 blue:0.83 alpha:1.0];
        cell.classNameLabel.textColor = [UIColor whiteColor];
    }
    
    cell.classNameLabel.text = [data objectForKey:@"course"];
    cell.locationLabel.text = [data objectForKey:@"location"];
    if ([data objectForKey:@"start_time"] > [data objectForKey:@"end_time"]) {
        cell.timeLabel.text = [NSString stringWithFormat:@"%@ to %@ (+1)", [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
    } else {
        cell.timeLabel.text = [NSString stringWithFormat:@"%@ to %@", [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier: @"message" sender: self];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"My study groups";
    } else {
        return @"Other study groups";
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
