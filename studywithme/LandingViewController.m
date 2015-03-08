//
//  LandingViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:nil action:nil];
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

- (void)viewDidDisappear:(BOOL)animated {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
