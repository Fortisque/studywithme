//
//  MapStudyGroupViewController.m
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "MapStudyGroupViewController.h"
#import <BuiltIO/BuiltIO.h>
#import "ViewStudyGroupTabViewController.h"
#import "PinAnnotationPoint.h"

#define METERS_PER_MILE 1609.344

@interface MapStudyGroupViewController ()
@property (nonatomic, strong) NSArray *otherStudyGroups;
@property (nonatomic, strong) NSArray *myStudyGroups;
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

    [locationManager startUpdatingLocation];
    _mapView.showsUserLocation = YES;
    
    _mapView.delegate = self;
    
    [self updateMap:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMap:) name:@"MyDataChangedNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateMap:(NSNotification *)notification
{
    // Purge old pins
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    
    [self.mapView removeAnnotations:pins];
    pins = nil;
    
    ViewStudyGroupTabViewController *tabVC = (ViewStudyGroupTabViewController *)self.tabBarController;
    
    _otherStudyGroups = tabVC.otherStudyGroups;
    _myStudyGroups = tabVC.myStudyGroups;
    for (int i = 0; i < [_otherStudyGroups count]; i++) {
        NSDictionary *data = [_otherStudyGroups objectAtIndex:i];
            
        CLLocationCoordinate2D location;
            
        location.longitude = [[[data objectForKey:@"__loc"] objectAtIndex:0] doubleValue];
        location.latitude = [[[data objectForKey:@"__loc"] objectAtIndex:1] doubleValue];
            
        PinAnnotationPoint *point = [[PinAnnotationPoint alloc] init];
            
        point.coordinate = location;
        point.title = [NSString stringWithFormat:@"%@ (%@ - %@)", [data objectForKey:@"course"], [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
        point.subtitle = [NSString stringWithFormat:@"%@", [data objectForKey:@"location"]];
        point.uid = [data objectForKey:@"uid"];
        
        [_mapView addAnnotation:point];
    }
    
    for (int i = 0; i < [_myStudyGroups count]; i++) {
        NSDictionary *data = [_myStudyGroups objectAtIndex:i];
        
        CLLocationCoordinate2D location;
        
        location.longitude = [[[data objectForKey:@"__loc"] objectAtIndex:0] doubleValue];
        location.latitude = [[[data objectForKey:@"__loc"] objectAtIndex:1] doubleValue];
        
        PinAnnotationPoint *point = [[PinAnnotationPoint alloc] init];
        
        point.coordinate = location;
        point.title = [NSString stringWithFormat:@"%@ (%@ - %@)", [data objectForKey:@"course"], [data objectForKey:@"start_time"], [data objectForKey:@"end_time"]];
        point.subtitle = [NSString stringWithFormat:@"%@", [data objectForKey:@"location"]];
        point.uid = [data objectForKey:@"uid"];
        
        [_mapView addAnnotation:point];
    }
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
    PinAnnotationPoint *pin = (PinAnnotationPoint *)view.annotation;
    
    [self performSegueWithIdentifier:@"messages" sender:self];
    
    [[NSUserDefaults standardUserDefaults] setObject:pin.title forKey:@"study_group_title"];
    [[NSUserDefaults standardUserDefaults] setObject:pin.uid forKey:@"study_group_uid"];
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
