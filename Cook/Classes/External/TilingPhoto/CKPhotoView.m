//
//  CKPhotoView.m
//  Cook
//
//  Created by Gerald on 14/02/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPhotoView.h"
#import "ImageHelper.h"

@interface CKPhotoView ()

@end

@implementation CKPhotoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isImageLoaded = NO;
    }
    return self;
}

- (void)dealloc {
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    [self.blurredImageView removeFromSuperview];
    self.blurredImageView = nil;
    self.thumbnailView = nil;
    [self.thumbnailView removeFromSuperview];
}

- (void)cleanImageViews {
    self.thumbnailView.image = nil;
    self.blurredImageView.image = nil;
    self.imageView.imageView = nil;
    self.isImageLoaded = NO;
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
        [self insertSubview:_thumbnailView belowSubview:self.imageView];
    }
    return _thumbnailView;
}

- (ImageScrollView *)imageView {
    if (!_imageView) {
        _imageView = [[ImageScrollView alloc] initWithFrame:[self imageViewFrame]];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _imageView.aspectFill = YES;
        [self addSubview:_imageView];
//        _imageView.alpha = 0.0;
    }
    return _imageView;
}

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        _blurredImageView = [[UIImageView alloc] initWithFrame:[self imageViewFrame]];
        _blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
        _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self insertSubview:_blurredImageView aboveSubview:self.imageView];
        _blurredImageView.alpha = 0.0;
    }
    return _blurredImageView;
}

#pragma mark - Public custom Image setters

- (void)setThumbnailImage:(UIImage *)thumbImage {
    self.thumbnailView.image = thumbImage;
    self.isImageLoaded = YES;
}

- (void)setFullImage:(UIImage *)fullImage {
    [self setFullImage:fullImage completion:nil];
}

- (void)setFullImage:(UIImage *)fullImage completion:(void (^)())completion {
    if (!self.thumbnailView.image || !self.isImageLoaded) {
        self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnailView.image = [ImageHelper thumbImageForImage:fullImage];
    }
    
    [ImageHelper generateTilesFromImage:fullImage size:self.imageView.frame.size completion:^(TiledImageBuilder *tileImage) {
        [self.imageView displayObject:tileImage];
        self.isImageLoaded = YES;
        if (completion) {
            completion();
        }
    }];
}

- (void)setBlurredImage:(UIImage *)fullImage tintColor:(UIColor *)color {
    //Generate blurred image now as well
    [ImageHelper blurredImage:fullImage tintColour:color radius:10.0 completion:^(UIImage *blurredImage) {
        self.blurredImageView.image = blurredImage;
    }];
}

@end