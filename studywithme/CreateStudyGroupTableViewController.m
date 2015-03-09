#import <BuiltIO/BuiltIO.h>
#import "CreateStudyGroupTableViewController.h"
#import "MapSearchViewController.h"

@interface CreateStudyGroupTableViewController ()

@property (strong, nonatomic) NSArray *courses;
@property (strong, nonatomic) NSMutableArray *coursesArray;
@end

@implementation CreateStudyGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self queryCourses];
}

- (void)queryCourses {
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"course"];
    [query whereKey:@"user" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]];
    
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        _courses = [result getResult];
        _coursesArray = [[NSMutableArray alloc] init];
        
        if ([_courses count] == 0) {
            [Helper alertWithTitle:@"Add some classes first" andMessage:@"You need to add a class before you can create study groups"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        for (int i = 0; i < [_courses count]; i++) {
            [_coursesArray addObject:[[_courses objectAtIndex:i] objectForKey:@"name"]];
        }
        
        [_picker reloadAllComponents];
        if (_studyGroup) {
            [self updateViewWithStudyGroupInfo];
        }
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        [Helper alertToCheckInternet];
        NSLog(@"%@", error.userInfo);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)updateViewWithStudyGroupInfo {
    for (int i = 0; i < [_coursesArray count]; i++) {
        NSString *course = [_studyGroup objectForKey:@"course"];
        if ([[_coursesArray objectAtIndex:i] isEqualToString: course]) {
            [_picker selectRow:i inComponent:0 animated:YES];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[_studyGroup objectForKey:@"location"] forKey:@"location"];
    [_location setTitle:[_studyGroup objectForKey:@"location"] forState:UIControlStateNormal];
    
    
    double longitude =  [[[_studyGroup objectForKey:@"__loc"] objectAtIndex:0] doubleValue];
    double latitude =  [[[_studyGroup objectForKey:@"__loc"] objectAtIndex:1] doubleValue];
    
    _coordinate = CLLocationCoordinate2DMake(longitude, latitude);
        
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"]; //24hr time format
    [_startTime setDate:[timeFormatter dateFromString:[_studyGroup objectForKey:@"start_time"]] animated:YES];
    [_endTime setDate:[timeFormatter dateFromString:[_studyGroup objectForKey:@"end_time"]] animated:YES];
    
    _goButton.title = @"Update";
}

# pragma mark - Pickerview delegate

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_coursesArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component {
    return [_coursesArray objectAtIndex:row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}

# pragma mark - Action

- (IBAction)enterLocation:(id)sender {
    [self performSegueWithIdentifier:@"map_search" sender:self];
}

- (IBAction)done:(id)sender {
    if (!_coordinate.longitude) {
        [Helper alertWithMessage:@"Please set a location for your study group"];
        return;
    }
    
    BuiltObject *obj = [BuiltObject objectWithClassUID:@"study_group"];
    
    // create a location object
    BuiltLocation *loc = [BuiltLocation locationWithLongitude:_coordinate.longitude
                                                  andLatitude:_coordinate.latitude];
    if (_studyGroup != nil) {
        [obj setUid: [_studyGroup objectForKey:@"uid"]];
    }
    
    [obj setLocation: loc];
    [obj setObject:[_coursesArray objectAtIndex:[_picker selectedRowInComponent:0]]
            forKey:@"course"];
    [obj setObject:[_location currentTitle]
            forKey:@"location"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"]; //24hr time format
    
    [obj setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"start_date"];
    [obj setObject:[timeFormatter stringFromDate:_startTime.date]
            forKey:@"start_time"];
    [obj setObject:[timeFormatter stringFromDate:_endTime.date]
            forKey:@"end_time"];
    
    // timeinverval is seconds
    if (abs([_endTime.date timeIntervalSinceDate:_startTime.date]) < 15 * 60) {
        [Helper alertWithMessage:@"Study group needs to last for at least 15 minutes"];
        return;
    }
    
    // if studying past midnight
    if ([_endTime.date timeIntervalSinceDate:_startTime.date] > 0) {
        [obj setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"end_date"];
    } else {
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.day = 1;
        NSDate *newDate = [[NSCalendar currentCalendar]dateByAddingComponents:dateComponents
                                                                       toDate:[NSDate date]
                                                                      options:0];
        [obj setObject:[dateFormatter stringFromDate:newDate] forKey:@"end_date"];
    }
    
    [_goButton setEnabled:NO];
    [obj saveOnSuccess:^{
        [_goButton setEnabled:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [(ViewStudyGroupTabBarController *)_presenter updateBuiltQuery];
    } onError:^(NSError *error) {
        // there was an error in updating the object
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
        [Helper alertWithMessage:@"Couldn't save, make sure all fields are filled"];
        [_goButton setEnabled:YES];
    }];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"map_search"]) {
        MapSearchViewController *vc = [segue destinationViewController];
        vc.presenter = self;
    }
}

@end
