
//

#import "MapViewController.h"
#import "MKMapView+ZoomLevel.h"
//#import <Twitter/Twitter.h>

#define ZOOM_LEVEL_PAD 11
#define ZOOM_LEVEL_PHONE 11
@interface MapViewController() <MKMapViewDelegate>
- (IBAction)getBounds:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize location = _location;

-(void)setLocation:(CLLocation *)location{
    //if(_location != location){
        _location = location;
        CLLocationDegrees latitude = self.location.coordinate.latitude;
        CLLocationDegrees longitude = self.location.coordinate.longitude;
        CLLocationCoordinate2D loc2D = CLLocationCoordinate2DMake(latitude, longitude);
        int zoomLevel = ZOOM_LEVEL_PAD;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            zoomLevel = ZOOM_LEVEL_PHONE;
    }
    NSLog(@"%f, %f",self.mapView.bounds.size.width, self.mapView.bounds.size.height);
    if(![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [self.mapView setCenterCoordinate:loc2D zoomLevel:zoomLevel animated:YES];
    }
    //}
}

#pragma mark - Synchronize Model and View

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.rightCalloutAccessoryView = btn;
    }
    //UIButton* btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //aView.rightCalloutAccessoryView = btn;
    aView.annotation = annotation;
    //[(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    NSLog(@"%@", aView.rightCalloutAccessoryView);
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    //NSLog(@"aView.annotation = %@", aView.annotation);
    UIImage *image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
    NSLog(@"image = %@",image);
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.image = image;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
    aView.leftCalloutAccessoryView = imageView;
    //UIButton* btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    //aView.rightCalloutAccessoryView = btn;
   // NSLog(@"%@",aView.rightCalloutAccessoryView);
    //NSLog(@"leftCalloutAccessoryView = %@",((UIImageView *)aView.leftCalloutAccessoryView).image);
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"callout accessory tapped for annotation %@", [view.annotation title]);
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CLLocationDegrees latitude = self.location.coordinate.latitude;
    CLLocationDegrees longitude = self.location.coordinate.longitude;
    CLLocationCoordinate2D loc2D = CLLocationCoordinate2DMake(latitude, longitude);
    
    int zoomLevel = ZOOM_LEVEL_PAD;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        zoomLevel = ZOOM_LEVEL_PHONE;
    }
    
    NSLog(@"%f, %f",self.mapView.bounds.size.width, self.mapView.bounds.size.height);
    [self.mapView setCenterCoordinate:loc2D zoomLevel:zoomLevel animated:YES];
    NSLog(@"%d",[self.mapView getZoomLevel]);
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)getBounds:(id)sender {
    NSLog(@"%f, %f",self.mapView.bounds.size.width, self.mapView.bounds.size.height);
}
@end
