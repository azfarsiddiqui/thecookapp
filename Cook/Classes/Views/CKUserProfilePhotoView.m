//
//  RoundedProfileView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 2/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKUserProfilePhotoView.h"
#import "CKUser.h"
#import "ViewHelper.h"
#import "ImageHelper.h"
#import "CKPhotoManager.h"

@interface CKUserProfilePhotoView ()

@property (nonatomic, assign) ProfileViewSize profileSize;
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIButton *editButton;

@end

@implementation CKUserProfilePhotoView

#define kMiniSize       CGSizeMake(30.0, 30.0)
#define kSmallSize      CGSizeMake(48.0, 48.0)
#define kMediumSize     CGSizeMake(60.0, 60.0)
#define kLargeSize      CGSizeMake(90.0, 90.0)
#define kBorder         1.0

+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize {
    return [self sizeForProfileSize:profileSize border:NO];
}

+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize border:(BOOL)border {
    CGSize size = CGSizeZero;
    switch (profileSize) {
        case ProfileViewSizeMini:
            size = kMiniSize;
            break;
        case ProfileViewSizeSmall:
            size = kSmallSize;
            break;
        case ProfileViewSizeMedium:
            size = kMediumSize;
            break;
        case ProfileViewSizeLarge:
            size = kLargeSize;
            break;
        case ProfileViewSizeLargeIntro:
            size = (CGSize){ 92.0, 92.0 };
            break;
        default:
            size = kSmallSize;
            break;
    }
    return border ? [self sizeAfterAddingBorderToSize:size] : size;
}

+ (CGSize)sizeAfterAddingBorderToSize:(CGSize)size {
    return CGSizeMake(kBorder + size.width + kBorder, kBorder + size.height + kBorder);
}

- (id)initWithProfileSize:(ProfileViewSize)profileSize {
    return [self initWithUser:nil profileSize:profileSize];
}

- (id)initWithProfileSize:(ProfileViewSize)profileSize border:(BOOL)border {
    return [self initWithUser:nil profileSize:profileSize border:border];
}

- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize {
    return [self initWithUser:user placeholder:nil profileSize:profileSize];
}

- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize border:(BOOL)border {
    return [self initWithUser:user placeholder:nil profileSize:profileSize border:border];
}

- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize {
    return [self initWithUser:user placeholder:placeholderImage profileSize:profileSize border:NO];
}

- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize
            border:(BOOL)border {
    
    if (self = [super initWithFrame:[CKUserProfilePhotoView frameForProfileSize:profileSize border:border]]) {
        self.placeholderImage = placeholderImage;
        self.profileSize = profileSize;
        
        // Background/border colour.
        if (border) {
            UIView *borderView = [[UIView alloc] initWithFrame:self.bounds];
            borderView.backgroundColor = [UIColor whiteColor];
            [self addSubview:borderView];
            self.borderView = borderView;
        }
        
        // Profile image view.
        UIImageView *profileImageView = [[UIImageView alloc] initWithImage:placeholderImage];
        profileImageView.frame = [self profileImageFrameWithBorder:border];
        [self addSubview:profileImageView];
        self.profileImageView = profileImageView;
        
        // Apply masks.
        if (border) {
            [self applyBorderMask];
        }
        [self applyRoundProfileImageMask];
        
        // Add edit.
        [self initEditButton];
        
        // Load photo if user was given.
        if (user) {
            [self loadProfilePhotoForUser:user];
        }
    }
    return self;
}

- (void)loadProfilePhotoForUser:(CKUser *)user {
    self.user = user;
    
    // Load profile photo if available.
    [[CKPhotoManager sharedInstance] imageForUrl:[user profilePhotoUrl] size:[ImageHelper profileSize] name:@"profilePhoto"
                                        progress:^(CGFloat progressRatio) {
                                        } completion:^(UIImage *image, NSString *name) {
                                            [self loadProfileImage:image];
                                        }];
}

- (void)reloadProfilePhoto {
    if (!self.user) {
        return;
    }
    
    [self loadProfilePhotoForUser:self.user];
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated {
    
    // Edit mode only in Large mode.
    if (self.profileSize != ProfileViewSizeLarge) {
        return;
    }
    
    if (editMode) {
        self.editButton.alpha = 0.0;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.editButton.alpha = editMode ? 1.0 : 0.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.editButton.alpha = editMode ? 1.0 : 0.0;
    }
}

- (void)loadProfileImage:(UIImage *)profileImage {
    self.profileImageView.image = [ImageHelper croppedImage:profileImage size:self.profileImageView.bounds.size];
}

#pragma mark - Properties

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_profile_photo.png"]
                                    selectedImage:[UIImage imageNamed:@"cook_customise_profile_photo_onpress.png"]
                                           target:self selector:@selector(editTapped:)];
    }
    return _editButton;
}

#pragma mark - Private methods

+ (CGRect)frameForProfileSize:(ProfileViewSize)profileSize {
    return [self frameForProfileSize:profileSize border:NO];
}

+ (CGRect)frameForProfileSize:(ProfileViewSize)profileSize border:(BOOL)border {
    CGSize size = [self sizeForProfileSize:profileSize border:border];
    return CGRectMake(0.0, 0.0, size.width, size.height);
}

- (CGRect)profileImageFrameWithBorder:(BOOL)border {
    if (border) {
        
        // Add border around actual size.
        CGSize size = [CKUserProfilePhotoView sizeForProfileSize:self.profileSize];
        return CGRectMake(kBorder, kBorder, size.width, size.height);
        
    } else {
        return self.bounds;
    }
}

- (void)applyBorderMask {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.borderView.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(floorf(self.borderView.bounds.size.width / 2.0),
                                                                                floorf(self.borderView.bounds.size.height / 2.0))];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.borderView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.borderView.layer.mask = maskLayer;
}

- (void)applyRoundProfileImageMask {
    [ViewHelper applyRoundedCornersToView:self.profileImageView
                                  corners:UIRectCornerAllCorners
                                     size:(CGSize){
                                         floorf(self.profileImageView.bounds.size.width / 2.0),
                                         floorf(self.profileImageView.bounds.size.height / 2.0)}];
}

- (void)editTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userProfilePhotoViewEditRequested)]) {
        [self.delegate performSelector:@selector(userProfilePhotoViewEditRequested)];
    }
}

- (void)initEditButton {
    self.editButton.frame = (CGRect){
        floorf((self.bounds.size.width - self.editButton.frame.size.width) / 2.0),
        floorf((self.bounds.size.height - self.editButton.frame.size.height) / 2.0),
        self.editButton.frame.size.width,
        self.editButton.frame.size.height
    };
    [self addSubview:self.editButton];
    self.editButton.alpha = 0.0;
}

@end
