# BVAccurateRoutePlot

If you are using Google Maps in your application, and want to plot some directions on the map, you won't get an accurate polyline which follwos the road (especially for long distances). 

The reason for this is that Google Maps will only send you an "overview_polyine" which is just a rough estimate of where the polyline should be on the map. This can lead to weird results, such as the polyline being completely off the road.

**BVAccurateRoutePlot** solves this by using Google's Snap-To-Road API, to **correct the poyline**.

**Note:** **BVAccurateRoutePlot** uses Apple's MapKit for calculating directions, as it is much faster than Google's. 

**Please don't forget to link the `<MapKit>` framework to your project in Xcode!**

## **Usage**

Open the demo project, and copy the folder called **BVAccurateRoutePlot** to your own Xcode project. That's it! :)

## **Example**


``` smalltalk 

//Initilaize the route  plotter
BVAccurateRoutePlot *routePlotter = [[BVAccurateRoutePlot alloc] init];
        
//Set up some properties
routePlotter.strokeWidth = 6;
routePlotter.strokeColor = [UIColor blueColor];

[routePlotter drawRouteOnMap:mapView withStartPoint:[tappedCoordinates objectAtIndex:0] endPoint:[tappedCoordinates objectAtIndex:1]]; 
```

## **License**

*Created by Balazs Vincze on 23/08/16.
Copyright © 2016 Balazs Vincze. All rights reserved.*

*Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.*

*THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL "BALAZS VINCZE" BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.*
