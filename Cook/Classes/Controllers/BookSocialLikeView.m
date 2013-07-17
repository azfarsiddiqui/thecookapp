//
//  BookSocialLikeView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookSocialLikeView.h"

@interface BookSocialLikeView ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation BookSocialLikeView

+ (NSString *)bookSocialLikeKind {
    return @"BookSocialLikeKind";
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)configureContentView:(UIView *)contentView {
    [self.contentView removeFromSuperview];
    contentView.center = self.center;
    [self addSubview:contentView];
    self.contentView = contentView;
}

@end
