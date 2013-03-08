//
//  FlickrPhotoTableViewController.h
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface FlickrPhotoTableViewController : UITableViewController 
@property (nonatomic, strong) NSArray *photos; // of Flickr photo dictionaries
@property (strong, nonatomic) IBOutlet ADBannerView *iAd;
@end
