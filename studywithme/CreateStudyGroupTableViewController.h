//
//  CreateStudyGroupTableViewController.h
//  studywithme
//
//  Created by Kevin Casey on 2/3/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewStudyGroupTabBarController.h"
#import "Helper.h"
#import <MapKit/MapKit.h>

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
