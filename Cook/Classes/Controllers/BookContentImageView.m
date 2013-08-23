//
//  BookCategoryImageView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentImageView.h"
#import "UIColor+Expanded.h"
#import "Theme.h"
#import "ImageHelper.h"
#import "ViewHelper.h"

@interface BookContentImageView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *vignetteOverlayView;

@property (nonatomic, strong) UIImageView *blurredImageView;

@end

@implementation BookContentImageView

#define kForceVisibleOffset         1.0

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        // The containerView is merely to serve as an opaque background for smooth scrolling without much of it clear.
        self.containerView = [[UIView alloc] initWithFrame:[self contentBoundsWithoutForceVisibleOffset]];
        self.containerView.backgroundColor = [Theme recipeGridImageBackgroundColour];
        [self.containerView addSubview:self.imageView];
        [self.containerView addSubview:self.vignetteOverlayView];
        
        // Scrolling overlays
        [self.imageView addSubview:self.blurredImageView];
        
        [self addSubview:self.containerView];
        
        // Motion effects.
        self.containerView.clipsToBounds = YES; // Clipped so that imageView doesn't leak out out.
        [ViewHelper applyDraggyMotionEffectsToView:self.imageView];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.blurredImageView.image = nil;
}

- (void)applyOffset:(CGFloat)offset {
    [self applyOffset:offset distance:200.0 view:self.blurredImageView];
}

- (void)configureImage:(UIImage *)image {
    [self configureImage:image placeholder:NO];
}

- (void)configureImage:(UIImage *)image placeholder:(BOOL)placeholder {
    if (image) {
        self.imageView.image = image;
        self.vignetteOverlayView.hidden = NO;
        
        UIColor *tintColour = [UIColor colorWithRed:22 green:35 blue:30 alpha:0.7];
        [ImageHelper blurredImage:image tintColour:tintColour completion:^(UIImage *blurredImage) {
            self.blurredImageView.image = blurredImage;
        }];
        
    } else {
        self.imageView.image = nil;
        self.vignetteOverlayView.hidden = YES;
    }
}

- (CGSize)imageSizeWithMotionOffset {
    return self.imageView.frame.size;
}

#pragma mark - Properties

- (UIImageView *)imageView {
    if (!_imageView) {
        UIOffset motionOffset = [ViewHelper standardMotionOffset];
        _imageView = [[UIImageView alloc] initWithFrame:(CGRect){
            self.containerView.bounds.origin.x - motionOffset.horizontal,
            self.containerView.bounds.origin.y - motionOffset.vertical,
            self.containerView.bounds.size.width + (motionOffset.horizontal * 2.0),
            self.containerView.bounds.size.height + (motionOffset.vertical * 2.0),
        }];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _imageView;
}

- (UIImageView *)vignetteOverlayView {
    if (!_vignetteOverlayView) {
        _vignetteOverlayView = [[UIImageView alloc] initWithFrame:self.containerView.bounds];
        _vignetteOverlayView.image = [UIImage imageNamed:@"cook_book_inner_page_overlay.png"];
    }
    return _vignetteOverlayView;
}

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        _blurredImageView = [[UIImageView alloc] initWithFrame:self.imageView.bounds];
    }
    return _blurredImageView;
}

#pragma mark - Private methods

- (void)applyOffset:(CGFloat)offset distance:(CGFloat)distance view:(UIView *)view {
    CGFloat alpha = 0.0;
    if (offset <= 0.0) {
        alpha = 0.0;
    } else {
        
        CGFloat ratio = offset / distance;
        alpha = MIN(ratio, 1.0);
    }

    [self applyAlpha:alpha view:view];
}

- (void)applyAlpha:(CGFloat)alpha view:(UIView *)view {
//    NSLog(@"Alpha %f", alpha);
    if (alpha > 0) {
        view.hidden = NO;
        view.alpha = alpha;
    } else {
        view.hidden = YES;
    }
}

- (CGRect)contentBoundsWithoutForceVisibleOffset {
    return (CGRect){
        self.bounds.origin.x + kForceVisibleOffset,
        self.bounds.origin.y,
        self.bounds.size.width - (kForceVisibleOffset * 2.0),
        self.bounds.size.height
    };
}

@end
