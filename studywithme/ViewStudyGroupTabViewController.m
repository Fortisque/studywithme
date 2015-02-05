//
//  ViewStudyGroupTabViewController.m
//  studywithme
//
//  Created by Kevin Casey on 2/3/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import "ViewStudyGroupTabViewController.h"
#import <BuiltIO/BuiltIO.h>

@interface ViewStudyGroupTabViewController ()

@end

@implementation ViewStudyGroupTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _courses = [NSMutableArray array];
    _myStudyGroups = [NSArray array];
    
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
    
    // query for my study groups

    // change this to query for other study groups
    [query whereKey:@"course"
        containedIn:_courses];
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        NSArray *results = [result getResult];
        
        NSMutableArray *myStudyGroups = [[NSMutableArray alloc] init];
        NSMutableArray *otherStudyGroups = [[NSMutableArray alloc] init];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"]; //24hr time format
        
        for (int i = 0; i < [results count]; i++) {
            NSDictionary *studyGroup = [results objectAtIndex:i];
            
            NSString *today = [dateFormatter stringFromDate:[NSDate date]];
            
            if ([today isEqualToString:[studyGroup objectForKey:@"start_date"]]) {
                // TODO: check for who created it
                [otherStudyGroups addObject:studyGroup];
            }
        }
        
       _otherStudyGroups = [[NSArray alloc] initWithArray:otherStudyGroups];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyDataChangedNotification" object:nil userInfo:nil];
        
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

@end
