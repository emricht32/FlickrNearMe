//
//  CamaraCaptureViewController.m
//  FlickrNearMe
//
//  Created by Admin on 11/8/12.
//  Copyright (c) 2012 Jonathan Emrich. All rights reserved.
//

#import "CamaraCaptureViewController.h"

@interface CamaraCaptureViewController ()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CamaraCaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   
}
- (IBAction)camara:(UIBarButtonItem *)sender {
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    
    //Depricated***[[self presentModalViewController:imagePicker animated:YES];
    [self presentViewController:imagePicker animated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //Depricated***[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    image = nil;
    // You have the image. You can use this to present the image in the next view like you require in `#3`.
    
    //Depricated***[[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{}];

}

@end
