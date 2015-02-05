//
//  StudyGroupsTableViewCell.h
//  studywithme
//
//  Created by Alice J. Liu on 2014-10-25.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateStudyGroupTableViewController.h"

@interface StudyGroupsTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *classNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
- (IBAction)editButtonPressed:(id)sender;

@end
