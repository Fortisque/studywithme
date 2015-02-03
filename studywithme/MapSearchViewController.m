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

BOOL zoomed;

- (void)viewDidLoad {
    [super viewDidLoad];
    zoomed = false;

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager requestWhenInUseAuthorization];
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [locationManager startUpdatingLocation];
        _mapView.showsUserLocation = YES;
        
    }
    
    _mapView.delegate = self;
    
    _search.delegate = self;
    
    _pin = [[MKPointAnnotation alloc] init];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 1 seconds
    [self.mapView addGestureRecognizer:lpgr];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@", searchText);
    [[NSUserDefaults standardUserDefaults] setObject:_search.text forKey:@"location"];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    if (!zoomed) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [_mapView setRegion:viewRegion animated:YES];
        zoomed = true;
    }
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

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self geocode];
}

- (void) finish
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)geocode
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:_search.text completionHandler:^(NSArray* placemarks, NSError* error){
        for (CLPlacemark* aPlacemark in placemarks)
        {
            NSLog(@"%@", aPlacemark);
            // Process the placemark.
            [self addPinToMapGivenCoordinate:aPlacemark.location.coordinate];
        }
    }];
}

- (void)addPinToMapGivenCoordinate:(CLLocationCoordinate2D)coordinate
{
    _pin.coordinate = coordinate;
    NSString *lat = [NSString stringWithFormat:@"%.8f", coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%.8f", coordinate.longitude];
    [[NSUserDefaults standardUserDefaults] setObject:lat forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:lng forKey:@"longitude"];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
    [_mapView addAnnotation:_pin];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    [self addPinToMapGivenCoordinate:touchMapCoordinate];
}
@end
