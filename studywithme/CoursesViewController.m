#import <BuiltIO/BuiltIO.h>

#import "CoursesViewController.h"

@interface CoursesViewController ()

@property (strong, nonatomic) NSMutableArray *courses;
@property (strong, nonatomic) NSMutableArray *displayCourses;
@end

@implementation CoursesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCourses];
}

- (void)setCourses {
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
        
        _courses = [NSMutableArray arrayWithArray:[set allObjects]];
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        [Helper alertToCheckInternet];
        NSLog(@"%@", error.userInfo);
    }];
}

# pragma mark - Search display delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_displayCourses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"courseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [_displayCourses objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;

    BuiltObject *obj = [BuiltObject objectWithClassUID:@"course"];
    [obj setObject:cellText forKey:@"name"];
    [obj setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"] forKey:@"user"];

    [obj saveOnSuccess:^{
        [self.navigationController popViewControllerAnimated:YES];
    } onError:^(NSError *error) {
        // there was an error in creating the object
        // error.userinfo contains more details regarding the same
        if ([[error.userInfo objectForKey:@"error_code"] intValue] == 119) {
            [Helper alertWithTitle:@"Could not add course" andMessage:@"You have already added that course!"];
        } else {
            [Helper alertToCheckInternet];
        }
        
        NSLog(@"%@", error.userInfo);
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString {
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchString];
    _displayCourses = [[_courses filteredArrayUsingPredicate:sPredicate] mutableCopy];

    if ([[searchString componentsSeparatedByString: @" "] count] > 1 && ![_displayCourses containsObject:[searchString uppercaseString]]) {
        [_displayCourses insertObject:[searchString uppercaseString] atIndex:0];
    }
    return true;
}

@end
