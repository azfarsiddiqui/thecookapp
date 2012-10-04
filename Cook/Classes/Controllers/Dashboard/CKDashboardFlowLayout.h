//
//  CKDashboardFlowLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKDashboardFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) BOOL nextDashboard;
@property (nonatomic, assign) BOOL expanded;

+ (CGSize)itemSize;

- (id)initWithNextDashboard;
- (CGPoint)itemOffset;
- (CGFloat)minScale;
- (void)applyScalingTransformToLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes;
- (CGSize)fullContentSize;

@end
