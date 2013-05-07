//
//  CKProgressView.m
//  UIProgressViewDemo
//
//  Created by Jeff Tan-Ang on 7/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKProgressView.h"

@implementation CKProgressView

#define kDefaultWidth   300.0

- (id)init {
    return [self initWithWidth:kDefaultWidth];
}

- (id)initWithWidth:(CGFloat)width {
    if (self = [super initWithProgressViewStyle:UIProgressViewStyleDefault]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        self.trackImage = [[UIImage imageNamed:@"cook_recipe_progressbar_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)];
        self.progressImage = [[UIImage imageNamed:@"cook_recipe_progressbar_inner.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)];
        
        // Fix the width.
        CGRect frame = self.frame;
        frame.size = CGSizeMake(width, self.trackImage.size.height);
        self.frame = frame;
    }
    return self;
}

@end
