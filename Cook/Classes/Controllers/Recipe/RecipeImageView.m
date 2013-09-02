//
//  RecipeImageView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 29/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeImageView.h"

@implementation RecipeImageView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    
    // Ignore taps if no images.
    if (self.placeholder) {
        return;
    }
    
    if (!self.enableDoubleTap) {
        return;
    }
    
    if (touch.tapCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    
    // Ignore taps if no images.
    if (self.placeholder) {
        return;
    }
    
    if (touch.tapCount == 1) {
        
        if (self.enableDoubleTap) {
            [self performSelector:@selector(singleTapped) withObject:nil afterDelay:0.2];
        } else {
            [self singleTapped];
        }
        
    } else if (touch.tapCount == 2) {
        [self.delegate recipeImageViewDoubleTappedAtPoint:[touch locationInView:self]];
    }
}

#pragma mark - Private methods

- (void)singleTapped {
    if ([self.delegate respondsToSelector:@selector(recipeImageViewTapped)]) {
        [self.delegate recipeImageViewTapped];
    }
}

@end
