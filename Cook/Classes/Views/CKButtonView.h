//
//  CKButtonView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 14/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKButtonView : UIView

- (id)initWithTarget:(id)target action:(SEL)selector;
- (id)initWithTarget:(id)target action:(SEL)selector backgroundImage:(UIImage *)backgroundImage;
- (void)setText:(NSString *)text activity:(BOOL)activity icon:(UIImage *)icon enabled:(BOOL)enabled;
- (void)setText:(NSString *)text activity:(BOOL)activity icon:(UIImage *)icon enabled:(BOOL)enabled selector:(SEL)selector;

@end
