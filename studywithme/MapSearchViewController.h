//
//  MapSearchViewController.h
//  studywithme
//
//  Created by Kevin Casey on 10/25/14.
//  Copyright (c) 2014 ieor190. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface MapSearchViewController : ViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate> {
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) IBOutlet UISearchBar *search;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)done:(id)sender;

@end
