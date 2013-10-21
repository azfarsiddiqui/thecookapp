//
//  CKInfoView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKInfoView.h"

@interface CKInfoView ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation CKInfoView

#define kContentSize    (CGSize){ 834.0, 613.0 }

- (id)init {
    if (self = [super initWithFrame:(CGRect){ 0.0, 0.0, kContentSize.width, kContentSize.height }]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)loadData {
    // Subclasses to implement.
}

#pragma mark - Properties

- (UIView *)contentView {
    UIImage *contentImage = [[UIImage imageNamed:@"cook_dash_library_selected_bg.png"]
                             resizableImageWithCapInsets:(UIEdgeInsets){ 36.0, 44.0, 52.0, 44.0 }];
    if (!_contentView) {
        _contentView = [[UIImageView alloc] initWithFrame:self.bounds];
        ((UIImageView *)_contentView).image = contentImage;
    }
    return _contentView;
}

@end
