#import <UIKit/UIKit.h>
#import "CreateStudyGroupTableViewController.h"

@interface StudyGroupsTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *classNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end
