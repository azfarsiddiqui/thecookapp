//
//  CKPhotoPickerViewController.m
//  CKPhotoPickerViewController
//
//  Created by Jeff Tan-Ang on 5/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPhotoPickerViewController.h"
#import "UIImage+ProportionalFill.h"

@interface CKPhotoPickerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
    UIPopoverControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id<CKPhotoPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImagePickerController *cameraPickerViewController;
@property (nonatomic, strong) UIImagePickerController *libraryPickerViewController;
@property (nonatomic, strong) UIPopoverController *popoverViewController;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIScrollView *previewScrollView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIButton *libraryButton;
@property (nonatomic, strong) UIButton *snapButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *retakeButton;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation CKPhotoPickerViewController

#define kToolbarHeight  44.0
#define kContentInsets  UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)

- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    [self initImagePicker];
    [self updateButtons];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIView *parentView = [self parentView];
    self.selectedImage = [[info valueForKey:UIImagePickerControllerOriginalImage] imageScaledToFitSize:parentView.bounds.size];
    [self.popoverViewController dismissPopoverAnimated:YES];
    self.popoverViewController = nil;
    self.libraryPickerViewController = nil;
    [self updateImagePreview];
    [self updateButtons];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.delegate photoPickerViewControllerCloseRequested];
}

#pragma mark - UIPopoverControllerDelegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popoverViewController = nil;
    self.libraryPickerViewController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.previewImageView;
}

#pragma mark - Private methods

- (void)initImagePicker {
    if ([self cameraSupported]) {
        UIImagePickerController *pickerViewController = [[UIImagePickerController alloc] init];
        pickerViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerViewController.delegate = self;
        pickerViewController.showsCameraControls = NO;
        self.cameraPickerViewController = pickerViewController;
        [self.view addSubview:self.cameraPickerViewController.view];
    }
}

- (UIView *)parentView {
    return self.cameraPickerViewController ? self.cameraPickerViewController.view : self.view;
}

- (UIButton *)libraryButton {
    if (!_libraryButton) {
        UIView *parentView = [self parentView];
        _libraryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _libraryButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        [_libraryButton addTarget:self action:@selector(libraryTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_libraryButton setTitle:@"Library" forState:UIControlStateNormal];
        [_libraryButton sizeToFit];
        [_libraryButton setFrame:CGRectMake(kContentInsets.left,
                                            parentView.bounds.size.height - _libraryButton.frame.size.height - kContentInsets.bottom,
                                            _libraryButton.frame.size.width,
                                            _libraryButton.frame.size.height)];
    }
    return _libraryButton;
}

- (UIButton *)snapButton {
    if (!_snapButton && [self cameraSupported]) {
        UIView *parentView = [self parentView];
        _snapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _snapButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [_snapButton addTarget:self action:@selector(snapTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_snapButton setTitle:@"Snap" forState:UIControlStateNormal];
        [_snapButton sizeToFit];
        [_snapButton setFrame:CGRectMake(floorf((parentView.bounds.size.width - _snapButton.frame.size.width) / 2.0),
                                         parentView.bounds.size.height - _snapButton.frame.size.height - kContentInsets.bottom,
                                        _snapButton.frame.size.width,
                                        _snapButton.frame.size.height)];
    }
    return _snapButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        UIView *parentView = [self parentView];
        _closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [_closeButton addTarget:self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [_closeButton sizeToFit];
        [_closeButton setFrame:CGRectMake(parentView.bounds.size.width - _closeButton.frame.size.width - kContentInsets.right,
                                          parentView.bounds.size.height - _closeButton.frame.size.height - kContentInsets.bottom,
                                          _closeButton.frame.size.width,
                                          _closeButton.frame.size.height)];
    }
    return _closeButton;
}

- (UIButton *)retakeButton {
    if (!_retakeButton) {
        UIView *parentView = [self parentView];
        _retakeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _retakeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        [_retakeButton addTarget:self action:@selector(retakeTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_retakeButton setTitle:@"Retake" forState:UIControlStateNormal];
        [_retakeButton sizeToFit];
        [_retakeButton setFrame:CGRectMake(kContentInsets.left,
                                           parentView.bounds.size.height - _retakeButton.frame.size.height - kContentInsets.bottom,
                                           _retakeButton.frame.size.width,
                                           _retakeButton.frame.size.height)];
    }
    return _retakeButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        UIView *parentView = [self parentView];
        _saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [_saveButton addTarget:self action:@selector(saveTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [_saveButton sizeToFit];
        [_saveButton setFrame:CGRectMake(parentView.bounds.size.width - _saveButton.frame.size.width - kContentInsets.right,
                                         parentView.bounds.size.height - _saveButton.frame.size.height - kContentInsets.bottom,
                                         _saveButton.frame.size.width,
                                         _saveButton.frame.size.height)];
    }
    return _saveButton;
}

- (void)libraryTapped:(id)sender {
    [self showLibrary:(self.popoverViewController == nil)];
}

- (void)snapTapped:(id)sender {
    [self.cameraPickerViewController takePicture];
}

- (void)closeTapped:(id)sender {
    [self.delegate photoPickerViewControllerCloseRequested];
}

- (void)retakeTapped:(id)sender {
    self.selectedImage = nil;
    [self updateImagePreview];
    [self updateButtons];
}

- (void)saveTapped:(id)sender {
    NSLog(@"ImageView: %@", NSStringFromCGRect(self.previewImageView.frame));
    NSLog(@"ScrollView: %@", NSStringFromCGRect(self.previewScrollView.frame));
    NSLog(@"ScrollView Scale: %f", self.previewScrollView.zoomScale);
    NSLog(@"ScrollView contentOffset: %@", NSStringFromCGPoint(self.previewScrollView.contentOffset));
    
    CGFloat imageScale = self.previewScrollView.zoomScale;
    CGRect imageFrame = CGRectMake(self.previewScrollView.contentOffset.x,
                                   self.previewScrollView.contentOffset.y,
                                   self.previewScrollView.bounds.size.width,
                                   self.previewScrollView.bounds.size.height);
    NSLog(@"imageScale: %f", imageScale);
    NSLog(@"imageFrame: %@", NSStringFromCGRect(imageFrame));
    
    // Maximum size is the scrollView size.
    CGSize imageSize = self.previewScrollView.bounds.size;
    if (imageScale > 1.0) {
        imageSize = CGSizeMake(imageSize.width * imageScale, imageSize.height * imageScale);
    }
    
    // Now resize the image.
    UIImage *resizedImage = [self cropImage:[self.selectedImage imageScaledToFitSize:imageSize] rect:imageFrame];
    [self.delegate photoPickerViewControllerSelectedImage:resizedImage];
}

- (BOOL)cameraSupported {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)showLibrary:(BOOL)show {
    if (show) {
        UIImagePickerController *pickerViewController = [[UIImagePickerController alloc] init];
        pickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerViewController.delegate = self;
        self.libraryPickerViewController = pickerViewController;
        
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:pickerViewController];
        self.popoverViewController = popoverController;
        popoverController.delegate = self;
        [popoverController presentPopoverFromRect:self.libraryButton.frame
                                           inView:self.libraryButton.superview
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    } else {
        [self.popoverViewController dismissPopoverAnimated:YES];
    }
}

- (void)updateButtons {
    UIView *parentView = [self parentView];
    BOOL photoSelected = (self.selectedImage != nil);
    if (photoSelected) {
        self.retakeButton.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        [parentView addSubview:self.retakeButton];
        [parentView addSubview:self.saveButton];
    } else {
        self.libraryButton.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        self.closeButton.alpha = 0.0;
        [parentView addSubview:self.libraryButton];
        [parentView addSubview:self.saveButton];
        [parentView addSubview:self.closeButton];
    }
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.libraryButton.alpha = photoSelected ? 0.0 : 1.0;
                         self.snapButton.alpha = photoSelected ? 0.0 : 1.0;
                         self.closeButton.alpha = photoSelected ? 0.0 : 1.0;
                         self.retakeButton.alpha = photoSelected ? 1.0 : 0.0;
                         self.saveButton.alpha = photoSelected ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished)  {
                         if (photoSelected) {
                             [self.libraryButton removeFromSuperview];
                             [self.snapButton removeFromSuperview];
                             [self.closeButton removeFromSuperview];
                         } else {
                             [self.retakeButton removeFromSuperview];
                             [self.saveButton removeFromSuperview];
                         }
                     }];
}

- (void)updateImagePreview {
    UIView *parentView = [self parentView];
    BOOL photoSelected = (self.selectedImage != nil);
    if (photoSelected) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:parentView.bounds];
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.alwaysBounceVertical = YES;
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = 1.0;
        scrollView.delegate = self;
        scrollView.alpha = 0.0;
        [parentView addSubview:scrollView];
        self.previewScrollView = scrollView;
        
        UIImageView *previewImageView = [[UIImageView alloc] initWithImage:self.selectedImage];
        previewImageView.frame = scrollView.bounds;
        previewImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [scrollView addSubview:previewImageView];
        self.previewImageView = previewImageView;
    }
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.previewScrollView.alpha = photoSelected ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished)  {
                         if (!photoSelected) {
                             [self.previewScrollView removeFromSuperview];
                             self.previewScrollView = nil;
                             self.previewImageView = nil;
                         }
                     }];
}

- (UIImage *)cropImage:(UIImage *)image rect:(CGRect)rect {
    if (image.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * image.scale,
                          rect.origin.y * image.scale,
                          rect.size.width * image.scale,
                          rect.size.height * image.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}
@end
