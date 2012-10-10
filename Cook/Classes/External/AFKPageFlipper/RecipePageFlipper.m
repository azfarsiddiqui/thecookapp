//
//  RecipePageFlipper.m
//  recipe
//
//  Created by Jonny Sagorin on 8/9/12.
//  Copyright (c) 2012 Apps Perhaps Pty Ltd. All rights reserved.
//

#import "RecipePageFlipper.h"

@implementation RecipePageFlipper

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self removeGestureRecognizer:self.tapRecognizer];
        self.tapRecognizer = nil;
    }
    
    return self;
}

@end
