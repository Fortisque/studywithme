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
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

CGFloat originalHeight;
bool keyboardActive;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    originalHeight = self.view.frame.origin.y;
    
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    _usernameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    _webView.delegate = self;
    
    NSURL *url = [NSURL URLWithString:@"https://auth.berkeley.edu/cas/login?"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSData *urlData = [request HTTPBody];
    if (urlData) {
        NSString *urlString=[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [urlString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            
            [queryStringDictionary setObject:value forKey:key];
        }
        
        _username = [queryStringDictionary objectForKey:@"username"];
        _password = [queryStringDictionary objectForKey:@"password"];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:
           @"document.body.innerHTML"];
    if ([result containsString:@"success"]) {
        webView.hidden = YES;
        [BuiltExtension  executeWithName:@"login"
                                    data:@{@"username": _username}
                               onSuccess:^(id response) {
                                   // response will contain the response of the extension method
                                   // here, the response is the user profile, with the authtoken
                                   [self successfullyLoggedIn:response];
                               } onError:^(NSError *error) {
                                   // error block in case of any error
                                   NSLog(@"%@", error);
                               }];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSLog(@"%f", keyboardSize.height);
    
    CGRect frameRect = self.view.frame;
    frameRect.origin.y = originalHeight - keyboardSize.height;
    self.view.frame = frameRect;
    NSLog(@"shown");
}

- (void) keyboardWillHide:(NSNotification *)notification {
    CGRect frameRect = self.view.frame;
    frameRect.origin.y = originalHeight;
    self.view.frame = frameRect;
}

# pragma mark - Textfield delegate

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
    [installation setObject:[user objectForKey:@"uid"] forKey:@"app_user_object_uid"];
    [installation setObject:[NSNumber numberWithInt:0]
                     forKey:@"badge"];
    [installation updateInstallationOnSuccess:^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }                                 onError:^(NSError *error) {
        
    }];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self performSegueWithIdentifier:@"success" sender:self];
    [[NSUserDefaults standardUserDefaults] setObject:_username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"uid"] forKey:@"uid"];
}

@end