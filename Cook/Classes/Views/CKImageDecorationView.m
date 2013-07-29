//
//  CKImageReusableView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 29/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKImageDecorationView.h"

@interface CKImageDecorationView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CKImageDecorationView

+ (NSString *)decorationKind {
    return @"CKImageDecorationView";
}

+ (CGSize)imageSize {
    return [self image].size;
}

+ (UIImage *)image {
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
    }
    return self;
}

#pragma mark - Properties

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[[self class] image]];
        _imageView.frame = self.bounds;
    }
    return _imageView;
}

@end
