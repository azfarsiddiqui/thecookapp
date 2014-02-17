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

@interface CKPhotoView ()

@property (nonatomic, strong) UIImage *thumbnailImage;

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
        _imageView.alpha = 0.0;
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
    self.imageView.alpha = 0.0;
    [ImageHelper generateTilesFromImage:fullImage size:self.imageView.frame.size completion:^(TiledImageBuilder *tileImage) {
        [self.imageView displayObject:tileImage completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.alpha = 1.0;
                self.thumbnailView.image = nil;
                if (completion) {
                    completion();
                }
            });
        }];
        self.isImageLoaded = YES;
    }];
}

- (void)setBlurredImage:(UIImage *)thumbImage tintColor:(UIColor *)color {
    //Generate blurred image now as well
    [ImageHelper blurredImage:thumbImage tintColour:color radius:10.0 completion:^(UIImage *blurredImage) {
        self.blurredImageView.image = blurredImage;
    }];
}

#pragma mark - Clean up methods

- (void)cleanImageViews {
    self.thumbnailView.image = nil;
    self.blurredImageView.image = nil;
    self.imageView.imageView = nil;
    self.isImageLoaded = NO;
}

- (void)deactivateImage {
    self.imageView.imageView = nil;
    self.blurredImageView.image = nil;
}

@end