//
//  RoundedProfileView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 2/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKUser;

typedef enum {
    ProfileViewSizeTiny,
	ProfileViewSizeMini,
	ProfileViewSizeSmall,
	ProfileViewSizeMedium,
	ProfileViewSizeLarge,
	ProfileViewSizeLargeIntro,
} ProfileViewSize;

@protocol CKUserProfilePhotoViewDelegate <NSObject>

@optional
- (NSString *)userProfileURL;
- (void)userProfilePhotoViewEditRequested;
- (void)userProfilePhotoViewTappedForUser:(CKUser *)user;

@end

@interface CKUserProfilePhotoView : UIView

@property (nonatomic, weak) id<CKUserProfilePhotoViewDelegate> delegate;
@property (nonatomic, assign) BOOL highlightOnTap;

+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize;
+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize border:(BOOL)border;

- (id)initWithProfileSize:(ProfileViewSize)profileSize;
- (id)initWithProfileSize:(ProfileViewSize)profileSize tappable:(BOOL)tappable;
- (id)initWithProfileSize:(ProfileViewSize)profileSize border:(BOOL)border;
- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize;
- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize border:(BOOL)border;
- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize;
- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize
            border:(BOOL)border;
- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize
            border:(BOOL)border overlay:(BOOL)overlay;
- (void)reloadProfilePhoto;
- (void)clearProfilePhoto;
- (void)loadProfilePhotoForUser:(CKUser *)user;
- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated;
- (void)loadProfileUrl:(NSURL *)profileUrl;
- (void)loadProfileImage:(UIImage *)profileImage;

@end
