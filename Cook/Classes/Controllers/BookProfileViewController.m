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
#import "ParsePhotoStore.h"
#import "UIImage+ProportionalFill.h"
#import <Parse/Parse.h>

@interface BookProfileViewController () <CKPhotoPickerViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *introView;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *editPhotoButton;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) UIImage *uploadedCoverPhoto;

@end

@implementation BookProfileViewController

#define kIntroOffset    CGPointMake(30.0, 30.0)
#define kIntroWidth     400.0
#define kProfileNameGap 20.0

- (id)initWithBook:(CKBook *)book {
    if (self = [super init]) {
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [EventHelper registerEditMode:self selector:@selector(editModeReceived:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [self initImageView];
    [self initIntroView];
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

#pragma mark - Private methods

- (void)initImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

- (void)initIntroView {
    
    UIView *introView = [[UIView alloc] initWithFrame:CGRectMake(kIntroOffset.x,
                                                                 kIntroOffset.y,
                                                                 kIntroWidth,
                                                                 self.view.bounds.size.height - (kIntroOffset.y * 2.0))];
    introView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    introView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:introView];
    self.introView = introView;
    
    // Semi-transparent black overlay.
    UIView *introOverlay = [[UIView alloc] initWithFrame:introView.bounds];
    introOverlay.backgroundColor = [UIColor blackColor];
    introOverlay.alpha = 0.8;
    [introView addSubview:introOverlay];
    
    // Book summary view.
    CKBookSummaryView *bookSummaryView = [[CKBookSummaryView alloc] initWithBook:self.book];
    bookSummaryView.frame = CGRectMake(floorf((introView.bounds.size.width - bookSummaryView.frame.size.width) / 2.0),
                                       floorf((introView.bounds.size.height - bookSummaryView.frame.size.height) / 2.0),
                                       bookSummaryView.frame.size.width,
                                       bookSummaryView.frame.size.height);
    [introView addSubview:bookSummaryView];
    
    // Buttons for the page.
    [self updateButtons];
}

- (void)updateButtons {
    
    // Add edit button if not already.
    CKUser *currentUser = [CKUser currentUser];
    if ([self.book isUserBookAuthor:currentUser] && !self.editButton.superview) {
        [self.introView addSubview:self.editButton];
    }
    
    if (self.editMode) {
        self.editPhotoButton.alpha = 0.0;
        [self.view addSubview:self.editPhotoButton];
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.editPhotoButton.alpha = self.editMode ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished)  {
                         if (!self.editMode) {
                             [self.editPhotoButton removeFromSuperview];
                         }
                     }];
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_edit.png"] target:self selector:@selector(editTapped:)];
        _editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_editButton setFrame:CGRectMake(self.introView.bounds.size.width - _editButton.frame.size.width - 15.0,
                                         15.0,
                                         _editButton.frame.size.width,
                                         _editButton.frame.size.height)];
    }
    return _editButton;
}

- (UIButton *)editPhotoButton {
    if (!_editPhotoButton) {
        _editPhotoButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_edit.png"] target:self selector:@selector(editPhotoTapped:)];
        _editPhotoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        CGFloat availableWidth = self.view.bounds.size.width - (self.introView.frame.origin.x + self.introView.frame.size.width);
        [_editPhotoButton setFrame:CGRectMake(self.introView.frame.origin.x + self.introView.frame.size.width + floorf((availableWidth -_editPhotoButton.frame.size.width) / 2.0),
                                              floorf((self.view.bounds.size.height - _editPhotoButton.frame.size.height) / 2.0),
                                              _editPhotoButton.frame.size.width,
                                              _editPhotoButton.frame.size.height)];
    }
    return _editPhotoButton;
}

- (void)editTapped:(id)sender {
    [EventHelper postEditMode:!self.editMode];
}

- (void)editPhotoTapped:(id)sender {
    [self showPhotoPicker:YES];
}

- (void)editModeReceived:(NSNotification *)notification {
    self.editMode = [EventHelper editModeForNotification:notification];
    BOOL saveMode = [EventHelper editModeSaveForNotification:notification];
    [self updateButtons];
    
    if (!self.editMode && saveMode) {
        [self.book.user saveCoverPhoto:self.uploadedCoverPhoto
                            completion:^{
                            }];
    }
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
    [self.photoStore imageForParseFile:[self.book.user parseCoverPhotoFile]
                                  size:self.imageView.bounds.size
                            completion:^(UIImage *image) {
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

@end
