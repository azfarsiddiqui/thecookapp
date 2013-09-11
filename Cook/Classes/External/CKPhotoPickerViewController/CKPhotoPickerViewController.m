//
//  CKPhotoPickerViewController.m
//  CKPhotoPickerViewController
//
//  Created by Jeff Tan-Ang on 5/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPhotoPickerViewController.h"
#import "UIImage+ProportionalFill.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>
#import "CKPhotoFilterSliderView.h"
#import "ImageHelper.h"
#import "CKActivityIndicatorView.h"

@interface CKPhotoPickerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
    UIPopoverControllerDelegate, UIScrollViewDelegate, CKNotchSliderViewDelegate>

@property (nonatomic, weak) id<CKPhotoPickerViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL saveToPhotoAlbum;
@property (nonatomic, assign) BOOL showFilters;
@property (nonatomic, strong) UIImagePickerController *cameraPickerViewController;
@property (nonatomic, strong) UIImagePickerController *libraryPickerViewController;
@property (nonatomic, strong) UIPopoverController *popoverViewController;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIScrollView *previewScrollView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *squareOverlayView;
@property (nonatomic, strong) UIButton *libraryButton;
@property (nonatomic, strong) UIButton *snapButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *retakeButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIView *vignetteView;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) CIContext *filterContext;
@property (nonatomic, strong) CKPhotoFilterSliderView *filterPickerView;
@property UIDeviceOrientation currentOrientation;
@property (nonatomic, strong) UIView *flashView;

@end

@implementation CKPhotoPickerViewController

#define kToolbarHeight  44.0
#define kContentInsets  UIEdgeInsetsMake(20.0, 15.0, 10.0, 15.0)
#define kSquareCropHeight 500
#define kSquareCropOrigin CGPointMake(260, 134)
#define MAX_IMAGE_WIDTH 2048
#define MAX_IMAGE_HEIGHT 1536

- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate {
    return [self initWithDelegate:delegate saveToPhotoAlbum:YES];
}

- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate type:(CKPhotoPickerImageType)type {
    return [self initWithDelegate:delegate type:type saveToPhotoAlbum:YES showFilters:YES];
}

- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate saveToPhotoAlbum:(BOOL)saveToPhotoAlbum {
    return [self initWithDelegate:delegate type:CKPhotoPickerImageTypeLandscape saveToPhotoAlbum:saveToPhotoAlbum showFilters:YES];
}

- (id)initWithDelegate:(id<CKPhotoPickerViewControllerDelegate>)delegate type:(CKPhotoPickerImageType)type
      saveToPhotoAlbum:(BOOL)saveToPhotoAlbum showFilters:(BOOL)showFilters {
    
    if (self = [super init]) {
        self.type = type;
        self.saveToPhotoAlbum = saveToPhotoAlbum;
        self.delegate = delegate;
        self.filterContext = [CIContext contextWithOptions:nil];
        self.showFilters = showFilters;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.currentOrientation = [[UIDevice currentDevice] orientation];
    
    self.activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
    self.activityView.center = [self parentView].center;
    [[self parentView] addSubview:self.activityView];
    
    // Square?
    if (self.type == CKPhotoPickerImageTypeSquare) {
        self.squareOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_customise_photo_overlay.png"]];
        self.squareOverlayView.frame = self.view.bounds;
        [[self parentView] addSubview:self.squareOverlayView];
    }
}

- (void)receivedRotate:(id)sender
{
    NSLog(@"receivedRotate");
    UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if(interfaceOrientation != UIDeviceOrientationUnknown) {
        NSLog(@"Rotated to: %i", interfaceOrientation);
    } else {
        NSLog(@"Unknown device orientation");
    }
}

- (void)rotateButtonsToOrientation:(UIDeviceOrientation)deviceOrientation
{
//    switch (self.currentOrientation) {
//        case UIDeviceOrientationPortrait:
//            <#statements#>
//            break;
//            
//        default:
//            break;
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initImagePicker];
    [self updateButtons];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGFloat cropWidth = chosenImage.size.width > MAX_IMAGE_WIDTH ? MAX_IMAGE_WIDTH : chosenImage.size.width;
    CGFloat cropHeight = chosenImage.size.height > MAX_IMAGE_HEIGHT ? MAX_IMAGE_HEIGHT : chosenImage.size.height;
    chosenImage = [chosenImage imageCroppedToFitSize:CGSizeMake(cropWidth, cropHeight)]; //[ImageHelper scaledImage:chosenImage size:CGSizeMake(cropWidth, cropHeight)];
    self.selectedImage = chosenImage;
    [self updateImagePreview];
    [self updateButtons];
    [self.popoverViewController dismissPopoverAnimated:YES];
    self.popoverViewController = nil;
    self.libraryPickerViewController = nil;
    [self removeImagePicker];
    [self.activityView stopAnimating];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // Cleanup manually as this doesn't call the popover delegate.
    [self.popoverViewController dismissPopoverAnimated:YES];
    self.popoverViewController = nil;
    self.libraryPickerViewController = nil;
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
    if ([self cameraSupported] && !self.cameraPickerViewController) {
        UIImagePickerController *pickerViewController = [[UIImagePickerController alloc] init];
        pickerViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerViewController.delegate = self;
        pickerViewController.showsCameraControls = NO;
        pickerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.cameraPickerViewController = pickerViewController;
        [self.view addSubview:self.cameraPickerViewController.view];
        if (self.squareOverlayView) [self.view bringSubviewToFront:self.squareOverlayView];
    }
}

- (void)removeImagePicker {
    if (self.cameraPickerViewController)
    {
        [self.cameraPickerViewController.view removeFromSuperview];
        self.cameraPickerViewController = nil;
    }
}

- (UIView *)parentView {
    return self.view;
}

- (CGRect)parentBounds {
    return [self parentView].bounds;
}

- (UIButton *)libraryButton {
    if (!_libraryButton) {
        UIView *parentView = [self parentView];
        _libraryButton = [self buttonWithImage:[UIImage imageNamed:@"cook_customise_photo_btn_cameraroll.png"]
                                 selectedImage:[UIImage imageNamed:@"cook_customise_photo_btn_cameraroll_onpress.png"]
                                        target:self selector:@selector(libraryTapped:)];
        _libraryButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
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
        _snapButton = [self buttonWithImage:[UIImage imageNamed:@"cook_customise_photo_btn_takephoto.png"]
                              selectedImage:[UIImage imageNamed:@"cook_customise_photo_btn_takephoto_onpress.png"]
                                     target:self selector:@selector(snapTapped:)];
        _snapButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        [_snapButton setFrame:CGRectMake(floorf((parentView.bounds.size.width - _snapButton.frame.size.width) / 2.0),
                                         parentView.bounds.size.height - _snapButton.frame.size.height - kContentInsets.bottom,
                                        _snapButton.frame.size.width,
                                        _snapButton.frame.size.height)];
    }
    return _snapButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [self buttonWithImage:[UIImage imageNamed:@"cook_btns_photo_cancel.png"] target:self selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_closeButton setFrame:CGRectMake(kContentInsets.left,
                                          kContentInsets.top,
                                          _closeButton.frame.size.width,
                                          _closeButton.frame.size.height)];
    }
    return _closeButton;
}

- (UIButton *)retakeButton {
    if (!_retakeButton) {
        _retakeButton = [self buttonWithImage:[UIImage imageNamed:@"cook_btns_photo_back.png"] target:self selector:@selector(retakeTapped:)];
        _retakeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_retakeButton setFrame:CGRectMake(kContentInsets.left,
                                           kContentInsets.top,
                                           _retakeButton.frame.size.width,
                                           _retakeButton.frame.size.height)];
    }
    return _retakeButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
//        CGRect parentBounds = [self parentBounds];
        _saveButton = [self buttonWithImage:[UIImage imageNamed:@"cook_btns_photo_okay.png"] target:self selector:@selector(saveTapped:)];
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_saveButton setFrame:CGRectMake(1024.0 - _saveButton.frame.size.width - kContentInsets.right,  // UGH!
                                         kContentInsets.top,
                                         _saveButton.frame.size.width,
                                         _saveButton.frame.size.height)];
    }
    return _saveButton;
}

- (UIView *)vignetteView {
    if (!_vignetteView) {
        _vignetteView = [[UIView alloc] initWithFrame:self.view.frame];
        _vignetteView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UIImage *bottomImage = [UIImage imageNamed:@"cook_book_inner_darkenphoto_strip_bottom"];
        UIImageView *bottomVignetteView = [[UIImageView alloc] initWithImage:[bottomImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
        bottomVignetteView.frame = CGRectMake(0, _vignetteView.frame.size.height - bottomVignetteView.frame.size.height, self.view.frame.size.width, bottomVignetteView.frame.size.height);
        _vignetteView.userInteractionEnabled = NO;
        [_vignetteView addSubview:bottomVignetteView];
    }
    return _vignetteView;
}

- (CKPhotoFilterSliderView *)filterPickerView {
    CGRect parentBounds = [self parentBounds];
    if (!_filterPickerView) {
        _filterPickerView = [[CKPhotoFilterSliderView alloc] initWithDelegate:self];
        _filterPickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    }
    [_filterPickerView setFrame:CGRectMake(floorf((parentBounds.size.width - _filterPickerView.frame.size.width) / 2.0),
                                           768 - _filterPickerView.frame.size.height - kContentInsets.bottom,  // UGH!
                                           _filterPickerView.frame.size.width,
                                           _filterPickerView.frame.size.height)];
    return _filterPickerView;
}

- (UIButton *)flashButton {
    if (!_flashButton && [self cameraSupported] && [self flashSupported]) {
        _flashButton = [self buttonWithImage:[self imageForFlashMode]
                               selectedImage:[UIImage imageNamed:@"cook_customise_photo_btn_flash_onpress.png"]
                                      target:self selector:@selector(flashTapped:)];
        _flashButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [_flashButton setFrame:CGRectMake(self.toggleButton.frame.origin.x - _flashButton.frame.size.width + 3.0,
                                          self.toggleButton.frame.origin.y,
                                          _flashButton.frame.size.width,
                                          _flashButton.frame.size.height)];
    }
    return _flashButton;
}

- (UIButton *)toggleButton {
    if (!_toggleButton && [self cameraSupported]) {
        CGRect parentBounds = [self parentBounds];
        _toggleButton = [self buttonWithImage:[UIImage imageNamed:@"cook_customise_photo_btn_cameratoggle.png"]
                                selectedImage:[UIImage imageNamed:@"cook_customise_photo_btn_cameratoggle_onpress.png"]
                                       target:self selector:@selector(toggleTapped:)];
        _toggleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [_toggleButton setFrame:CGRectMake(parentBounds.size.width - _toggleButton.frame.size.width - kContentInsets.right,
                                           parentBounds.size.height - _toggleButton.frame.size.height - kContentInsets.bottom,
                                           _toggleButton.frame.size.width,
                                           _toggleButton.frame.size.height)];
    }
    return _toggleButton;
}

- (UIImage *)imageForFlashMode {
    UIImage *flashImage = nil;
    switch (self.cameraPickerViewController.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeOff:
            flashImage = [UIImage imageNamed:@"cook_customise_photo_btn_flash_off.png"];
            break;
        case UIImagePickerControllerCameraFlashModeAuto:
            flashImage = [UIImage imageNamed:@"cook_customise_photo_btn_flash_auto.png"];
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            flashImage = [UIImage imageNamed:@"cook_customise_photo_btn_flash_on.png"];
            break;
        default:
            break;
    }
    return flashImage;
}

- (void)libraryTapped:(id)sender {
    [self showLibrary:(self.popoverViewController == nil)];
}

- (void)snapTapped:(id)sender {
    [[self parentView] bringSubviewToFront:self.activityView];
    [self.activityView startAnimating];
    [self.cameraPickerViewController takePicture];
}

- (void)closeTapped:(id)sender {
    [self.delegate photoPickerViewControllerCloseRequested];
}

- (void)retakeTapped:(id)sender {
    self.selectedImage = nil;
    [self initImagePicker];
    [self updateImagePreview];
    [self updateButtons];
}

- (void)flashTapped:(id)sender {
    [self toggleFlash];
}

- (void)toggleTapped:(id)sender {
    [self toggleCamera];
}

- (void)saveTapped:(id)sender {
    // Spin activity and disable buttons.
    [self updateButtonsEnabled:NO];
    [[self parentView] bringSubviewToFront:self.activityView];
    [self.activityView startAnimating];
    
    // Detach and save photo asynchronously.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self savePhoto];
    });
}

- (void)savePhoto {
    
    CGFloat imageScale = self.selectedImage.size.width / self.previewScrollView.bounds.size.width;
    CGFloat deviceScale = [self deviceScale];
    CGFloat scale = (deviceScale / self.previewScrollView.zoomScale) * imageScale;
    CGRect visibleRect = CGRectZero;
    if (self.type == CKPhotoPickerImageTypeSquare)
    {
        visibleRect = CGRectMake(kSquareCropOrigin.x, kSquareCropOrigin.y, kSquareCropHeight, kSquareCropHeight);
    }
    else {
        visibleRect = CGRectMake(self.previewScrollView.contentOffset.x,
                                 self.previewScrollView.contentOffset.y,
                                 self.previewScrollView.bounds.size.width,
                                 self.previewScrollView.bounds.size.height);
    }
    // Crop out the visible image off the scrollView.
    UIImage *visibleImage = [self cropImage:self.previewImageView.image atRect:visibleRect scale:scale];
    
    // Save to photo album.
    if (self.cameraPickerViewController.sourceType == UIImagePickerControllerSourceTypeCamera && self.saveToPhotoAlbum) {
        
        // Check status
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status != ALAuthorizationStatusAuthorized) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                            message:@"Please give Cook permission to access your photo library in your settings app." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            NSLog(@"Saved to camera roll.");
            UIImageWriteToSavedPhotosAlbum(visibleImage, nil, nil, nil);
        }
    }
    
    [self.delegate photoPickerViewControllerSelectedImage:visibleImage];
    [self.activityView stopAnimating];
}

- (BOOL)cameraSupported {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)flashSupported {
    return [UIImagePickerController isFlashAvailableForCameraDevice:self.cameraPickerViewController.cameraDevice];
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
    [self updateButtonsEnabled:YES];
}

- (void)updateButtonsEnabled:(BOOL)enabled {
    UIView *parentView = [self parentView];
    BOOL photoSelected = (self.selectedImage != nil);
    if (photoSelected) {
        self.retakeButton.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        self.filterPickerView.alpha = 0.0;
        self.vignetteView.alpha = 0.0;
        [parentView addSubview:self.retakeButton];
        [parentView addSubview:self.saveButton];
        [parentView addSubview:self.vignetteView];
        if (self.showFilters)
            [parentView addSubview:self.filterPickerView];
    } else {
        self.closeButton.alpha = 0.0;
        self.libraryButton.alpha = 0.0;
        self.snapButton.alpha = 0.0;
        self.flashButton.alpha = 0.0;
        self.toggleButton.alpha = 0.0;
        [parentView addSubview:self.closeButton];
        [parentView addSubview:self.libraryButton];
        [parentView addSubview:self.snapButton];
        [parentView addSubview:self.flashButton];
        [parentView addSubview:self.toggleButton];
    }
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.closeButton.alpha = photoSelected ? 0.0 : 1.0;
                         self.libraryButton.alpha = photoSelected ? 0.0 : 1.0;
                         self.snapButton.alpha = photoSelected ? 0.0 : 1.0;
                         self.flashButton.alpha = photoSelected ? 0.0 : 1.0;
                         self.toggleButton.alpha = photoSelected ? 0.0 : 1.0;
                         self.retakeButton.alpha = photoSelected ? 1.0 : 0.0;
                         self.saveButton.alpha = photoSelected ? 1.0 : 0.0;
                         self.filterPickerView.alpha = photoSelected ? 1.0 : 0.0;
                         self.vignetteView.alpha = photoSelected ? 1.0 : 0.0;
                         
                         self.closeButton.userInteractionEnabled = enabled;
                         self.libraryButton.userInteractionEnabled = enabled;
                         self.snapButton.userInteractionEnabled = enabled;
                         self.flashButton.userInteractionEnabled = enabled;
                         self.toggleButton.userInteractionEnabled = enabled;
                         self.retakeButton.userInteractionEnabled = enabled;
                         self.saveButton.userInteractionEnabled = enabled;
                         self.filterPickerView.userInteractionEnabled = enabled;
                     }
                     completion:^(BOOL finished)  {
                         if (photoSelected) {
                             [self.closeButton removeFromSuperview];
                             [self.libraryButton removeFromSuperview];
                             [self.snapButton removeFromSuperview];
                             [self.flashButton removeFromSuperview];
                             [self.toggleButton removeFromSuperview];
                         } else {
                             [self.retakeButton removeFromSuperview];
                             [self.saveButton removeFromSuperview];
                             [self.filterPickerView removeFromSuperview];
                             [self.vignetteView removeFromSuperview];
                         }
                     }];
}



- (void)updateImagePreview {
    UIView *parentView = [self parentView];
    BOOL photoSelected = (self.selectedImage != nil);
    
    if (photoSelected) {
        CGRect visibleFrame = parentView.bounds;
        
        UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:visibleFrame];
        previewImageView.image = [self.selectedImage imageCroppedToFitSize:previewImageView.bounds.size];
        previewImageView.autoresizingMask = UIViewAutoresizingNone;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:parentView.bounds];
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.contentSize = previewImageView.frame.size;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.alwaysBounceVertical = YES;
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = 1.0;
        scrollView.delegate = self;
        scrollView.alpha = 0.0;
        [parentView addSubview:scrollView];
        self.previewScrollView = scrollView;
        
        if (self.type == CKPhotoPickerImageTypeSquare) {
            scrollView.contentInset = UIEdgeInsetsMake(kSquareCropOrigin.y, kSquareCropOrigin.x, kSquareCropOrigin.y, kSquareCropOrigin.x);
        }
        
        [scrollView addSubview:previewImageView];
        self.previewImageView = previewImageView;
        
        // Reset slider to 'None'
        if (self.showFilters)
        {
            [self.filterPickerView slideToNotchIndex:0 animated:NO];
        }
    }
    if (self.squareOverlayView) [[self parentView] bringSubviewToFront:self.squareOverlayView];
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.previewScrollView.alpha = photoSelected ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished)  {
                         if (!photoSelected) {
//                             [self.squareOverlayView removeFromSuperview];
                             [self.previewScrollView removeFromSuperview];
                             self.previewScrollView = nil;
                             self.previewImageView = nil;
//                             self.squareOverlayView = nil;
                         }
                     }];

}

- (UIImage *)cropImage:(UIImage *)sourceImage atRect:(CGRect)frame scale:(CGFloat)scale {
    frame = (CGRect){
        frame.origin.x * scale,
        frame.origin.y * scale,
        frame.size.width * scale,
        frame.size.height * scale
    };
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([sourceImage CGImage], frame);
    UIImage* croppedImage = [[UIImage alloc] initWithCGImage:croppedImageRef
                                                       scale:scale
                                                 orientation:sourceImage.imageOrientation];
    CGImageRelease(croppedImageRef);
    return croppedImage;
}

- (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    return [self buttonWithImage:image selectedImage:nil target:target selector:selector];
}

- (UIButton *)buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(id)target
                     selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    if (selectedImage) {
        [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
        [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    }
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    button.userInteractionEnabled = (target != nil && selector != nil);
    button.autoresizingMask = UIViewAutoresizingNone;
    return button;
}

- (CGFloat)deviceScale {
    return [UIScreen mainScreen].scale;
}

- (void)toggleFlash {
    self.cameraPickerViewController.cameraFlashMode = [self nextFlashToggleMode];
    [self.flashButton setBackgroundImage:[self imageForFlashMode] forState:UIControlStateNormal];
}

- (void)toggleCamera {
    self.cameraPickerViewController.cameraDevice = [self nextCameraDevice];
}

- (UIImagePickerControllerCameraFlashMode)nextFlashToggleMode {
    
    UIImagePickerControllerCameraFlashMode nextMode = UIImagePickerControllerCameraFlashModeOff;
    switch (self.cameraPickerViewController.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeOff:
            nextMode = UIImagePickerControllerCameraFlashModeAuto;
            break;
        case UIImagePickerControllerCameraFlashModeAuto:
            nextMode = UIImagePickerControllerCameraFlashModeOn;
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            nextMode = UIImagePickerControllerCameraFlashModeAuto;
            break;
        default:
            break;
    }
    
    return nextMode;
}

- (UIImagePickerControllerCameraDevice)nextCameraDevice {
    UIImagePickerControllerCameraDevice nextDevice = UIImagePickerControllerCameraDeviceRear;
    if (self.cameraPickerViewController.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        return UIImagePickerControllerCameraDeviceFront;
    } else if (self.cameraPickerViewController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.cameraPickerViewController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    return nextDevice;
}

#pragma mark - CKPhotoFilterSliderView delegate methods
- (void)notchSliderView:(CKNotchSliderView *)sliderView selectedIndex:(NSInteger)notchIndex
{
    @autoreleasepool {
        UIImage *filteredImage = self.selectedImage;
        switch (notchIndex) {
            case CKPhotoFilterTypeNone:
                break;
            case CKPhotoFilterAuto:
                filteredImage = [self autoFilterOnImage:filteredImage];
                break;
            case CKPhotoFilterOutdoors:
                filteredImage = [self outdoorFilterOnImage:filteredImage];
                break;
            case CKPhotoFilterIndoors:
                filteredImage = [self indoorFilterOnImage:filteredImage];
                break;
            case CKPhotoFilterVibrant:
                filteredImage = [self vibrantFilterOnImage:filteredImage];
                break;
            case CKPhotoFilterCool:
                filteredImage = [self coolFilterOnImage:filteredImage];
                break;
            case CKPhotoFilterWarm:
                filteredImage = [self warmFilterOnImage:filteredImage];
                break;
            case CKPhotoFilterText:
                filteredImage = [self textFilterOnImage:filteredImage];
                break;
            default:
                break;
        }
        self.previewImageView.image = filteredImage;
    }
}

#pragma mark - Image filtering methods
- (UIImage *)indoorFilterOnImage:(UIImage *)image
{
    CIImage *filteredImage = [[CIImage alloc] initWithImage:image];
    filteredImage = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, filteredImage, @"inputContrast", [NSNumber numberWithFloat:1.03], @"inputSaturation", [NSNumber numberWithFloat:1.04], nil].outputImage;
    filteredImage = [CIFilter filterWithName:@"CIUnsharpMask" keysAndValues:kCIInputImageKey, filteredImage,
                     @"inputRadius", [NSNumber numberWithFloat:1.7],
                     @"inputIntensity", [NSNumber numberWithFloat:0.3], nil].outputImage;
    CGImageRef returnCGImage = [self.filterContext createCGImage:filteredImage fromRect:filteredImage.extent];
    UIImage *returnImage = [UIImage imageWithCGImage:returnCGImage scale:image.scale orientation:image.imageOrientation];
    filteredImage = nil;
    CGImageRelease(returnCGImage);
    return returnImage;
}

- (UIImage *)autoFilterOnImage:(UIImage *)image
{
    UIImage *returnImage;
    @autoreleasepool {
        CIImage *filteredImage = [[CIImage alloc] initWithImage:image];
        NSArray *adjustments = [filteredImage autoAdjustmentFiltersWithOptions:@{kCIImageAutoAdjustEnhance: @YES,
                                                         kCIImageAutoAdjustRedEye: @NO}];
        for (CIFilter *filter in adjustments){
            [filter setValue:filteredImage forKey:kCIInputImageKey];
            filteredImage = filter.outputImage;
        }
        CGImageRef returnCGImage = [self.filterContext createCGImage:filteredImage fromRect:filteredImage.extent];
        returnImage = [UIImage imageWithCGImage:returnCGImage scale:image.scale orientation:image.imageOrientation];
        filteredImage = nil;
        CGImageRelease(returnCGImage);
    }
    return returnImage;
}

- (UIImage *)outdoorFilterOnImage:(UIImage *)image
{
    UIImage *returnImage;
    @autoreleasepool {
        CIImage *filteredImage = [[CIImage alloc] initWithImage:image];
        filteredImage = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, filteredImage, @"inputContrast", [NSNumber numberWithFloat:0.9], @"inputSaturation", [NSNumber numberWithFloat:1.0], nil].outputImage;
//        filteredImage = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, filteredImage, @"inputEV", [NSNumber numberWithFloat:1.02], nil].outputImage;
        filteredImage = [CIFilter filterWithName:@"CIVibrance" keysAndValues:kCIInputImageKey, filteredImage, @"inputAmount", [NSNumber numberWithFloat:1.1], nil].outputImage;
        CGImageRef returnCGImage = [self.filterContext createCGImage:filteredImage fromRect:filteredImage.extent];
        returnImage = [UIImage imageWithCGImage:returnCGImage scale:image.scale orientation:image.imageOrientation];
        filteredImage = nil;
        CGImageRelease(returnCGImage);
    }
    return returnImage;
}

- (UIImage *)vibrantFilterOnImage:(UIImage *)image
{
    UIImage *returnImage;
    @autoreleasepool {
        CIImage *filteredImage = [[CIImage alloc] initWithImage:image];
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectChrome" keysAndValues:kCIInputImageKey, filteredImage, nil].outputImage;
        //        filteredImage = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, filteredImage,
        //                         @"inputBrightness", [NSNumber numberWithFloat:0.0],
        //                         @"inputContrast", [NSNumber numberWithFloat:1.3],
        //                         @"inputSaturation", [NSNumber numberWithFloat:1.15], nil].outputImage;
        //        filteredImage = [CIFilter filterWithName:@"CIVibrance" keysAndValues:kCIInputImageKey, filteredImage,
        //                         @"inputAmount", [NSNumber numberWithFloat:1.3], nil].outputImage;
        //        filteredImage = [CIFilter filterWithName:@"CISharpenLuminance" keysAndValues:kCIInputImageKey, filteredImage,
        //                         @"inputSharpness", [NSNumber numberWithFloat:0.5], nil].outputImage;
        CGImageRef returnCGImage = [self.filterContext createCGImage:filteredImage fromRect:filteredImage.extent];
        returnImage = [UIImage imageWithCGImage:returnCGImage scale:image.scale orientation:image.imageOrientation];
        filteredImage = nil;
        CGImageRelease(returnCGImage);
    }
    return returnImage;
}

- (UIImage *)coolFilterOnImage:(UIImage *)image
{
    UIImage *returnImage;
    @autoreleasepool {
        CIImage *filteredImage = [[CIImage alloc] initWithImage:image];
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectProcess" keysAndValues:kCIInputImageKey, filteredImage, nil].outputImage;
        //    filteredImage = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, filteredImage, @"inputContrast", [NSNumber numberWithFloat:1.03], @"inputSaturation", [NSNumber numberWithFloat:1.08], nil].outputImage;
        //    filteredImage = [CIFilter filterWithName:@"CITemperatureAndTint" keysAndValues:kCIInputImageKey, filteredImage, @"inputNeutral", [CIVector vectorWithX:6500 Y:500], @"inputTargetNeutral", [CIVector vectorWithX:6700 Y:500], nil].outputImage;
        //    filteredImage = [CIFilter filterWithName:@"CIUnsharpMask" keysAndValues:kCIInputImageKey, filteredImage,
        //                     @"inputRadius", [NSNumber numberWithFloat:1.7],
        //                     @"inputIntensity", [NSNumber numberWithFloat:0.3], nil].outputImage;
        CGImageRef returnCGImage = [self.filterContext createCGImage:filteredImage fromRect:filteredImage.extent];
        returnImage = [UIImage imageWithCGImage:returnCGImage scale:image.scale orientation:image.imageOrientation];
        filteredImage = nil;
        CGImageRelease(returnCGImage);
    }
    return returnImage;
}

- (UIImage *)warmFilterOnImage:(UIImage *)image
{
    UIImage *returnImage;
    @autoreleasepool {
        CIImage *filteredImage = [[CIImage alloc] initWithImage:image];
        filteredImage = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:kCIInputImageKey, filteredImage, nil].outputImage;
        //    filteredImage = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, filteredImage, @"inputContrast", [NSNumber numberWithFloat:1.03], @"inputSaturation", [NSNumber numberWithFloat:1.02], nil].outputImage;
        //    filteredImage = [CIFilter filterWithName:@"CITemperatureAndTint" keysAndValues:kCIInputImageKey, filteredImage, @"inputNeutral", [CIVector vectorWithX:6500 Y:500], @"inputTargetNeutral", [CIVector vectorWithX:6100 Y:500], nil].outputImage;
        //    filteredImage = [CIFilter filterWithName:@"CIUnsharpMask" keysAndValues:kCIInputImageKey, filteredImage,
        //                     @"inputRadius", [NSNumber numberWithFloat:1.7],
        //                     @"inputIntensity", [NSNumber numberWithFloat:0.3], nil].outputImage;
        CGImageRef returnCGImage = [self.filterContext createCGImage:filteredImage fromRect:filteredImage.extent];
        returnImage = [UIImage imageWithCGImage:returnCGImage scale:image.scale orientation:image.imageOrientation];
        filteredImage = nil;
        CGImageRelease(returnCGImage);
    }
    return returnImage;
}

- (UIImage *)textFilterOnImage:(UIImage *)image
{
    UIImage *finalImage;
    @autoreleasepool {
        CIImage *filteredImage = [[CIImage alloc] initWithImage:image];
        filteredImage = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, filteredImage,
                         @"inputBrightness", [NSNumber numberWithFloat:0.0],
                         @"inputContrast", [NSNumber numberWithFloat:1.5],
                         @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
        filteredImage = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, filteredImage,
                         @"inputEV", [NSNumber numberWithFloat:1.3], nil].outputImage;
        CGImageRef returnCGImage = [self.filterContext createCGImage:filteredImage fromRect:filteredImage.extent];
        finalImage = [UIImage imageWithCGImage:returnCGImage scale:image.scale orientation:image.imageOrientation];
        filteredImage = nil;
        CGImageRelease(returnCGImage);
    }
    
    return finalImage;
}


@end
