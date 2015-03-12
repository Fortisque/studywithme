#import "LandingViewController.h"
#import <BuiltIO/BuiltIO.h>
#import <CoreLocation/CoreLocation.h>

@interface LandingViewController () {
    CLLocationManager *locationManager;
}

@end

@implementation LandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc] init];
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // This page looks good with a see through nav bar.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    // Set to 0 badges on every landing page view
    BuiltInstallation *installation = [BuiltInstallation currentInstallation];
    [installation setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"] forKey:@"app_user_object_uid"];
    [installation setObject:[NSNumber numberWithInt:0]
                     forKey:@"badge"];
    [installation updateInstallationOnSuccess:^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        NSLog(@"CLEARED BADGES");
    }                                 onError:^(NSError *error) {
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Translucent doesn't look good on other controllers
    self.navigationController.navigationBar.translucent = NO;

    [super viewWillDisappear:animated];
}

- (IBAction)logout:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Logout"
                          message: @"Are you sure you want to logout?"
                          delegate: nil
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Confirm", nil];
    alert.delegate = self;
    [alert show];
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}



@end
