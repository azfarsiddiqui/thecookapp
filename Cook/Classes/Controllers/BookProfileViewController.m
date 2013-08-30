//
//  BookProfileViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookProfileViewController.h"
#import "CKBook.h"
#import "CKUser.h"
#import "Theme.h"
#import "CKUserProfilePhotoView.h"
#import "CKBookSummaryView.h"
#import "ViewHelper.h"
#import "EventHelper.h"
#import "CKPhotoPickerViewController.h"
#import "AppHelper.h"
#import "UIImage+ProportionalFill.h"
#import "CKEditingViewHelper.h"
#import "CKPhotoManager.h"
#import <Parse/Parse.h>

@interface BookProfileViewController () <CKPhotoPickerViewControllerDelegate, CKEditingTextBoxViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) UIImage *uploadedCoverPhoto;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;

@end

@implementation BookProfileViewController

#define kButtonInsets       UIEdgeInsetsMake(22.0, 10.0, 15.0, 20.0)
#define kEditButtonInsets   UIEdgeInsetsMake(20.0, 5.0, 0.0, 5.0)

- (id)initWithBook:(CKBook *)book {
    if (self = [super init]) {
        self.book = book;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initImageView];
    
    if ([self canEditBook]) {
        [self.view addSubview:self.editButton];
    }
    
    [self loadData];
}

#pragma mark - CKPhotoPickerViewControllerDelegate methods

- (void)photoPickerViewControllerSelectedImage:(UIImage *)image {
    [self showPhotoPicker:NO];
    
    // Present the image.
    UIImage *croppedImage = [image imageCroppedToFitSize:self.imageView.bounds.size];
    self.imageView.image = croppedImage;
    
    // Save photo to be uploaded.
    self.uploadedCoverPhoto = image;
}

- (void)photoPickerViewControllerCloseRequested {
    [self showPhotoPicker:NO];
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
}

#pragma mark - Properties

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_edit_light.png"]
                                           target:self
                                         selector:@selector(editTapped:)];
        _editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _editButton.frame = CGRectMake(self.view.frame.size.width - kButtonInsets.right - _editButton.frame.size.width,
                                       kButtonInsets.top,
                                       _editButton.frame.size.width,
                                       _editButton.frame.size.height);
    }
    return _editButton;
}

#pragma mark - Private methods

- (void)initImageView {
    
    // Image container view to clip the motion effects of the imageView.
    UIView *imageContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    imageContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageContainerView.clipsToBounds = YES;
    [self.view addSubview:imageContainerView];
    
    UIOffset motionOffset = [ViewHelper standardMotionOffset];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = (CGRect) {
        imageContainerView.bounds.origin.x - motionOffset.horizontal,
        imageContainerView.bounds.origin.y - motionOffset.vertical,
        imageContainerView.bounds.size.width + (motionOffset.horizontal * 2.0),
        imageContainerView.bounds.size.height + (motionOffset.vertical * 2.0)
    };
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [imageContainerView addSubview:imageView];
    self.imageView = imageView;
    
    // Motion effects.
    [ViewHelper applyDraggyMotionEffectsToView:self.imageView];
}

- (void)showPhotoPicker:(BOOL)show {
    if (show) {
        // Present photo picker fullscreen.
        UIView *rootView = [[AppHelper sharedInstance] rootView];
        CKPhotoPickerViewController *photoPickerViewController = [[CKPhotoPickerViewController alloc] initWithDelegate:self];
        self.photoPickerViewController = photoPickerViewController;
        self.photoPickerViewController.view.alpha = 0.0;
        [rootView addSubview:self.photoPickerViewController.view];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.photoPickerViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!show) {
                             [self cleanupPhotoPicker];
                         }
                     }];
}

- (void)cleanupPhotoPicker {
    [self.photoPickerViewController.view removeFromSuperview];
    self.photoPickerViewController = nil;
}

- (void)loadData {
    if ([self.book.user hasCoverPhoto]) {
        
        [[CKPhotoManager sharedInstance] imageForParseFile:[self.book.user parseCoverPhotoFile]
                                                      size:self.imageView.bounds.size name:@"profileCover"
                                                  progress:^(CGFloat progressRatio) {
                                                  } completion:^(UIImage *image, NSString *name) {
                                                      self.imageView.alpha = 0.0;
                                                      self.imageView.image = image;
                                                      
                                                      // Fade it in.
                                                      [UIView animateWithDuration:0.6
                                                                            delay:0.0
                                                                          options:UIViewAnimationOptionCurveEaseIn
                                                                       animations:^{
                                                                           self.imageView.alpha = 1.0;
                                                                       }
                                                                       completion:^(BOOL finished) {
                                                                       }];
                                                  }];
    }
}

- (BOOL)canEditBook {
    return [self.book isOwner];
}

- (void)editTapped:(id)sender {
    [self enableEditMode:YES completion:^{
        [self.bookPageDelegate bookPageViewController:self editModeRequested:YES];
    }];
}

- (void)enableEditMode:(BOOL)editMode completion:(void (^)())completion {
    self.editMode = editMode;
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.editButton.alpha = editMode ? 0.0 : 1.0;
                     }
                     completion:^(BOOL finished)  {
                         if (completion != nil) {
                             completion();
                         }
                     }];
}

@end
