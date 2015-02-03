//
//  MapStudyGroupViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "MapStudyGroupViewController.h"
#import <BuiltIO/BuiltIO.h>

#define METERS_PER_MILE 1609.344

@interface MapStudyGroupViewController ()
@property (nonatomic, strong) NSArray *result;
@property (nonatomic, strong) NSMutableArray *courses;
@end

BOOL zoomed;

@implementation MapStudyGroupViewController

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
    
    _courses = [[NSMutableArray alloc] init];
    
    [self setCourses];
}

- (void)setCourses
{
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"course"];
    
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        NSArray *res = [result getResult];
        
        
        for (int i = 0; i < [res count]; i++) {
            [_courses addObject:[[res objectAtIndex:i] objectForKey:@"name"]];
        }
        
        [self updateBuiltQuery];
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
    }];
}

- (void)updateBuiltQuery
{
    BuiltQuery *query = [BuiltQuery queryWithClassUID:@"study_group"];
    
    [query whereKey:@"course"
        containedIn:_courses];
    
    NSLog(@"%@", _courses);
    
    [query exec:^(QueryResult *result, ResponseType type) {
        // the query has executed successfully.
        // [result getResult] will contain a list of objects that satisfy the conditions
        // here's the object we just created
        _result = [result getResult];
        
        for (int i = 0; i < [_result count]; i++) {
            NSDictionary *data = [_result objectAtIndex:i];
            
            NSLog(@"%@", data);
            
            
            CLLocationCoordinate2D location;
            
            location.longitude = [[[data objectForKey:@"__loc"] objectAtIndex:0] doubleValue];
            location.latitude = [[[data objectForKey:@"__loc"] objectAtIndex:1] doubleValue];
            
            //[[CLLocation alloc] initWithLatitude:[data objectForKey:@"latitude"] longitude:[data objectForKey:@"longitude"]];
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            
            point.coordinate = location;
            point.title = [NSString stringWithFormat:@"%@, %@ max", [data objectForKey:@"course"], [data objectForKey:@"size"]];
            point.subtitle = [NSString stringWithFormat:@"%@ - %@", [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
            
            [_mapView addAnnotation:point];
            
        }
    } onError:^(NSError *error, ResponseType type) {
        // query execution failed.
        // error.userinfo contains more details regarding the same
        NSLog(@"%@", error.userInfo);
    }];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //if annotation is the user location, return nil to get default blue-dot...
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    //create purple pin view for all other annotations...
    static NSString *reuseId = @"hello";
    
    MKPinAnnotationView *myPersonalView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (myPersonalView == nil)
    {
        myPersonalView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        myPersonalView.pinColor = MKPinAnnotationColorPurple;
        myPersonalView.canShowCallout = YES;
        myPersonalView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    }
    else
    {
        //if re-using view from another annotation, point view to current annotation...
        myPersonalView.annotation = annotation;
    }
    
    return myPersonalView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"message" sender:self];
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

@end
