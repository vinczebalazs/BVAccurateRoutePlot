//
//  BVAccurateRoutePlot.h
//  BVAccurateRoutePlot
//
//  Created by Balazs Vincze on 23/08/16.
//  Copyright © 2016 Balazs Vincze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@import GoogleMaps;

@interface BVAccurateRoutePlot : NSObject{
    NSMutableDictionary *tempLocationDictionary;
    int numberOfRequests;
}

@property UIColor *strokeColor;
@property float strokeWidth;

- (void)drawRouteOnMap:(GMSMapView*)map withStartPoint:(CLLocation*)start endPoint:(CLLocation*)end;

@end
