//
//  PinAnnotationPoint.h
//  studywithme
//
//  Created by Kevin Casey on 2/5/15.
//  Copyright (c) 2015 ieor190. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PinAnnotationPoint : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


@end
