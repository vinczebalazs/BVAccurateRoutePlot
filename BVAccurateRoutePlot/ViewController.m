//
//  ViewController.m
//  BVAccurateRoutePlot
//
//  Created by Balazs Vincze on 23/08/16.
//  Copyright © 2016 Balazs Vincze. All rights reserved.
//

#import "ViewController.h"
#import "BVAccurateRoutePlot.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tappedCoordinates = [[NSMutableArray alloc] init];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:47.4979
                                                            longitude:19.0402
                                                                 zoom:14];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.delegate = self;
    self.view = mapView;
}

- (void)viewDidAppear:(BOOL)animated{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tap any two points on the map to calulcate a route between them (snapped perfectly to the road, of course)" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    CLLocation *tappedLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate
                            .longitude];
    
    [tappedCoordinates addObject:tappedLocation];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coordinate;
    marker.map = mapView;
    
    if ([tappedCoordinates count] == 2){
        
        //Initilaize the route  plotter
        BVAccurateRoutePlot *routePlotter = [[BVAccurateRoutePlot alloc] init];
        
        //Set up some properties
        routePlotter.strokeWidth = 6;
        routePlotter.strokeColor = [UIColor blueColor];
        
        [mapView clear];
        
        [routePlotter drawRouteOnMap:mapView withStartPoint:[tappedCoordinates objectAtIndex:0] endPoint:[tappedCoordinates objectAtIndex:1]];
        
        [tappedCoordinates removeAllObjects];
        
        
    }
}


@end
