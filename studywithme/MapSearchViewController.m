//
//  MapSearchViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "MapSearchViewController.h"
#define METERS_PER_MILE 1609.344

@interface MapSearchViewController ()

@end

@implementation MapSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //[locationManager requestAlwaysAuthorization];
    
    [locationManager startUpdatingLocation];
    
    _mapView.showsUserLocation = YES;
    
    _mapView.delegate = self;
    
    _search.delegate = self;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@", searchText);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
    [locationManager stopUpdatingLocation];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)done:(id)sender {
    [self finish];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self finish];
}

- (void) finish
{
    [[NSUserDefaults standardUserDefaults] setObject:_search.text forKey:@"location"];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:_search.text completionHandler:^(NSArray* placemarks, NSError* error){
        for (CLPlacemark* aPlacemark in placemarks)
        {
            // Process the placemark.
            NSString *latDest1 = [NSString stringWithFormat:@"%.8f",aPlacemark.location.coordinate.latitude];
            NSString *lngDest1 = [NSString stringWithFormat:@"%.8f",aPlacemark.location.coordinate.longitude];
            
            [[NSUserDefaults standardUserDefaults] setObject:latDest1 forKey:@"latitude"];
            [[NSUserDefaults standardUserDefaults] setObject:lngDest1 forKey:@"longitude"];
        }
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
