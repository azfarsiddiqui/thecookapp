//
//  CKPrivacyView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 10/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKPrivacyViewDelegate

- (void)privacyViewSelectedPrivateMode:(BOOL)privateMode;

@end

@interface CKPrivacyView : UIView

- (id)initWithPrivateMode:(BOOL)privateMode delegate:(id<CKPrivacyViewDelegate>)delegate;

@end
