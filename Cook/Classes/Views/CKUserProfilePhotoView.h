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
	ProfileViewSizeMini,
	ProfileViewSizeSmall,
	ProfileViewSizeMedium,
	ProfileViewSizeLarge,
	ProfileViewSizeLargeIntro,
} ProfileViewSize;

@protocol CKUserProfilePhotoViewDelegate <NSObject>

- (void)userProfilePhotoViewEditRequested;

@end

@interface CKUserProfilePhotoView : UIView

@property (nonatomic, weak) id<CKUserProfilePhotoViewDelegate> delegate;

+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize;
+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize border:(BOOL)border;

- (id)initWithProfileSize:(ProfileViewSize)profileSize;
- (id)initWithProfileSize:(ProfileViewSize)profileSize border:(BOOL)border;
- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize;
- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize border:(BOOL)border;
- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize;
- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize
            border:(BOOL)border;
- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize
            border:(BOOL)border overlay:(BOOL)overlay;
- (void)reloadProfilePhoto;
- (void)loadProfilePhotoForUser:(CKUser *)user;
- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated;
- (void)loadProfileImage:(UIImage *)profileImage;

@end
