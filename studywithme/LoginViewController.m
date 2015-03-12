#import <BuiltIO/BuiltIO.h>

#import "LoginViewController.h"

@interface LoginViewController ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (strong, nonatomic) UIWebView *webView;
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
        _password = [queryStringDictionary objectForKey:@"password"];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:
           @"document.body.innerHTML"];
    if ([result containsString:@"Log In Successful"]) {
        [BuiltExtension  executeWithName:@"login"
                                    data:@{@"username": _username}
                               onSuccess:^(id response) {
                                   // response will contain the response of the extension method
                                   // here, the response is the user profile, with the authtoken
                                   [_webView stringByEvaluatingJavaScriptFromString:@"document.location.href = '/cas/logout';"];
                                   BuiltUser *user = [[BuiltUser user] initWithUserDict:response];
                                   [BuiltUser setCurrentUser:user];
                                   [self successfullyLoggedIn:response];
                               } onError:^(NSError *error) {
                                   // error block in case of any error
                                   [Helper alertToCheckInternet];
                                   NSLog(@"%@", error);
                               }];
        
    }
}

- (void)webView:(UIWebView *)webViewfail didFailLoadWithError:(NSError *)error {
    [Helper alertToCheckInternet];
    [self hideWebView];
}

- (void)webViewConnectToCalnet {
    NSURL *url = [NSURL URLWithString:@"https://auth.berkeley.edu/cas/login"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self showWebView];
}

- (void)successfullyLoggedIn:(BuiltUser *)user {
    [self performSegueWithIdentifier:@"success" sender:self];
    [[NSUserDefaults standardUserDefaults] setObject:_username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"uid"] forKey:@"uid"];
}

#pragma mark - Action

- (IBAction)loginPressed:(id)sender {
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:self.view.frame];
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    
    [self webViewConnectToCalnet];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewConnectToCalnet) name:@"dataFromNotification" object:nil];
}

#pragma mark - Helper

- (void)showWebView {
    self.navigationItem.title = @"Login";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self action:@selector(hideWebView)];
    self.navigationController.navigationBar.translucent = NO;
    _webView.hidden = NO;
}

- (void)hideWebView {
    self.navigationItem.title = @"";
    self.navigationItem.leftBarButtonItem = nil;
    [Helper setHeaderToBeTransparentForNavigationController:self.navigationController];
    _webView.hidden = YES;
}

@end