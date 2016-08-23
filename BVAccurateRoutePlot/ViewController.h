//
//  ViewController.h
//  BVAccurateRoutePlot
//
//  Created by Balazs Vincze on 23/08/16.
//  Copyright © 2016 Balazs Vincze. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMaps;

@interface ViewController : UIViewController <GMSMapViewDelegate>{
    NSMutableArray *tappedCoordinates;
}


@end

