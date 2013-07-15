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

@end

@implementation BookCategoryImageView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)configureImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
