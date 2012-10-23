//
//  CKBenchtopLayout.h
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BenchtopDelegate.h"

@interface BenchtopLayout : UICollectionViewLayout

@property (nonatomic, assign) id<BenchtopDelegate> benchtopDelegate;

- (id)initWithBenchtopDelegate:(id<BenchtopDelegate>)benchtopDelegate;
- (void)layoutCompleted;

@end
