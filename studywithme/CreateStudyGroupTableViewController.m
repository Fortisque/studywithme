//
//  CreateStudyGroupTableViewController.m
//  studywithme
//
//  Created by Kevin Casey on 2/3/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import "CreateStudyGroupTableViewController.h"
#import <BuiltIO/BuiltIO.h>

@interface CreateStudyGroupTableViewController ()

@property (strong, nonatomic) NSArray *courses;
@property (strong, nonatomic) NSMutableArray *coursesArray;
@end

@implementation CreateStudyGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    
    [self queryCourses];
    
    if (_studyGroup) {
        [self updateViewWithStudyGroupInfo];
    }
}

- (void)queryCourses {
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"course"];
    
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        _courses = [result getResult];
        
        _coursesArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [_courses count]; i++) {
            [_coursesArray addObject:[[_courses objectAtIndex:i] objectForKey:@"name"]];
        }
        
        [_picker reloadAllComponents];
        
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"location"];
        
    if (str) {
        [_location setTitle:str forState:UIControlStateNormal];
    }
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
    
    [[NSUserDefaults standardUserDefaults] setObject:[[_studyGroup objectForKey:@"__loc"] objectAtIndex:0] forKey:@"longitude"];
    [[NSUserDefaults standardUserDefaults] setObject:[[_studyGroup objectForKey:@"__loc"] objectAtIndex:1] forKey:@"latitude"];
        
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"]; //24hr time format
    [_startTime setDate:[timeFormatter dateFromString:[_studyGroup objectForKey:@"start_time"]] animated:YES];
    [_endTime setDate:[timeFormatter dateFromString:[_studyGroup objectForKey:@"end_time"]] animated:YES];
    
    [_goButton setTitle:@"Update!" forState:UIControlStateNormal];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_coursesArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [_coursesArray objectAtIndex:row];
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
    return 5;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (IBAction)done:(id)sender {
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"]) {
        [self alertWithMessage:@"Please set a location for your study group"];
        return;
    }
    BuiltObject *obj = [BuiltObject objectWithClassUID:@"study_group"];
        
    // create a location object
    BuiltLocation *loc = [BuiltLocation locationWithLongitude:[[[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"] doubleValue]
                                                  andLatitude:[[[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"] doubleValue]];
    if (_studyGroup != nil) {
        [obj setUid: [_studyGroup objectForKey:@"uid"]];
        NSLog(@"updaing object with uid: %@", [_studyGroup objectForKey:@"uid"]);
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
        NSLog(@"Successfully saved study group!");
        [_goButton setEnabled:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [(ViewStudyGroupTabViewController *)_presenter updateBuiltQuery];
    } onError:^(NSError *error) {
        // there was an error in updating the object
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
        [self alertWithMessage:@"Couldn't save, make sure all fields are filled"];
        [_goButton setEnabled:YES];
    }];
}

- (IBAction)enter_location:(id)sender {
    [self performSegueWithIdentifier:@"map_search" sender:self];
}

- (void)alertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong!"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
