//
//  PagingBenchtopBackgroundView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagingBenchtopBackgroundView : UICollectionReusableView

@property (nonatomic, strong) UIColor *leftEdgeColour;
@property (nonatomic, strong) UIColor *rightEdgeColour;

- (id)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth;
- (void)addColour:(UIColor *)colour;
- (void)blend;
- (void)blendWithCompletion:(void (^)())completion;

@end
