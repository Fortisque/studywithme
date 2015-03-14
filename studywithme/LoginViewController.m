#import <BuiltIO/BuiltIO.h>

#import "LoginViewController.h"

@interface LoginViewController ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *calnetCookie;
@property (strong, nonatomic) UIWebView *loginWebView;
@property (strong, nonatomic) UIWebView *logoutWebView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideWebView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
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
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView == _loginWebView) {
        [self showWebView];
        NSString *result = [webView stringByEvaluatingJavaScriptFromString:
                            @"document.body.innerHTML"];
        if ([result containsString:@"Log In Successful"]) {
            NSHTTPCookie *cookie;
            NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (cookie in [cookieJar cookies]) {
                if ([[cookie valueForKey:@"name"] isEqualToString:@"CASTGC"]) {
                    _calnetCookie = [cookie valueForKey:@"value"];
                }
            }
            [BuiltExtension  executeWithName:@"login"
                                        data:@{@"username": _username, @"calnetCookie": _calnetCookie}
                                   onSuccess:^(id response) {
                                       // response will contain the response of the extension method
                                       // here, the response is the user profile, with the authtoken
                                       BuiltUser *user = [[BuiltUser user] initWithUserDict:response];
                                       [BuiltUser setCurrentUser:user];
                                       [self successfullyLoggedIn:response];
                                       [self logout];
                                   } onError:^(NSError *error) {
                                       // error block in case of any error
                                       [Helper alertToCheckInternet];
                                       NSLog(@"%@", error);
                                   }];
            
        }
    }
}

- (void)webView:(UIWebView *)webViewfail didFailLoadWithError:(NSError *)error {
    [Helper alertToCheckInternet];
}

- (void)webViewConnectToCalnetLogin {
    NSURL *url = [NSURL URLWithString:@"https://auth.berkeley.edu/cas/login"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_loginWebView loadRequest:request];
}

- (void)webViewConnectToCalnetLogout {
    NSURL *url = [NSURL URLWithString:@"https://auth.berkeley.edu/cas/logout"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_logoutWebView loadRequest:request];
}

- (void)successfullyLoggedIn:(BuiltUser *)user {
    [self performSegueWithIdentifier:@"success" sender:self];
    [[NSUserDefaults standardUserDefaults] setObject:_username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"uid"] forKey:@"uid"];
}

#pragma mark - Action

- (IBAction)loginPressed:(id)sender {
    if (!_loginWebView) {
        _loginWebView = [[UIWebView alloc]initWithFrame:self.view.frame];
        _loginWebView.delegate = self;
    }
    
    [self webViewConnectToCalnetLogin];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewConnectToCalnetLogin) name:@"dataFromNotification" object:nil];
}

- (void)logout {
    if (!_logoutWebView) {
        _logoutWebView = [[UIWebView alloc]initWithFrame:self.view.frame];
        _logoutWebView.delegate = self;
    }
    
    [self webViewConnectToCalnetLogout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewConnectToCalnetLogout) name:@"dataFromNotification" object:nil];
}

#pragma mark - Helper

- (void)showWebView {
    self.navigationItem.title = @"Login";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self action:@selector(hideWebView)];
    self.navigationController.navigationBar.translucent = NO;
    [self.view addSubview:_loginWebView];
}

- (void)hideWebView {
    self.navigationItem.title = @"";
    self.navigationItem.leftBarButtonItem = nil;
    [Helper setHeaderToBeTransparentForNavigationController:self.navigationController];
    [_loginWebView removeFromSuperview];
}

@end