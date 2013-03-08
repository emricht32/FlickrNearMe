//
//  FlickrPhotoTableViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "FlickrPhotoTableViewController.h"
#import "FlickrFetcher.h"
#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "SystemVersioningPreProcessorMacros.h"

#define my_dispatch_release(object) ({ dispatch_object_t _o = (object); \
_dispatch_object_validate(_o); })
#define OS_OBJECT_USE_OBJC 0

@interface FlickrPhotoTableViewController() <MapViewControllerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate, ADBannerViewDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *places;
@property (strong, nonatomic) NSString* location;
@property (assign, nonatomic) double latitude, longitude;
@property (strong, nonatomic) CLLocation* myLocation;
@property (assign, nonatomic) BOOL bannerIsVisible;
@end

@implementation FlickrPhotoTableViewController

@synthesize photos = _photos;
@synthesize locationManager = _locationManager;
@synthesize places = _places;
@synthesize location = _location;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize myLocation = _myLocation;
@synthesize iAd = _iAd;
@synthesize bannerIsVisible = _bannerIsVisible;

- (void)setMyLocation:(CLLocation *)myLocation{
    if (_myLocation != myLocation) {
        _myLocation = myLocation;
        [self updateSplitViewDetail];
    }
}

-(void) viewDidLoad{
    [super viewDidLoad];
    self.places = [[NSMutableArray alloc]init];
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.distanceFilter = kCLLocationAccuracyKilometer;
    self.locationManager.delegate = self;
    self.tableView.tableFooterView = self.iAd;
    //[self scrollViewDidScroll:self.tableView];
    [self refresh:self];
    [self.locationManager startUpdatingLocation];
}

-(void) viewWillAppear:(BOOL)animated{
    if(self.iAd.isBannerLoaded){
        self.bannerIsVisible = YES;
        self.iAd.hidden = NO;
    }
    else{
        self.bannerIsVisible = NO;
        self.iAd.hidden = YES;
    }
    [self adPlacementHelper];
}
-(void) viewDidUnload{
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [self.locationManager stopUpdatingLocation];
    self.myLocation = newLocation;
    self.latitude = newLocation.coordinate.latitude;
    self.longitude = newLocation.coordinate.longitude;
    /*
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString * location = ([placemarks count] > 0) ? [[placemarks objectAtIndex:0] locality] : @"Not Found";
        self.location = location;
        double latitude = ([placemarks count] > 0) ? ((CLPlacemark*)placemarks[0]).location.coordinate.latitude : 0;
        double longitude = ([placemarks count] > 0) ? ((CLPlacemark*)placemarks[0]).location.coordinate.longitude : 0;
        self.latitude = latitude;
        self.longitude = longitude;
       // NSLog(@"places2 = %@",self.places);
        
    }];
     */
    [self.locationManager startMonitoringSignificantLocationChanges];
     
}

- (IBAction)refresh:(id)sender
{
    // might want to use introspection to be sure sender is UIBarButtonItem
    // (if not, it can skip the spinner)
    // that way this method can be a little more generic
    if([sender isKindOfClass:[UIBarButtonItem class]]){
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    }
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        //NSLog(@"places = %@",self.places);
        if(![self.location isEqualToString:@"Not Found"]){
            //NSDictionary *dictPlace = [[NSDictionary alloc]initWithObjectsAndKeys:[self.places objectAtIndex:0], FLICKR_PLACE_ID, nil];
            //NSArray *photos = [FlickrFetcher recentGeoreferencedPhotos];
            //NSArray *photos = [FlickrFetcher photosInPlace:dictPlace maxResults:50];
            NSArray* photos = [FlickrFetcher photosNearLatitude:self.latitude andLongitude:self.longitude maxResults:250];
            //NSArray *tempPlaces = [FlickrFetcher topPlaces];
            NSLog(@"photos = %@",photos);
            
            //NSLog(@"tempPlaces = %@", tempPlaces);
            dispatch_async(dispatch_get_main_queue(), ^{
                if([sender isKindOfClass:[UIBarButtonItem class]]){
                    self.navigationItem.rightBarButtonItem = sender;
                }
                self.photos = photos;
                //self.places = [tempPlaces mutableCopy];
            });
        }
    });
    //if(SYSTEM_VERSION_LESS_THAN(@"6.0") )
        dispatch_release(downloadQueue);
    
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
    for (NSDictionary *photo in self.photos) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

- (void)updateSplitViewDetail
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if ([detail isKindOfClass:[MapViewController class]]) {
        MapViewController *mapVC = (MapViewController *)detail;
        mapVC.delegate = self;
        mapVC.annotations = [self mapAnnotations];
        mapVC.location = self.myLocation;
    }
}

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos) {
        _photos = photos;
        [self updateSplitViewDetail];
        // Model changed, so update our View (the table)
        if (self.tableView.window) [self.tableView reloadData];
    }
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    cell.textLabel.text = [photo objectForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [photo objectForKey:FLICKR_PHOTO_OWNER];
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"MapView"]){
        MapViewController* mvc = (MapViewController*) segue.destinationViewController;
        mvc.delegate = self;
        mvc.annotations = [self mapAnnotations];
        mvc.location = self.myLocation;
    }
}

#pragma mark ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self adPlacementHelper];
    
}

-(void) adPlacementHelper{
    CGRect iAdFrame = self.iAd.frame;
    CGFloat newOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - iAdFrame.size.height;
    CGRect newIAdFrame = CGRectMake(iAdFrame.origin.x, newOriginY, iAdFrame.size.width, iAdFrame.size.height);
    self.iAd.frame = newIAdFrame;
  
}

#pragma mark ADBannerViewDelegate

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"didFailToReceiveAdWithError with Error: %@", error);
    if (self.bannerIsVisible)
    {
        /*
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectMake(0.0,350.0,banner.frame.size.width,banner.frame.size.height);
        [UIView commitAnimations];
         */
        self.iAd.hidden = YES;
        self.bannerIsVisible = NO;
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"bannerViewDidLoadAd");
    if (!self.bannerIsVisible)
    {
        /*
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectMake(0.0,317.0,banner.frame.size.width,banner.frame.size.height);
        [UIView commitAnimations];
         */
        self.bannerIsVisible = YES;
        self.iAd.hidden = NO;
    }
}

- (int)getBannerHeight:(UIDeviceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return 32;
    } else {
        return 50;
    }
}

- (int)getBannerHeight {
    return [self getBannerHeight:[UIDevice currentDevice].orientation];
}

@end
