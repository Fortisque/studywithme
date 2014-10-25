//
//  CreateStudyGroupViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "CreateStudyGroupViewController.h"
#import <BuiltIO/BuiltIO.h>

@interface CreateStudyGroupViewController ()
@property (strong, nonatomic) NSArray *courses;
@property (strong, nonatomic) NSMutableArray *coursesArray;

@end

@implementation CreateStudyGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
        
        NSLog(@"courses:%@", _coursesArray);
        
        [_classPicker reloadAllComponents];
        
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

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSLog(@"%d", [_coursesArray count]);
    return [_coursesArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    NSLog(@"%@", _coursesArray);
    return [_coursesArray objectAtIndex:row];
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
     NSLog(@"Selected Row %d", row);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
