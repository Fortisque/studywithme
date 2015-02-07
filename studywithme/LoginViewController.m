//
//  LoginViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "LoginViewController.h"
#import <BuiltIO/BuiltIO.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    _usernameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

# pragma makr - Textfield delegate

-(void) dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard:textField];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self dismissKeyboard:textField];
}

# pragma mark - Action

- (IBAction)login:(id)sender {
    if (![self verifyBerkeleyEmailUsername]) {
        [Helper alertWithMessage:@"Berkeley email required"];
        return;
    }
    BuiltUser *user = [BuiltUser user];
    
    [user loginWithEmail:_usernameField.text
             andPassword:_passwordField.text
               OnSuccess:^{
                   [self successfullyLoggedIn:user];
               } onError:^(NSError *error) {
                   // login failed
                   // error.userinfo contains more details regarding the same
                   [Helper alertWithMessage:[error.userInfo valueForKey:@"error_message"]];
                   NSLog(@"%@", error.userInfo);
               }];
}

- (IBAction)register:(id)sender {
    if (![self verifyBerkeleyEmailUsername]) {
        [Helper alertWithMessage:@"Berkeley email required"];
        return;
    }
    BuiltUser *user = [BuiltUser user];
    user.email = _usernameField.text;
    user.password = _passwordField.text;
    user.confirmPassword = _passwordField.text;
    [user signUpOnSuccess:^{
        [Helper alertWithTitle:@"Successfully registered" andMessage:@"Check your email to confirm your account!"];
    } onError:^(NSError *error) {
        // there was an error in signing up the user
        // error.userinfo contains more details regarding the same
        [Helper alertWithMessage:[error.userInfo valueForKey:@"error_message"]];
        NSLog(@"%@", error.userInfo);
    }];
}

# pragma mark - helpers

- (BOOL)verifyBerkeleyEmailUsername {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(.*)@berkeley.edu$" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSString *str = _usernameField.text;
    NSTextCheckingResult *match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
    NSString *res = [str substringWithRange:[match rangeAtIndex:1]];
    return [res length] != 0;
}

- (void)successfullyLoggedIn:(BuiltUser *)user {
    BuiltInstallation *installation = [BuiltInstallation currentInstallation];
    [installation setObject:user.uid forKey:@"app_user_object_uid"];
    [installation setObject:[NSNumber numberWithInt:0]
                     forKey:@"badge"];
    [installation updateInstallationOnSuccess:^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }                                 onError:^(NSError *error) {
        
    }];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self performSegueWithIdentifier:@"success" sender:self];
    [[NSUserDefaults standardUserDefaults] setObject:_usernameField.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:user.uid forKey:@"uid"];
}

@end
