//
//  MyCoursesViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "MyCoursesViewController.h"
#import <BuiltIO/BuiltIO.h>

@interface MyCoursesViewController ()
@property (strong, nonatomic) NSArray *myCourses;
@end

@implementation MyCoursesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self builtUpdateTable];
    
    self.tableView.allowsSelectionDuringEditing = true;
    
    //self.tableView.backgroundColor = [UIColor colorWithRed:254.0/255 green:166.0/255 blue:20.0/255 alpha:1.0];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setEditing:false];
    [super viewWillAppear:animated];
    
    [self builtUpdateTable];
}

- (void)builtUpdateTable {
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"course"];
    
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        _myCourses = [result getResult];
        [self.tableView reloadData];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_myCourses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *courseCellIdentifier = @"course";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:courseCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:courseCellIdentifier];
    }
    
    cell.textLabel.text = [[_myCourses objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        BuiltQuery *query = [BuiltQuery queryWithClassUID:@"course"];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *cellText = cell.textLabel.text;
        
        [query whereKey:@"name"
                equalTo:cellText];
        [query exec:^(QueryResult *result, ResponseType type) {
            BuiltObject *obj = [BuiltObject objectWithClassUID:@"course"];
            [obj setUid:[[[result getResult] objectAtIndex:0] objectForKey:@"uid"]];
            
            [obj destroyOnSuccess:^{
                NSLog(@"delete");
                [self builtUpdateTable];
            } onError:^(NSError *error) {
                // there was an error in deleting the object
                // error.userinfo contains more details regarding the same
                NSLog(@"%@", error.userInfo);
            }];
            
        } onError:^(NSError *error, ResponseType type) {
            // query execution failed.
            // error.userinfo contains more details regarding the same
            NSLog(@"%@", error.userInfo);
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEditing]) {
        [tableView setEditing:false];
    } else {
        [tableView setEditing:true];
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
