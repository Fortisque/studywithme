//
//  CoursesViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "CoursesViewController.h"
#import <BuiltIO/BuiltIO.h>

@interface CoursesViewController ()

@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) NSMutableArray *displayCourses;
@end

@implementation CoursesViewController
@synthesize courses;
@synthesize displayCourses;

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        NSMutableSet *set = [[NSMutableSet alloc] init];
        
        for (int i = 0; i < [res count]; i++) {
            [set addObject:[[res objectAtIndex:i] objectForKey:@"name"]];
        }
        
        courses = [NSMutableArray arrayWithArray:[set allObjects]];
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [displayCourses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"courseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [displayCourses objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;

    BuiltObject *obj = [BuiltObject objectWithClassUID:@"course"];
    [obj setObject:cellText forKey:@"name"];
    [obj setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"] forKey:@"user"];

    [obj saveOnSuccess:^{
        NSLog(@"saved course to built");
        [self.navigationController popViewControllerAnimated:YES];
    } onError:^(NSError *error) {
        // there was an error in creating the object
        // error.userinfo contains more details regarding the same
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't add that course"
                                                        message:@"You already have that course, or check your internet"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
        NSLog(@"%@", error.userInfo);
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    displayCourses = [[NSMutableArray alloc] init];
    
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
    
    displayCourses = [[courses filteredArrayUsingPredicate:sPredicate] mutableCopy];
    if ([[searchString componentsSeparatedByString: @" "] count] > 1 && ![displayCourses containsObject:[searchString uppercaseString]]) {
        [displayCourses insertObject:[searchString uppercaseString] atIndex:0];
    }
    return true;
}

@end
