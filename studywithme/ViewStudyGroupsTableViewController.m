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
@property (strong, nonatomic) NSArray* tableData;
@property (strong, nonatomic) NSMutableArray *courses;
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
    
    ViewStudyGroupTabViewController *tabVC = (ViewStudyGroupTabViewController *)self.tabBarController;
    NSLog(@"%@", tabVC.arr);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _courses = [[NSMutableArray alloc] init];
    [self setCourses];
    
}

- (void)setCourses
{
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"course"];
    
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        NSArray *res = [result getResult];
        
        
        for (int i = 0; i < [res count]; i++) {
            [_courses addObject:[[res objectAtIndex:i] objectForKey:@"name"]];
        }
        
        [self updateBuiltQuery];
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
    }];
}

- (void)updateBuiltQuery
{
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"study_group"];
    
    [query whereKey:@"course"
        containedIn:_courses];
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        _tableData = [result getResult];
        
        [self.tableView reloadData];

    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
    }];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *studyGroupCellIdentifier = @"StudyGroupCell";
    
    StudyGroupsTableViewCell *cell = (StudyGroupsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:studyGroupCellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:studyGroupCellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *data = [_tableData objectAtIndex:indexPath.row];
    
    cell.classNameLabel.text = [data objectForKey:@"course"];
    cell.locationLabel.text = [data objectForKey:@"location"];
    cell.timeLabel.text = [NSString stringWithFormat:@"From: %@", [data objectForKey:@"start_time"]];
    
    cell.endLabel.text = [NSString stringWithFormat:@"Ending at: %@", [data objectForKey:@"end_time"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier: @"message" sender: self];
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
