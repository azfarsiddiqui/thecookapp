//
//  BookCategoryImageView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCategoryImageView.h"

@interface BookCategoryImageView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *whiteOverlayView;

@end

@implementation BookCategoryImageView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        
        self.whiteOverlayView = [[UIView alloc] initWithFrame:self.bounds];
        self.whiteOverlayView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.8];
        self.whiteOverlayView.hidden = YES;
        [self addSubview:self.whiteOverlayView];
    }
    return self;
}

- (void)applyAlpha:(CGFloat)alpha {
    if (alpha > 0) {
        self.whiteOverlayView.hidden = NO;
        self.whiteOverlayView.alpha = alpha;
    } else {
        self.whiteOverlayView.hidden = YES;
    }
}

- (void)configureImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
