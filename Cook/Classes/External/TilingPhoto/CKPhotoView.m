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
        // Initialization code
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
    self.imageView.imageView = nil;
    self.blurredImageView.image = nil;
}

#pragma mark - Properties

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[UIImageView alloc] initWithFrame:self.frame];
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _thumbnailView.image = [ImageHelper imageFromDiskNamed:@"cook_edit_bg_blank" type:@"png"];
        [self insertSubview:_thumbnailView atIndex:0];
    }
    return _thumbnailView;
}

- (ImageScrollView *)imageView {
    if (!_imageView) {
        _imageView = [[ImageScrollView alloc] initWithFrame:self.frame];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _imageView.aspectFill = YES;
        [self insertSubview:_imageView atIndex:1];
//        _imageView.alpha = 0.0;
    }
    return _imageView;
}

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        _blurredImageView = [[UIImageView alloc] initWithFrame:self.frame];
        _blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
        _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self insertSubview:_blurredImageView atIndex:2];
//        _blurredImageView.alpha = 0.0;
    }
    return _blurredImageView;
}

#pragma mark - Public custom Image setters

- (void)setThumbnailImage:(UIImage *)thumbImage {
    self.thumbnailView.image = thumbImage;
//    self.thumbnailView.alpha = 1.0;
//    self.imageView.alpha = 0.0;
//    self.blurredImageView.alpha = 0.0;
}

- (void)setFullImage:(UIImage *)fullImage {
    //Tile and assign main imageView
    [ImageHelper generateTilesFromImage:fullImage size:CGSizeMake(256, 256) completion:^(TiledImageBuilder *tileImage) {
        [self.imageView displayObject:tileImage];
//        [self.thumbnailView removeFromSuperview];
    }];
}

- (void)setBlurredImage:(UIImage *)fullImage tintColor:(UIColor *)color {
    //Generate blurred image now as well
    [ImageHelper blurredImage:fullImage tintColour:color radius:10.0 completion:^(UIImage *blurredImage) {
        self.blurredImageView.image = blurredImage;
    }];
}

@end