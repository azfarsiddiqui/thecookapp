//
//  CookPageFlipper.m
//  recipe
//
//  Created by Jonny Sagorin on 8/9/12.
//  Copyright (c) 2012 Cook Pty Ltd. All rights reserved.
//

#import "CookPageFlipper.h"

@implementation CookPageFlipper

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self removeGestureRecognizer:self.tapRecognizer];
        self.tapRecognizer = nil;
    }
    
    return self;
}

@end
