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
	ProfileViewSizeSmall,
	ProfileViewSizeMedium,
	ProfileViewSizeLarge,
} ProfileViewSize;

@interface CKUserProfilePhotoView : UIImageView

+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize;

- (id)initWithProfileSize:(ProfileViewSize)profileSize;
- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize;
- (void)loadProfilePhotoForUser:(CKUser *)user;

@end
