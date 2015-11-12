//
//  ViewController.m
//  Google Maps SDK
//
//  Created by Chris on 8/11/15.
//  Copyright (c) 2015 Prince Fungus. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create array properties
    self.places = [[NSMutableArray alloc]init];
    
    // Set camera to Turn To Tech and set mapView's camera
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.741655
                                                            longitude:-73.989980
                                                                 zoom:16];
    self.mapView.camera = camera;
    
    // Creates a marker in the center of the map.
    [self createMarkers];
    
    // Show compass button (only appears when the user first twists screen)
    self.mapView.settings.compassButton = YES;
    
    // Set self as mapView's delegate
    self.mapView.delegate = self;
    
    self.searchBar = [[UISearchBar alloc]init];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Find nearby";
    self.navigationItem.titleView = self.searchBar;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Hide navbar because we won't need it in mapView
    //self.navigationController.navigationBarHidden = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Remove all places
    [self.places removeAllObjects];
    
    // Hide Cancel Button and Keyboard
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    // Create URL for a Places API Nearby Search, passing in values from camera.target for coordinates
    NSURL *nearbySearchURL = [NSURL URLWithString:[NSString stringWithFormat:
                                                   @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=500&type=%@&key=API KEY",
                                                   self.mapView.camera.target.latitude,
                                                   self.mapView.camera.target.longitude,
                                                   [searchBar.text lowercaseString]]];
    
    /* NEARBY SEARCH */
    NSURLSessionDataTask *searchTask =
    [[NSURLSession sharedSession]
     dataTaskWithURL:nearbySearchURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
     {
         // 4: Handle response here
         NSData *jsonData = [NSData dataWithContentsOfURL:nearbySearchURL];
         NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
         
         // Create a Place for each JSON place returned and assign properties
         for(id returnedPlace in [jsonDict objectForKey:@"results"])
         {
             Place *currentPlace = [[Place alloc]init];
             currentPlace.placeID = [returnedPlace objectForKey:@"place_id"];
             currentPlace.name = [returnedPlace objectForKey:@"name"];
             currentPlace.address = [returnedPlace objectForKey:@"vicinity"];
             
             currentPlace.latitude = [[[[returnedPlace objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"]doubleValue];
             currentPlace.longitude = [[[[returnedPlace objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"]doubleValue];
             currentPlace.coordinate = CLLocationCoordinate2DMake(currentPlace.latitude, currentPlace.longitude);
             
             // Add currentPlace to array
             [self.places addObject:currentPlace];
         }
         
         // Call createMarkers on main thread, calls to Google Maps must be on main thread
         dispatch_async(dispatch_get_main_queue(), ^{
             [self createMarkers];
         });
     }];
    [searchTask resume];
}

- (IBAction)mapTypeSelector:(id)sender
{
    // Switch between Standard, Satellite, and Hybrid map types
    switch (((UISegmentedControl *)sender).selectedSegmentIndex)
    {
        case 0:
            self.mapView.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.mapView.mapType = kGMSTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = kGMSTypeHybrid;
            break;
        default:
            break;
    }
}

-(void) createMarkers
{
    // Clear all current markers
    [self.mapView clear];
    
    // Create marker for current map center
    GMSMarker *centerMarker = [GMSMarker markerWithPosition:self.mapView.camera.target];
    centerMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    centerMarker.title = @"Center of map";
    centerMarker.appearAnimation = kGMSMarkerAnimationPop;
    centerMarker.map = self.mapView;
    
    // Create markers for current places array
    if (self.places != nil)
    {
        for (int i = 0; i < [self.places count]; i++)
        {
            GMSMarker *marker = [GMSMarker markerWithPosition:[self.places[i]coordinate]];
            marker.title = [self.places[i]name];
            marker.snippet =  [self.places[i]address];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.userData = [self.places[i]placeID];
            marker.map = self.mapView;
        }
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    NSLog(@"Info Window tapped");
    
    /* DETAIL SEARCH */
    NSURL *detailSearchURL  = [NSURL URLWithString: [NSString stringWithFormat:
                                                     @"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=API KEY",
                                                     marker.userData] ];
    NSURLSessionDataTask *detailTask =
    [[NSURLSession sharedSession]
     dataTaskWithURL:detailSearchURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
     {
         // 4: Handle response here
         NSData *jsonDetailsData = [NSData dataWithContentsOfURL:detailSearchURL];
         NSDictionary *jsonDetailsDict = [NSJSONSerialization JSONObjectWithData:jsonDetailsData options:kNilOptions error:nil];
         
         // Save Place's website for use with segue to webView
         self.selectedPlaceWebsite = [jsonDetailsDict valueForKeyPath:@"result.website"];
         
         
         dispatch_async(dispatch_get_main_queue(), ^{
             // If there was no website returned by Google, present an alert
             if (self.selectedPlaceWebsite == nil)
             {
                 UIAlertController *noWebsiteAlert = [UIAlertController
                                                      alertControllerWithTitle:@"No Website"
                                                      message:@"There is no website associated with this place."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction* defaultAction = [UIAlertAction
                                                 actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {}];
                 
                 [noWebsiteAlert addAction:defaultAction];
                 [self presentViewController:noWebsiteAlert animated:YES completion:nil];
                 
             }
             // Else perform segue to webView
             else
             {
                 [self performSegueWithIdentifier:@"webView" sender:self];
             }
         });
     }];
    [detailTask resume];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    webViewController *webVC = segue.destinationViewController;
    webVC.url = [NSURL URLWithString:self.selectedPlaceWebsite];
    NSLog(@"Preparing for segue");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
