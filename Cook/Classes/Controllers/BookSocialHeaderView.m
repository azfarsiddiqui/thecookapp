//
//  BookCommentsHeaderView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookSocialHeaderView.h"
#import "Theme.h"

@interface BookSocialHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BookSocialHeaderView

+ (NSString *)bookSocialHeaderKind {
    return @"BookSocialHeaderKind";
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)configureTitle:(NSString *)title {
    self.titleLabel.text = [title uppercaseString];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = (CGRect){
        floorf((self.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
        floorf((self.bounds.size.height - self.titleLabel.frame.size.height) / 2.0),
        self.titleLabel.frame.size.width,
        self.titleLabel.frame.size.height
    };
}

#pragma mark - Properties

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [Theme bookSocialTitleFont];
        _titleLabel.textColor = [Theme bookSocialTitleColour];
    }
    return _titleLabel;
}

@end
