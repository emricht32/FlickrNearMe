//
//  MasterViewController.h
//  FlickrNearMe
//
//  Created by Admin on 11/5/12.
//  Copyright (c) 2012 Jonathan Emrich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
