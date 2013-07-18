//
//  BookSocialLikeView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookSupplementaryContainerView.h"

@interface BookSupplementaryContainerView ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation BookSupplementaryContainerView

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
    contentView.frame = (CGRect){
        floorf((self.bounds.size.width - contentView.frame.size.width) / 2.0),
        floorf((self.bounds.size.height - contentView.frame.size.height) / 2.0),
        contentView.frame.size.width,
        contentView.frame.size.height
    };
    [self addSubview:contentView];
    self.contentView = contentView;
}

@end
