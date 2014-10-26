//
//  CreateStudyGroupViewController.h
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateStudyGroupViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *classPicker;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
- (IBAction)submit:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *startTime;
@property (strong, nonatomic) IBOutlet UITextField *endTime;
@property (strong, nonatomic) IBOutlet UITextField *maxSize;

@end
