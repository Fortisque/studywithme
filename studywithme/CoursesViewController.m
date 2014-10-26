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
    
    courses = [[NSMutableArray alloc] initWithObjects:@"CS61A", @"CS61B", @"CS61C", @"CS161", @"CS169", @"CS170", @"CS188", @"ENGLISH122", @"GERMANR5B", @"MATH54", @"MATH53", nil];
    
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
    CGRect rect = CGRectMake(0, 44, 400, 400);
    [tableView setFrame:rect];
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    
    BuiltObject *obj = [BuiltObject objectWithClassUID:@"course"];
    [obj setObject:cellText
            forKey:@"name"];

    [obj saveOnSuccess:^{
        NSLog(@"saved course to built");
        [self.navigationController popViewControllerAnimated:YES];
    } onError:^(NSError *error) {
        // there was an error in creating the object
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
        [self.navigationController popViewControllerAnimated:YES];
    }];
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
