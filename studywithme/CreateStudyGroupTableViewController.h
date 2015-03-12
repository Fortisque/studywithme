#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

#import "Helper.h"
#import "ViewStudyGroupTabBarController.h"

@interface CreateStudyGroupTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIButton *location;
@property (strong, nonatomic) IBOutlet UIDatePicker *startTime;
@property (strong, nonatomic) IBOutlet UIDatePicker *endTime;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *goButton;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSDictionary *studyGroup;
@property (weak, atomic) ViewStudyGroupTabBarController *presenter;

- (IBAction)done:(id)sender;
- (IBAction)enterLocation:(id)sender;

@end
