//
//  CKBookCoverView.h
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBookCoverView : UIView

- (void)setCover:(NSString *)cover illustration:(NSString *)illustration;
- (void)setTitle:(NSString *)title author:(NSString *)author caption:(NSString *)caption;

@end
