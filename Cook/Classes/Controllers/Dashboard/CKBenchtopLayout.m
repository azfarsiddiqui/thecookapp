//
//  CKBenchtopLayout.m
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBenchtopLayout.h"

@interface CKBenchtopLayout ()

@end

@implementation CKBenchtopLayout

- (id)initWithBenchtopDelegate:(id<CKBenchtopDelegate>)benchtopDelegate {
    if ([super init]) {
        self.benchtopDelegate = benchtopDelegate;
    }
    return self;
}

- (void)layoutCompleted {
    // Subclasses to implement what to do after layout has completed after animation.
}

@end
