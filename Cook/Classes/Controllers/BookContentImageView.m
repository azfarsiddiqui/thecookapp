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
#import "CKBook.h"
#import "CKRecipe.h"
#import "CKBookCover.h"
#import "EventHelper.h"
#import "CKPhotoManager.h"
#import "NSString+Utilities.h"
#import "CKPhotoView.h"

@interface BookContentImageView ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CKPhotoView *photoView;
@property (nonatomic, strong) UIImageView *vignetteOverlayView;
@property (nonatomic, assign) BOOL fullImageLoaded;

@end

@implementation BookContentImageView

#define kForceVisibleOffset         1.0

- (void)dealloc {
    self.photoView = nil;
    self.vignetteOverlayView.image = nil;
    [EventHelper unregisterPhotoLoading:self];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        // The containerView is merely to serve as an opaque background for smooth scrolling without much of it clear.
        self.containerView = [[UIView alloc] initWithFrame:[self contentBoundsWithoutForceVisibleOffset]];
        self.containerView.backgroundColor = [Theme recipeGridImageBackgroundColour];
        [self.containerView addSubview:self.photoView];
        [self.containerView addSubview:self.vignetteOverlayView];
        
        // Scrolling overlays
        [self addSubview:self.containerView];
        
        // Motion effects.
        self.containerView.clipsToBounds = YES; // Clipped so that imageView doesn't leak out out.
        [ViewHelper applyDraggyMotionEffectsToView:self.photoView];
        
        // Register photo loading events.
        [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.photoView cleanImageViews];
    self.recipe = nil;
    self.book = nil;
    self.fullImageLoaded = NO;
}

- (void)applyOffset:(CGFloat)offset {
    [self applyOffset:offset distance:200.0 view:self.photoView.blurredImageView];
}

- (void)configureFeaturedRecipe:(CKRecipe *)recipe book:(CKBook *)book {
    self.recipe = recipe;
    self.book = book;
    self.fullImageLoaded = NO;
    [self configureImage:[CKBookCover recipeEditBackgroundImageForCover:book.cover] book:book];
    
    if ([recipe hasPhotos]) {
        [[CKPhotoManager sharedInstance] imageForRecipe:recipe size:[self imageSizeWithMotionOffset]];
    }
}

- (CGSize)imageSizeWithMotionOffset {
    return self.photoView.frame.size;
}

- (void)reloadWithBook:(CKBook *)book {
    self.isFullLoad = YES;
    [self configureFeaturedRecipe:self.recipe book:book];
//    [self configureImage:self.imageView.image book:book];
}

#pragma mark - Properties

- (CKPhotoView *)photoView {
    if (!_photoView) {
        UIOffset motionOffset = [ViewHelper standardMotionOffset];
        _photoView = [[CKPhotoView alloc] initWithFrame:(CGRect){
            self.containerView.bounds.origin.x - motionOffset.horizontal,
            self.containerView.bounds.origin.y - motionOffset.vertical,
            self.containerView.bounds.size.width + (motionOffset.horizontal * 2.0),
            self.containerView.bounds.size.height + (motionOffset.vertical * 2.0),
        }];
    }
    return _photoView;
}

- (UIImageView *)vignetteOverlayView {
    if (!_vignetteOverlayView) {
        _vignetteOverlayView = [[UIImageView alloc] initWithFrame:self.containerView.bounds];
        _vignetteOverlayView.image = [UIImage imageNamed:@"cook_book_inner_page_overlay.png"];
    }
    return _vignetteOverlayView;
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

- (void)photoLoadingReceived:(NSNotification *)notification {
    NSString *name = [EventHelper nameForPhotoLoading:notification];
    BOOL thumb = [EventHelper thumbForPhotoLoading:notification];
    NSString *recipePhotoName = [[CKPhotoManager sharedInstance] photoNameForRecipe:self.recipe];
    
    if ([recipePhotoName isEqualToString:name]) {
        
        // If full image is not loaded yet, then keep setting it until it has been flagged as fully loaded.
        if (!self.fullImageLoaded) {
            if ([EventHelper hasImageForPhotoLoading:notification]) {
                UIImage *image = [EventHelper imageForPhotoLoading:notification];
                [self configureImage:image book:self.book];
                self.fullImageLoaded = !thumb;
            }
        }
    }
}

- (void)configureImage:(UIImage *)image book:(CKBook *)book {
    if (image) {
        self.vignetteOverlayView.hidden = NO;
        
        //Only set blurred image if user has explicitly navigated or fast-forwarded to this page
        if (self.isFullLoad && self.fullImageLoaded) {
            UIColor *tintColour = [[CKBookCover bookContentTintColourForCover:book.cover] colorWithAlphaComponent:0.58];
            [self.photoView setFullImage:image];
            [self.photoView setBlurredImage:image tintColor:tintColour];
        } else {
            [self.photoView setThumbnailImage:image];
        }
        
    } else {
        [self.photoView cleanImageViews];
        self.vignetteOverlayView.hidden = YES;
    }
}

@end
