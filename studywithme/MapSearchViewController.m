//
//  MapSearchViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "MapSearchViewController.h"
#define METERS_PER_MILE 1609.344
#import "CreateStudyGroupTableViewController.h"

@interface MapSearchViewController ()

@end

@implementation MapSearchViewController

CLLocation *myLocation;

BOOL done;

- (void)viewDidLoad {
    [super viewDidLoad];
    done = false;

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    
    _search.delegate = self;
    
    _pin = [[MKPointAnnotation alloc] init];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 1 seconds
    [self.mapView addGestureRecognizer:lpgr];
}

#pragma mark - UISearchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (!done) {
        [self geocode];
    }
}

#pragma mark - CLLocation delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    myLocation = [locations lastObject];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
    
    [self addPinToMapGivenCoordinate:myLocation.coordinate];
    [self reverseGeocodeGivenLocation:myLocation];
    
    [locationManager stopUpdatingLocation];
}

#pragma mark - MKMapView delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self addPinToMapGivenCoordinate:mapView.centerCoordinate];
    [self reverseGeocodeGivenCoordinate:mapView.centerCoordinate];
}

# pragma mark - Action

- (IBAction)done:(id)sender {
    _presenter.coordinate = _pin.coordinate;
    [_presenter.location setTitle:_search.text forState:UIControlStateNormal];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    [self addPinToMapGivenCoordinate:touchMapCoordinate];
    [self reverseGeocodeGivenCoordinate:touchMapCoordinate];
}

# pragma mark - Helpers

- (void)geocode {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:[_search.text stringByAppendingString:@" berkeley"] completionHandler:^(NSArray* placemarks, NSError* error){
        if ([placemarks count] != 0) {
            CLPlacemark* firstPlacemark = [placemarks objectAtIndex:0];
            [self addPinToMapGivenCoordinate:firstPlacemark.location.coordinate];
        }
    }];
}

- (void)reverseGeocodeGivenCoordinate:(CLLocationCoordinate2D)coordinate {
    [self reverseGeocodeGivenLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]];
}

- (void)reverseGeocodeGivenLocation:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLGeocodeCompletionHandler handler = ^(NSArray *placemark, NSError *err) {
        if ([placemark count] != 0) {
            CLPlacemark *firstPlacemark = placemark[0];
            _search.text = firstPlacemark.name;
        }

    };
    
    [geocoder reverseGeocodeLocation:location completionHandler:handler];
}

- (void)addPinToMapGivenCoordinate:(CLLocationCoordinate2D)coordinate {
    _pin.coordinate = coordinate;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
    [_mapView addAnnotation:_pin];
}

@end
