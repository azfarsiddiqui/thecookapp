//
//  CKLoginView.h
//  CKFacebookLoginButton
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKLoginViewDelegate

- (void)loginViewTapped;

@end

@interface CKLoginView : UIView

- (id)initWithDelegate:(id<CKLoginViewDelegate>)delegate;
- (void)loginStarted;
- (void)loginDone;
- (void)loginReset;

@end
