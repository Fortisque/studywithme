#import <MapKit/MapKit.h>

#import "SPGooglePlacesAutocomplete.h"
#import "SPGooglePlacesPlaceDetailQuery.h"

@class CreateStudyGroupTableViewController;

@interface MapSearchViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    MKPointAnnotation *selectedPlaceAnnotation;
    
    BOOL shouldBeginEditing;
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) IBOutlet UISearchBar *search;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocation *location;
@property (weak, nonatomic) CreateStudyGroupTableViewController *presenter;

- (IBAction)done:(id)sender;

@end
