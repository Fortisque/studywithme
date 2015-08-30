#import <BuiltIO/BuiltIO.h>

#import "ViewStudyGroupTabBarController.h"
#import "CreateStudyGroupTableViewController.h"

@interface ViewStudyGroupTabBarController ()

@end

@implementation ViewStudyGroupTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _myStudyGroups = @[];
    _otherStudyGroups = @[];
    _futureStudyGroups = @[];
    
    [self setCourses];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCourses) name:@"dataFromNotification" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setCourses {
    _courses = [NSMutableArray array];
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"course"];
    [query whereKey:@"user" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]];
    
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        NSArray *res = [result getResult];
        
        for (int i = 0; i < [res count]; i++) {
            [_courses addObject:[[res objectAtIndex:i] objectForKey:@"name"]];
        }
        
        // Find relevant study groups.
        [self updateBuiltQuery];
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        [Helper alertToCheckInternet];
        NSLog(@"%@", error.userInfo);
    }];
}

- (void)updateBuiltQuery {
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"study_group"];
    
    [query whereKey:@"course" containedIn:_courses];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"]; //24hr time format
    
    [query whereKey:@"end_date" greaterThanOrEqualTo:[dateFormatter stringFromDate:[NSDate date]]];
    [query orderByAscending:@"start_date"];
    [query exec:^(QueryResult *result, ResponseType type) {
        NSArray *results = [result getResult];
        
        NSMutableArray *myStudyGroups = [[NSMutableArray alloc] init];
        NSMutableArray *otherStudyGroups = [[NSMutableArray alloc] init];
        NSMutableArray *futureStudyGroups = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [results count]; i++) {
            NSDictionary *studyGroup = [results objectAtIndex:i];
            if ([[dateFormatter stringFromDate:[NSDate date]] isEqualToString:[studyGroup objectForKey:@"end_date"]]) {
                NSComparisonResult result = [(NSString *)[studyGroup objectForKey:@"end_time"] compare:[timeFormatter stringFromDate:[NSDate date]]];
                if (result == NSOrderedAscending) {
                    // This study group has already ended.
                    continue;
                }
            }
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"] isEqualToString:[studyGroup objectForKey:@"app_user_object_uid"]]) {
                [myStudyGroups addObject:studyGroup];
            } else {
                if ([[dateFormatter stringFromDate:[NSDate date]] isEqualToString:[studyGroup objectForKey:@"start_date"]]) {
                    [otherStudyGroups addObject:studyGroup];
                } else {
                    [futureStudyGroups addObject:studyGroup];
                }
            }
        }
        
        _myStudyGroups = [[NSArray alloc] initWithArray:myStudyGroups];
        _otherStudyGroups = [[NSArray alloc] initWithArray:otherStudyGroups];
        _futureStudyGroups = [[NSArray alloc] initWithArray:futureStudyGroups];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyDataChangedNotification" object:nil userInfo:nil];
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        [Helper alertToCheckInternet];
        NSLog(@"%@", error.userInfo);
    }];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addStudyGroup"]) {
        CreateStudyGroupTableViewController *vc = [segue destinationViewController];
        vc.presenter = self;
    }
}

# pragma mark - Action

- (IBAction)addButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"addStudyGroup" sender:sender];
}

@end
