//
//  FeedbackViewController.m
//  studywithme
//
//  Created by Alice Jia Qi Liu on 3/8/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _feedbackTextView.layer.cornerRadius = 5;
    _feedbackTextView.layer.borderColor = [[UIColor colorWithRed:0.35 green:0.54 blue:0.83 alpha:1.0] CGColor];
    _feedbackTextView.layer.borderWidth = 1;
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

- (IBAction)onSubmit:(id)sender {
}

@end
