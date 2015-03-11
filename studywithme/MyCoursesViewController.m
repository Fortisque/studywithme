#import "MyCoursesViewController.h"
#import <BuiltIO/BuiltIO.h>

@interface MyCoursesViewController ()
@property (strong, nonatomic) NSArray *myCourses;
@end

@implementation MyCoursesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setEditing:false];
    [self builtUpdateTable];
}

- (void)builtUpdateTable {
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"course"];
    [query whereKey:@"user" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]];
    
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        _myCourses = [result getResult];
        [self.tableView reloadData];
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        [Helper alertToCheckInternet];
        NSLog(@"%@", error.userInfo);
    }];
}

# pragma mark - Table view data source

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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:1 green:0.8 blue:0.43 alpha:1.0];
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.35 green:0.54 blue:0.83 alpha:1.0];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
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
        
        [query whereKey:@"name" equalTo:cellText];
        [query whereKey:@"user" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]];
        [query exec:^(QueryResult *result, ResponseType type) {
            BuiltObject *obj = [BuiltObject objectWithClassUID:@"course"];
            [obj setUid:[[[result getResult] objectAtIndex:0] objectForKey:@"uid"]];
            
            [obj destroyOnSuccess:^{
                [self builtUpdateTable];
            } onError:^(NSError *error) {
                // there was an error in deleting the object
                // error.userinfo contains more details regarding the same
                [Helper alertToCheckInternet];
                NSLog(@"%@", error.userInfo);
            }];
        } onError:^(NSError *error, ResponseType type) {
            // query execution failed.
            // error.userinfo contains more details regarding the same
            [Helper alertToCheckInternet];
            NSLog(@"%@", error.userInfo);
        }];
    }
}

@end
