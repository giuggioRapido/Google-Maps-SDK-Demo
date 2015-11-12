//
//  ViewController.h
//  Google Maps SDK
//
//  Created by Chris on 8/11/15.
//  Copyright (c) 2015 Prince Fungus. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;
#import "Place.h"
#import <CoreLocation/CoreLocation.h>
#import <WebKit/WebKit.h>
#import "webViewController.h"

@interface ViewController : UIViewController <GMSMapViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet GMSPlacePicker *placePicker;
@property (strong, nonatomic) GMSPlacesClient * placesClient;
@property (strong, nonatomic) NSMutableArray *places;
@property (nonatomic) CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) NSString *selectedPlaceWebsite;
@property (strong, nonatomic) UISearchBar *searchBar;





@end

