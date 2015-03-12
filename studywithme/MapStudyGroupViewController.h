#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapStudyGroupViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> {
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
