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
#import "CKBookCover.h"

@interface BookProfileViewController () <CKPhotoPickerViewControllerDelegate, CKEditingTextBoxViewDelegate,
    CKBookSummaryViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *photoButtonView;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) CKPhotoPickerViewController *photoPickerViewController;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;

// Edited content.
@property (nonatomic, strong) UIImage *updatedBookCoverPhoto;
@property (nonatomic, strong) UIImage *updatedUserPhoto;
@property (nonatomic, strong) NSString *updatedBookStory;

@end

@implementation BookProfileViewController

#define kButtonInsets       UIEdgeInsetsMake(22.0, 10.0, 15.0, 20.0)
#define kEditButtonInsets   UIEdgeInsetsMake(20.0, 5.0, 0.0, 5.0)
#define kAvailableWidth     624.0

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
        [self.view addSubview:self.photoButtonView];
        
        // Wrap an editBox box.
        [self.editingHelper wrapEditingView:self.photoButtonView contentInsets:(UIEdgeInsets){
            32.0, 32.0, 20.0, 41.0
        } delegate:self white:YES editMode:NO];
        UIView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoButtonView];
        self.photoButtonView.alpha = 0.0;
        photoBoxView.alpha = 0.0;
        
        [self.view addSubview:self.editButton];
    }
    
    [self loadData];
}

#pragma mark - BookPageViewController methods

- (BOOL)pageSaveRequired {
    return (self.updatedBookCoverPhoto != nil || ([self.summaryView contentSaveRequired]));
}

- (void)pagePerformSave:(BOOL)save {
    if (save) {
        
        // Upload profile photo if given.
        if (self.updatedBookCoverPhoto) {
            [self.book saveWithImage:self.updatedBookCoverPhoto
                          completion:^{
                              DLog(@"Saved book.");
                          } failure:^(NSError *error) {
                              // Ignore returns.
                          }];
        }
        
        if ([self.summaryView contentSaveRequired]) {
            [self.summaryView contentPerformSave:YES];
        }
        
    } else {
        
        // Reload the data.
        [self loadData];
        
        // Restore the data in summary view.
        [self.summaryView contentPerformSave:NO];
    }
}

#pragma mark - CKPhotoPickerViewControllerDelegate methods

- (void)photoPickerViewControllerSelectedImage:(UIImage *)image {
    [self showPhotoPicker:NO];
    
    // Present the image.
    UIImage *croppedImage = [image imageCroppedToFitSize:self.imageView.bounds.size];
    self.imageView.image = croppedImage;
    
    // Save photo to be uploaded.
    self.updatedBookCoverPhoto = image;
}

- (void)photoPickerViewControllerCloseRequested {
    [self showPhotoPicker:NO];
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    [self showPhotoPicker:YES];
}

#pragma mark - CKBookSummaryViewDelegate methods

- (void)bookSummaryViewEditing:(BOOL)editing {
    [self.bookPageDelegate bookPageViewController:self editing:editing];
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

- (UIView *)photoButtonView {
    if (!_photoButtonView) {
        
        UIImageView *cameraImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_customise_icon_photo.png"]];
        CGRect cameraImageFrame = cameraImageView.frame;
        
        UILabel *photoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        photoLabel.font = [Theme editPhotoFont];
        photoLabel.textColor = [Theme editPhotoColour];
        photoLabel.textAlignment = NSTextAlignmentCenter;
        photoLabel.backgroundColor = [UIColor clearColor];
        photoLabel.text = @"PHOTO";
        [photoLabel sizeToFit];
        CGRect photoLabelFrame = photoLabel.frame;
        photoLabelFrame = (CGRect){
            cameraImageView.frame.origin.x + cameraImageView.frame.size.width + 6.0,
            floorf((cameraImageView.frame.size.height - photoLabel.frame.size.height) / 2.0) + 2.0,
            photoLabel.frame.size.width,
            photoLabel.frame.size.height
        };
        photoLabel.frame = photoLabelFrame;
        
        UIEdgeInsets contentInsets = (UIEdgeInsets){
            0.0, 0.0, 0.0, 0.0
        };
        CGRect frame = CGRectUnion(cameraImageView.frame, photoLabel.frame);
        _photoButtonView = [[UIView alloc] initWithFrame:frame];
        _photoButtonView.backgroundColor = [UIColor clearColor];
        [_photoButtonView addSubview:cameraImageView];
        _photoButtonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
        [_photoButtonView addSubview:photoLabel];
        cameraImageFrame.origin.x += contentInsets.left;
        cameraImageFrame.origin.y += contentInsets.top;
        photoLabelFrame.origin.x += contentInsets.left;
        photoLabelFrame.origin.y += contentInsets.top;
        frame.size.height += contentInsets.top + contentInsets.bottom;
        frame.size.width += contentInsets.left + contentInsets.right;
        frame.origin.x = (self.view.bounds.size.width - kAvailableWidth) + floorf((kAvailableWidth - frame.size.width) / 2.0);
        frame.origin.y = floorf((self.view.bounds.size.height - frame.size.height) / 2.0);
        cameraImageView.frame = cameraImageFrame;
        photoLabel.frame = photoLabelFrame;
        _photoButtonView.frame = frame;
        
        // Disable interaction for CKEditing to take over.
        _photoButtonView.userInteractionEnabled = NO;
    }
    return _photoButtonView;
}

- (CKBookSummaryView *)summaryView {
    if (!_summaryView) {
        _summaryView = [[CKBookSummaryView alloc] initWithBook:self.book];
        _summaryView.delegate = self;
    }
    return _summaryView;
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
    if ([self.book hasCoverPhoto]) {
        [[CKPhotoManager sharedInstance] imageForBook:self.book size:self.imageView.bounds.size name:@"profileCover"
                                             progress:^(CGFloat progressRatio, NSString *name) {
                                             } thumbCompletion:^(UIImage *thumbImage, NSString *name) {
                                                 self.imageView.image = thumbImage;
                                             } completion:^(UIImage *image, NSString *name) {
                                                 self.imageView.image = image;
                                             }];
    } else {
        UIImage *bookCoverImage = [CKBookCover recipeEditBackgroundImageForCover:self.book.cover];
        self.imageView.image = bookCoverImage;
    }
}

- (BOOL)canEditBook {
    return [self.book isOwner];
}

- (void)editTapped:(id)sender {
    [self.bookPageDelegate bookPageViewController:self editModeRequested:YES];
}

- (void)enableEditMode:(BOOL)editMode completion:(void (^)())completion {
    [self enableEditMode:editMode animated:YES completion:completion];
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated completion:(void (^)())completion {
    self.editMode = editMode;
    
    // Prep photo edit button to be transitioned in.
    if (self.editMode) {
        UIView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoButtonView];
        self.photoButtonView.alpha = 0.0;
        photoBoxView.alpha = 0.0;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             // Photo button.
                             self.editButton.alpha = editMode ? 0.0 : 1.0;
                             self.photoButtonView.alpha = self.editMode ? 1.0 : 0.0;
                             CKEditingTextBoxView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoButtonView];
                             photoBoxView.alpha = self.photoButtonView.alpha;
                             
                         }
                         completion:^(BOOL finished)  {
                             
                             // Summary view.
                             [self.summaryView enableEditMode:editMode animated:YES];
                             
                             if (completion != nil) {
                                 completion();
                             }
                         }];
    } else {
        
        // Photo button.
        self.editButton.alpha = editMode ? 0.0 : 1.0;
        self.photoButtonView.alpha = self.editMode ? 1.0 : 0.0;
        CKEditingTextBoxView *photoBoxView = [self.editingHelper textBoxViewForEditingView:self.photoButtonView];
        photoBoxView.alpha = self.photoButtonView.alpha;
        
        // Summary view.
        [self.summaryView enableEditMode:editMode animated:NO];
    }
}

@end
