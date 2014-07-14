//
//  CKStatView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 3/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKStatView : UIView

- (id)initWithUnitDisplay:(NSString *)unitDisplay pluralDisplay:(NSString *)pluralDisplay;
- (void)updateNumber:(NSUInteger)number;

@end
