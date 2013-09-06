//
//  CKPhotoPickerViewController.h
//  CKPhotoPickerViewController
//
//  Created by Jeff Tan-Ang on 5/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CKPhotoPickerImageType) {
    CKPhotoPickerImageTypeLandscape,
    CKPhotoPickerImageTypeSquare
};

@protocol CKPhotoPickerViewControllerDelegate

- (void)photoPickerViewControllerSelectedImage:(UIImage *)image;
- (void)photoPickerViewControllerCloseRequested;

@end

@interface CKPhotoPickerViewController : UIViewController

@property (nonatomic, assign) CKPhotoPickerImageType type;

- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate;
- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate type:(CKPhotoPickerImageType)type;
- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate saveToPhotoAlbum:(BOOL)saveToPhotoAlbum;
- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate type:(CKPhotoPickerImageType)type
      saveToPhotoAlbum:(BOOL)saveToPhotoAlbum showFilters:(BOOL)showFilters;

@end
