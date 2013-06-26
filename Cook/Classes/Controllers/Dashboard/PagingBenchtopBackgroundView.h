//
//  PagingBenchtopBackgroundView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagingBenchtopBackgroundView : UICollectionReusableView

- (void)addColour:(UIColor *)colour offset:(CGFloat)offset;
- (void)blend;

@end
