//
//  ViewStudyGroupTabViewController.h
//  studywithme
//
//  Created by Kevin Casey on 2/3/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

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
