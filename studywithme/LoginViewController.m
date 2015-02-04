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

- (IBAction)login:(id)sender {
    if (![self verifyBerkeleyEmailUsername]) {
        [self alertWithMessage:@"Berkeley email required"];
        return;
    }
    BuiltUser *user = [BuiltUser user];
    
    [user loginWithEmail:_usernameField.text
             andPassword:_passwordField.text
               OnSuccess:^{
                   // user has logged in successfully
                   BuiltInstallation *installation = [BuiltInstallation currentInstallation];
                   [installation setObject:user.uid forKey:@"app_user_object_uid"];
                   [installation updateInstallationOnSuccess:^{
                       
                   }                                 onError:^(NSError *error) {
                       
                   }];
                   self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:nil action:nil];
                   [self performSegueWithIdentifier:@"success" sender:self];
                   [[NSUserDefaults standardUserDefaults] setObject:_usernameField.text forKey:@"username"];
               } onError:^(NSError *error) {
                   // login failed
                   // error.userinfo contains more details regarding the same
                   NSLog(@"%@", error.userInfo);
                   [self alertWithMessage:[error.userInfo valueForKey:@"error_message"]];
               }];
}

- (IBAction)register:(id)sender {
    if (![self verifyBerkeleyEmailUsername]) {
        [self alertWithMessage:@"Berkeley email required"];
        return;
    }
    BuiltUser *user = [BuiltUser user];
    user.email = _usernameField.text;
    user.password = _passwordField.text;
    user.confirmPassword = _passwordField.text;
    [user signUpOnSuccess:^{
        _welcomeLabel.text = [NSString stringWithFormat:@"Yay, %@ is signed up!", user.email];
    } onError:^(NSError *error) {
        // there was an error in signing up the user
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
        [self alertWithMessage:[error.userInfo valueForKey:@"error_message"]];
    }];
}

- (BOOL)verifyBerkeleyEmailUsername
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(.*)@berkeley.edu$" options:0 error:NULL];
    NSString *str = _usernameField.text;
    NSTextCheckingResult *match = [regex firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
    NSString *res = [str substringWithRange:[match rangeAtIndex:1]];
    return [res length] != 0;
}

- (void)alertWithMessage:(NSString *)message
{
    if ([message length] == 0) {
        message = @"Please check your internet";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong!"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
