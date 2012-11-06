//
//  DetailViewController.h
//  FlickrNearMe
//
//  Created by Admin on 11/5/12.
//  Copyright (c) 2012 Jonathan Emrich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
