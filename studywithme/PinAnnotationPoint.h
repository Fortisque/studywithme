#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PinAnnotationPoint : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSDictionary *studyGroup;

@end
