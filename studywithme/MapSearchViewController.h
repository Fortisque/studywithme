//
//  MapSearchViewController.h
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import <MapKit/MapKit.h>

@class CreateStudyGroupTableViewController;

@interface MapSearchViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate> {
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) IBOutlet UISearchBar *search;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation *pin;

@property (weak, nonatomic) CreateStudyGroupTableViewController *presenter;

- (IBAction)done:(id)sender;

@end
