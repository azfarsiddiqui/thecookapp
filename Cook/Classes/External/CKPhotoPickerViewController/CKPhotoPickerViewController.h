//
//  CKPhotoPickerViewController.h
//  CKPhotoPickerViewController
//
//  Created by Jeff Tan-Ang on 5/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKPhotoPickerViewControllerDelegate

- (void)photoPickerViewControllerSelectedImage:(UIImage *)image;
- (void)photoPickerViewControllerCloseRequested;

@end

@interface CKPhotoPickerViewController : UIViewController

- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate;
- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate saveToPhotoAlbum:(BOOL)saveToPhotoAlbum;

@end
