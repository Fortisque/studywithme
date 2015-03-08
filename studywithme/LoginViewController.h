//
//  LoginViewController.h
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helper.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIView *signinView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)login:(id)sender;
- (IBAction)register:(id)sender;

@end
