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
#import "EventHelper.h"

@interface CKUserProfilePhotoView ()

@property (nonatomic, assign) ProfileViewSize profileSize;
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UIImageView *profileOverlay;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) NSURL *profilePhotoUrl;
@property (nonatomic, assign) BOOL editMode;

@end

@implementation CKUserProfilePhotoView

#define kTinySize       CGSizeMake(13.0, 13.0)
#define kMiniSize       CGSizeMake(30.0, 30.0)
#define kSmallSize      CGSizeMake(50.0, 50.0)
#define kMediumSize     CGSizeMake(60.0, 60.0)
#define kLargeSize      CGSizeMake(90.0, 90.0)
#define kBorder         1.0

+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize {
    return [self sizeForProfileSize:profileSize border:NO];
}

+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize border:(BOOL)border {
    CGSize size = CGSizeZero;
    switch (profileSize) {
        case ProfileViewSizeTiny:
            size = kTinySize;
            break;
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

- (void)dealloc {
    [EventHelper unregisterPhotoLoading:self];
}

- (id)initWithProfileSize:(ProfileViewSize)profileSize {
    return [self initWithUser:nil profileSize:profileSize];
}

- (id)initWithProfileSize:(ProfileViewSize)profileSize tappable:(BOOL)tappable {
    
    return [self initWithUser:nil placeholder:[UIImage imageNamed:@"cook_default_profile.png"] profileSize:profileSize
                       border:NO overlay:NO tappable:tappable];
}

- (id)initWithProfileSize:(ProfileViewSize)profileSize border:(BOOL)border {
    return [self initWithUser:nil profileSize:profileSize border:border];
}

- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize {
    return [self initWithUser:user placeholder:[UIImage imageNamed:@"cook_default_profile.png"] profileSize:profileSize];
}

- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize border:(BOOL)border {
    
    return [self initWithUser:user placeholder:[UIImage imageNamed:@"cook_default_profile.png"] profileSize:profileSize
                       border:border];
}

- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize {
    return [self initWithUser:user placeholder:placeholderImage profileSize:profileSize border:NO];
}

- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize
            border:(BOOL)border {
    
    return [self initWithUser:user placeholder:placeholderImage profileSize:profileSize border:border overlay:NO];
}

- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize
            border:(BOOL)border overlay:(BOOL)overlay {
    
    return [self initWithUser:user placeholder:placeholderImage profileSize:profileSize border:border overlay:overlay
                     tappable:YES];
}

- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize
            border:(BOOL)border overlay:(BOOL)overlay tappable:(BOOL)tappable {
    
    if (self = [super initWithFrame:[CKUserProfilePhotoView frameForProfileSize:profileSize border:border]]) {
        
        self.placeholderImage = placeholderImage;
        self.profileSize = profileSize;
        self.highlightOnTap = YES;
        
        // Background/border colour.
        if (border) {
            UIView *borderView = [[UIView alloc] initWithFrame:self.bounds];
            borderView.backgroundColor = [UIColor whiteColor];
            [self addSubview:borderView];
            self.borderView = borderView;
        }
        
        // Profile image view.
        UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:[self profileImageFrameWithBorder:border]];
        profileImageView.backgroundColor = [UIColor blackColor];
        profileImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:profileImageView];
        self.profileImageView = profileImageView;
        
        // Apply masks.
        if (border) {
            [self applyBorderMask];
        }
        [self applyRoundProfileImageMask];
        
        // Apply overlay.
        if (overlay) {
            UIImageView *profileOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_library_profile_overlay.png"]];
            profileOverlay.frame = (CGRect){
                floorf((self.bounds.size.width - profileOverlay.frame.size.width) / 2.0),
                floorf((self.bounds.size.height - profileOverlay.frame.size.height) / 2.0) + 4.0,
                profileOverlay.frame.size.width,
                profileOverlay.frame.size.height
            };
            [self addSubview:profileOverlay];
            self.profileOverlay = profileOverlay;
        }
        
        // Register photo loading events.
        [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
        
        // Load photo if user was given.
        if (user) {
            [self loadProfilePhotoForUser:user];
        } else {
            self.profileImageView.image = placeholderImage;
        }
        
        // Add tappable related controls.
        self.userInteractionEnabled = tappable;
        if (tappable) {
            
            // Add edit.
            [self initEditButton];
            
            // Register taps.
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapped:)];
            [self addGestureRecognizer:tapGesture];
        }
        
    }
    return self;
}

- (void)loadProfilePhotoForUser:(CKUser *)user {
    self.user = user;
    [self loadProfileUrl:[user profilePhotoUrl]];
}

- (void)reloadProfilePhoto {
    if (!self.user) {
        return;
    }
    
    [self loadProfilePhotoForUser:self.user];
}

- (void)clearProfilePhoto {
    self.profileImageView.image = nil;
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated {
    self.editMode = editMode;
    
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
                             self.profileOverlay.alpha = editMode ? 0.0 : 1.0;
                             self.editButton.alpha = editMode ? 1.0 : 0.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.profileOverlay.alpha = editMode ? 0.0 : 1.0;
        self.editButton.alpha = editMode ? 1.0 : 0.0;
    }
}

- (void)loadProfileUrl:(NSURL *)profileUrl {
    self.profilePhotoUrl = profileUrl;
    if (profileUrl) {
        // If blank profile, just load from app bundle
        if ([[profileUrl absoluteString] isEqualToString:[[CKUser defaultBlankProfileUrl] absoluteString]]) {
            self.profileImageView.image = [UIImage imageNamed:@"cook_default_profile.png"];
            return;
        }
        self.profileImageView.image = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[CKPhotoManager sharedInstance] thumbImageForURL:profileUrl size:self.profileImageView.bounds.size completion:^(UIImage *image, NSString *name) {
                if ([name isEqualToString:[profileUrl absoluteString]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Cross-fade the image.
                        [UIView transitionWithView:self.profileImageView
                                          duration:0.2
                                           options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                            self.profileImageView.image = image;
                                        } completion:nil];
                    });
                }
            }];
        });
    }
}

- (void)loadProfileImage:(UIImage *)profileImage {
    self.profileImageView.image = [ImageHelper croppedImage:profileImage size:self.profileImageView.bounds.size];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.delegate || !self.highlightOnTap) {
        return;
    }
    self.profileImageView.alpha = 0.5;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.delegate || !self.highlightOnTap) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        self.profileImageView.alpha = 0.5;
    } else {
        self.profileImageView.alpha = 1.0;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.delegate || !self.highlightOnTap) {
        return;
    }
    self.profileImageView.alpha = 1.0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.profileImageView.alpha = 1.0;
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
        floorf((self.bounds.size.height - self.editButton.frame.size.height) / 2.0) + 1.0,
        self.editButton.frame.size.width,
        self.editButton.frame.size.height
    };
    [self addSubview:self.editButton];
    self.editButton.alpha = 0.0;
}

- (void)photoLoadingReceived:(NSNotification *)notification {
    NSString *name = [EventHelper nameForPhotoLoading:notification];
    if ([[self.profilePhotoUrl absoluteString] isEqualToString:name]) {
        if ([EventHelper hasImageForPhotoLoading:notification]) {
            UIImage *image = [EventHelper imageForPhotoLoading:notification];
            [self loadProfileImage:image];
        }
    }
}

- (void)profileTapped:(UITapGestureRecognizer *)tapGesture {
    if (self.editMode) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(userProfilePhotoViewTappedForUser:)]) {
        [self.delegate userProfilePhotoViewTappedForUser:self.user];
    }
}

@end
