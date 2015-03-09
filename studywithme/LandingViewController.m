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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

- (IBAction)logout:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
