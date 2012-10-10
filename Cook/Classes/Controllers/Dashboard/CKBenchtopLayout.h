//
//  CKBenchtopLayout.h
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBenchtopDelegate.h"

@interface CKBenchtopLayout : UICollectionViewLayout

@property (nonatomic, assign) id<CKBenchtopDelegate> benchtopDelegate;

- (id)initWithBenchtopDelegate:(id<CKBenchtopDelegate>)benchtopDelegate;
- (void)layoutCompleted;

@end
