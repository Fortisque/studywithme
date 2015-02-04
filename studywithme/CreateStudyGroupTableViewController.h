//
//  CreateStudyGroupTableViewController.h
//  studywithme
//
//  Created by Kevin Casey on 2/3/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateStudyGroupTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIButton *location;
@property (strong, nonatomic) IBOutlet UIDatePicker *startTime;
@property (strong, nonatomic) IBOutlet UIDatePicker *endTime;
- (IBAction)done:(id)sender;
- (IBAction)enter_location:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *goButton;

@end
