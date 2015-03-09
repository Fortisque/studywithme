#import <UIKit/UIKit.h>
#import "Helper.h"

@interface ViewStudyGroupTabBarController : UITabBarController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (strong, nonatomic) NSArray* myStudyGroups;
@property (strong, nonatomic) NSArray* otherStudyGroups;
@property (strong, nonatomic) NSMutableArray* courses;

- (IBAction)addButtonPressed:(id)sender;

- (void)updateBuiltQuery;

@end
