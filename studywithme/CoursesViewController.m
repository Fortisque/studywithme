//
//  CoursesViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "CoursesViewController.h"

@interface CoursesViewController ()

@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) NSMutableArray *displayCourses;
@end

@implementation CoursesViewController
@synthesize courses;
@synthesize displayCourses;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    courses = [[NSMutableArray alloc] initWithObjects:@"CS61A", @"CS61B", @"CS61C", @"CS170", @"ENGLISH122", @"GermanR5B", nil];
    
    // Do any additional setup after loading the view.
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
    CGRect rect = CGRectMake(0, 44, 350, 200);
    [self.searchDisplayController.searchResultsTableView setFrame:rect];
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
    
    // Display recipe in the table cell
    
    cell.textLabel.text = [displayCourses objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select");
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    displayCourses = [[NSMutableArray alloc] init];
    
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
    
    displayCourses = [[courses filteredArrayUsingPredicate:sPredicate] mutableCopy];
    return true;
}

@end
