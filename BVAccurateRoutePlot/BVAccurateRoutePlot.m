//
//  BVAccurateRoutePlot.m
//  BVAccurateRoutePlot
//
//  Created by Balazs Vincze on 23/08/16.
//  Copyright © 2016 Balazs Vincze. All rights reserved.
//

#import "BVAccurateRoutePlot.h"

@implementation BVAccurateRoutePlot

- (id)init{
    
    tempLocationDictionary = [[NSMutableDictionary alloc] init];
    
    return  [super init];
}

- (void)drawRouteOnMap:(GMSMapView *)map withStartPoint:(CLLocation*)start endPoint:(CLLocation*)end{
    
    //Create placemarks from the passed in locations
    MKPlacemark *startPM = [[MKPlacemark alloc] initWithCoordinate:start.coordinate addressDictionary:NULL];
    MKPlacemark *finsihPM = [[MKPlacemark alloc] initWithCoordinate:end.coordinate addressDictionary:NULL];

    //Create direction request
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:[[MKMapItem alloc] initWithPlacemark:startPM]];
    [request setDestination:[[MKMapItem alloc] initWithPlacemark:finsihPM]];
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    
    //Calculate directions
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    NSLog(@"Calculating directions...");
    
    [direction calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse *response, NSError *error) {
        
        //If no error, proceed
        if (!error) {
            
            NSLog(@"Received calculated directions");
            
            //Get the calculated route from the response
            MKRoute *route = [response.routes firstObject];
            NSUInteger pointCount = route.polyline.pointCount;
            
            //Allocate a C array to hold this many points/coordinates...
            CLLocationCoordinate2D *routeCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D));
            
            //Get the coordinates (all of them)...
            [route.polyline getCoordinates:routeCoordinates range:NSMakeRange(0, pointCount)];
            
            //Initialize some variables
            NSMutableArray *locationsArray = [[NSMutableArray alloc] init];
            CLLocation *lastLocation = [[CLLocation alloc] init];
            
            //Loop through the coordinates and slice them up into arrays of 99 coordinates (the Snap-To-Road API can only process 100 coordinates per request)
            for (int start = 0; start < pointCount; start += 99) {
                [locationsArray removeAllObjects];
                NSInteger length = MIN(99, pointCount-start);
                
                //Add the last object from the previous array of points, so the Snap-To-Road API can return more exact results
                if(start != 0){
                    [locationsArray addObject:lastLocation];
                }
                
                //Loop through the sliced up array of coordinates and add them to our array which we will send to the Snap-To-Road API
                for(int i = start;i<start+length;i++){
                    CLLocationCoordinate2D loc2D = routeCoordinates[i];
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:loc2D.latitude longitude:loc2D.longitude];
                    [locationsArray addObject:location];
                }
                
                lastLocation = [locationsArray lastObject];
                numberOfRequests++;
                [self snapCoordinatesToRoadFromArray:locationsArray withRequestNumber:numberOfRequests drawItOnMap:map];
            }

            //Free the memory used by the C array
            free(routeCoordinates);
            
        }
        
        //If there was en error, log it
        else {
            NSLog(@"Error is %@",error);
        }
        
    }];
    
}

#pragma mark Send coordinates to the Snap-To-Road API
- (void)snapCoordinatesToRoadFromArray:(NSMutableArray*)locationsArray withRequestNumber:(int)requestNumber drawItOnMap:(GMSMapView*)mapView{
    //Create string to store coordinates in for the URL
    NSString *tempcoordinatesForURL = @"";
    
    //Append tempcoordinatesForURL string by the coordinates in the right format
    for(int i = 0;i<[locationsArray count];i++){
        
        CLLocationCoordinate2D coordinates = [[locationsArray objectAtIndex:i] coordinate];
        
        NSString *coordinatesString = [NSString stringWithFormat:@"|%f,%f|",coordinates.latitude,coordinates.longitude];
        
        tempcoordinatesForURL = [tempcoordinatesForURL stringByAppendingString:coordinatesString];
    }
    
    //Remove unnecessary charchters tempcoordinatesForURL
    NSString *coordinatesForURL = [[tempcoordinatesForURL substringToIndex:[tempcoordinatesForURL length]-1] stringByReplacingOccurrencesOfString:@"||" withString:@"|"];
    
    //Create url by removing last charachter from coordinatesForURL string
    NSString *urlPath = [NSString stringWithFormat:@"https://roads.googleapis.com/v1/snapToRoads?path=%@&interpolate=true&key=AIzaSyDrtHA-AMiVVylUPcp46_Vf1eZJJFBwRCY",[coordinatesForURL substringFromIndex:1]];
    
    //Remove unsupproted charchters from urlPath and create an NSURL
    NSString *escapedUrlPath = [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:escapedUrlPath];
    
    //Create request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSLog(@"Sending coordinates arary %i to Snap-To-Roads API",requestNumber);
    
    //Send request to server
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request  completionHandler:^(NSData *data,NSURLResponse *response, NSError *connectionError) {
        
        //If response, parse JSON
        if(response){
            
            //Dictionary with the whole JSON file
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            //Array of snapped points from the JSON
            NSArray *snappedPoints = [result objectForKey:@"snappedPoints"];
            
            NSMutableArray *locationsArray = [[NSMutableArray alloc] init];
            
            //Loop through the snapped points array and add each coordinate to a temporary array
            for (int i = 0; i<[snappedPoints count]; i++) {
                NSDictionary *location = [[snappedPoints objectAtIndex:i] objectForKey:@"location"];
                
                double latitude = [[location objectForKey:@"latitude"] doubleValue];
                double longitude = [[location objectForKey:@"longitude"] doubleValue];
                
                CLLocation *loc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                
                [locationsArray addObject:loc];
                
            }
            
            //Add these temporary location arrays to the dictionary with the key as the request number
            [tempLocationDictionary setObject:locationsArray forKey:[NSString stringWithFormat:@"%i",requestNumber]];
            
            //If all requests have completed get the location arrays from the dicitonary in the same order as the request were made
            if([tempLocationDictionary count] == numberOfRequests){
                
                NSLog(@"Received all coordinates snapped to the road, drawing it on map...");
                
                //Create path to draw on map later
                GMSMutablePath *path = [GMSMutablePath path];
                
                //Loop through the dictionary and get the location arrays in the right order
                for (int i = 0; i<[tempLocationDictionary count]; i++) {
                    
                    //Create a dummy array
                    NSArray *array = [tempLocationDictionary objectForKey:[NSString stringWithFormat:@"%i",i+1]];
                    
                    //Get the coordinates from the array which we just got from the dictionary
                    for (CLLocation *location in array) {
                        [path addCoordinate:location.coordinate];
                        
                    }
                }
                
                //Draw path on the map (execute this on the main thread, as UI updates must be executed there)
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Create polyline
                    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                    polyline.map = mapView;
                    
                    if(self.strokeColor){
                        polyline.strokeColor = self.strokeColor;
                    }
                    
                    if(self.strokeWidth){
                        polyline.strokeWidth = self.strokeWidth;
                    }
                    
                });
                
            }
            
        }
        
        //If error, log it
        else if(connectionError){
            NSLog(@"%@",connectionError);
        }
        
    }];
    
    //Start the request
    [dataTask resume];
}
     
     
@end
