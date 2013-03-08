//
//  MKMapView+ZoomLevel.h
//  Shutterbug
//
//  Created by Admin on 11/6/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

- (int) getZoomLevel;

@end
