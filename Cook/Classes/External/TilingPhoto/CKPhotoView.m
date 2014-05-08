//
//  CKPhotoView.m
//  Cook
//
//  Created by Gerald on 14/02/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPhotoView.h"
#import "ImageHelper.h"
#import "UIColor+Expanded.h"
#import "CKPhotoManager.h"

@interface CKPhotoView ()

@end

@implementation CKPhotoView

- (void)dealloc {
    self.imageView.image = nil;
    [self.imageView removeFromSuperview];
    self.blurredImageView.image = nil;
    [self.blurredImageView removeFromSuperview];
    self.thumbnailView.image = nil;
    [self.thumbnailView removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.thumbnailView];
        [self addSubview:self.imageView];
        [self addSubview:self.blurredImageView];
    }
    return self;
}

- (CGRect)imageViewFrame {
    return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Properties

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[UIImageView alloc] initWithFrame:[self imageViewFrame]];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _thumbnailView.image = [ImageHelper imageFromDiskNamed:@"cook_edit_bg_blank" type:@"png"];
    }
    return _thumbnailView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:[self imageViewFrame]];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageView;
}

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        _blurredImageView = [[UIImageView alloc] initWithFrame:[self imageViewFrame]];
        _blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
        _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _blurredImageView.alpha = 0.0;
    }
    return _blurredImageView;
}

#pragma mark - Public custom Image setters

- (void)setThumbnailImage:(UIImage *)thumbImage {
    self.thumbnailView.image = thumbImage;
}

- (void)setFullImage:(UIImage *)fullImage {
    [self setFullImage:fullImage completion:nil];
}

- (void)setFullImage:(UIImage *)fullImage completion:(void (^)())completion {
    self.imageView.image = fullImage;
//    self.thumbnailView.image = nil;
}

- (void)setBlurredImage:(UIImage *)thumbImage {
    //Generate blurred image now as well
    if (thumbImage) {
        self.blurredImageView.image = thumbImage;
    }
}

#pragma mark - Clean up methods

- (void)cleanImageViews {
//    self.thumbnailView.image = nil;
    self.blurredImageView.image = nil;
    self.imageView.image = nil;
}

- (void)deactivateImage {
    self.imageView.image = nil;
//    self.blurredImageView.image = nil;
}

@end