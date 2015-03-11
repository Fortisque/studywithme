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
    
    originalHeight = self.view.frame.origin.y;
    
    _webView.delegate = self;
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
    if ([result containsString:@"Log In Successful"]) {
        webView.hidden = YES;
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
}

- (void)viewWillAppear:(BOOL)animated {
    _webView.hidden = NO;
    [super viewWillAppear:animated];
    [self webViewConnectToCalnet];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewConnectToCalnet) name:@"dataFromNotification" object:nil];
}

- (void)webViewConnectToCalnet
{
    NSURL *url = [NSURL URLWithString:@"https://auth.berkeley.edu/cas/login"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)successfullyLoggedIn:(BuiltUser *)user {
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self performSegueWithIdentifier:@"success" sender:self];
    [[NSUserDefaults standardUserDefaults] setObject:_username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"uid"] forKey:@"uid"];
}

@end