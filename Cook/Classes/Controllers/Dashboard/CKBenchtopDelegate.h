//
//  CKBenchtop.h
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 9/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKBenchtopDelegate <NSObject>

- (BOOL)onMyBenchtop;
- (CGSize)benchtopItemSize;
- (CGFloat)benchtopSideGap;
- (CGFloat)benchtopBookMinScaleFactor;
- (CGFloat)benchtopItemOffset;

@end
