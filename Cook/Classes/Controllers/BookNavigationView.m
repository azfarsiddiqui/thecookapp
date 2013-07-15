//
//  BookNavigationView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationView.h"

@interface BookNavigationView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation BookNavigationView

+ (CGFloat)navigationHeight {
    return 74.0;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_titlebar.png"]];
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundImageView.frame = self.bounds;
        [self addSubview:self.backgroundImageView];
    }
    return self;
}

@end
