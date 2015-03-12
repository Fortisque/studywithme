#import "CreateStudyGroupTableViewController.h"
#import "MapSearchViewController.h"

@interface MapSearchViewController ()

@end

@implementation MapSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:@"AIzaSyAsBLEGYoII6fWXcRUS9XanIYlK8aBAfnk"];
    shouldBeginEditing = YES;
    
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _search.delegate = self;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocation delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation * myLocation = [locations lastObject];
    if (myLocation.horizontalAccuracy < 0) {
        return;
    }
    NSTimeInterval interval = [myLocation.timestamp timeIntervalSinceNow];
    
    if (abs(interval) < 30) {
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, 1000, 1000);
        [_mapView setRegion:viewRegion animated:YES];
        [self reverseGeocodeGivenCoordinate:myLocation.coordinate];
    
        // Give the device 1 second to normalize its location before stopping. Everytime we get an updated location
        // it throws down the pin and zooms, so we can't keep updating too long in case the user wants to specify
        // their own address
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:locationManager
                                       selector:@selector(stopUpdatingLocation)
                                       userInfo:nil
                                        repeats:NO];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResultPlaces count];
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return searchResultPlaces[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;
}

#pragma mark UITableViewDelegate

- (void)recenterMapToPlacemark:(CLPlacemark *)placemark {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = placemark.location.coordinate;
    
    [self.mapView setRegion:region];
}

- (void)recenterMapToLocation:(CLLocation *)location {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = location.coordinate;
    
    [self.mapView setRegion:region];
}

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address {
    [self.mapView removeAnnotation:selectedPlaceAnnotation];
    
    selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
    selectedPlaceAnnotation.coordinate = placemark.location.coordinate;
    selectedPlaceAnnotation.title = address;
    [self.mapView addAnnotation:selectedPlaceAnnotation];
}

- (void)addPlacemarkLocationToMap:(CLLocation *)location addressString:(NSString *)address {
    [self.mapView removeAnnotation:selectedPlaceAnnotation];
    
    selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
    selectedPlaceAnnotation.coordinate = location.coordinate;
    selectedPlaceAnnotation.title = address;
    [self.mapView addAnnotation:selectedPlaceAnnotation];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
    
    SPGooglePlacesPlaceDetailQuery *query = [[SPGooglePlacesPlaceDetailQuery alloc] initWithApiKey:@"AIzaSyAsBLEGYoII6fWXcRUS9XanIYlK8aBAfnk"];
    query.reference = place.reference;
    [query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not map selected Place"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else {
            NSString *addressString = placeDictionary[@"name"];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[placeDictionary[@"geometry"][@"location"][@"lat"] doubleValue] longitude:[placeDictionary[@"geometry"][@"location"][@"lng"] doubleValue]];
            
            [self addPlacemarkLocationToMap:location addressString:addressString];
            [self recenterMapToLocation:location];
            // ref: https://github.com/chenyuan/SPGooglePlacesAutocomplete/issues/10
            [self.searchDisplayController setActive:NO];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
            _search.text = addressString;
            _location = location;
        }
    }];
    
}

#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    searchQuery.location = self.mapView.userLocation.coordinate;
    if (searchQuery.location.latitude != 0.0) {
        // Restrict to within 1000 meters, this is Berkeley.
        searchQuery.radius = 1000;
    }
    searchQuery.input = searchString;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch Places"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else {
            searchResultPlaces = places;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {
        // User tapped the 'clear' button.
        shouldBeginEditing = NO;
        [self.searchDisplayController setActive:NO];
        [self.mapView removeAnnotation:selectedPlaceAnnotation];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (shouldBeginEditing) {
        // Animate in the table view.
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchDisplayController.searchResultsTableView.alpha = 0.75;
        [UIView commitAnimations];
        
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

# pragma mark - Action

- (IBAction)done:(id)sender {
    _presenter.coordinate = _location.coordinate;
    [_presenter.location setTitle:_search.text forState:UIControlStateNormal];
    [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark - Helper

- (void)reverseGeocodeGivenCoordinate:(CLLocationCoordinate2D)coordinate {
    [self reverseGeocodeGivenLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude]];
}

- (void)reverseGeocodeGivenLocation:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLGeocodeCompletionHandler handler = ^(NSArray *placemark, NSError *err) {
        if ([placemark count] != 0) {
            CLPlacemark *firstPlacemark = placemark[0];
            _search.text = firstPlacemark.name;
            _location = firstPlacemark.location;
            [self addPlacemarkAnnotationToMap:firstPlacemark addressString:firstPlacemark.name];
            [self recenterMapToPlacemark:firstPlacemark];
        }
        
    };
    
    [geocoder reverseGeocodeLocation:location completionHandler:handler];
}

@end
