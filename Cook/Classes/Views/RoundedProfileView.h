//
//  RoundedProfileView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 2/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

typedef enum {
	RoundedProfileViewSizeSmall,
	RoundedProfileViewSizeMedium,
	RoundedProfileViewSizeLarge,
} RoundedProfileViewSize;

@interface RoundedProfileView : FBProfilePictureView

+ (CGSize)sizeForProfileSize:(RoundedProfileViewSize)profileSize;

- (id)initWithProfileSize:(RoundedProfileViewSize)profileSize;

@end
