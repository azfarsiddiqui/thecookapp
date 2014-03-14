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
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CKPhotoView *photoView;
@property (nonatomic, strong) UIImageView *vignetteOverlayView;
@property (nonatomic, assign) BOOL fullImageLoaded;
@property (nonatomic, assign) BOOL isThumbLoading;

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
        
        [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
        
        self.isThumbLoading = NO;
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

- (void)configureFeaturedRecipe:(CKRecipe *)recipe book:(CKBook *)book cachedImage:(UIImage *)cachedImage {
    self.recipe = recipe;
    self.book = book;
    self.fullImageLoaded = NO;
    
    self.photoView.thumbnailView.image = [CKBookCover recipeEditBackgroundImageForCover:self.book.cover];
    
    if (cachedImage) {
        //If cached thumb image, skip to directly assigning it
        self.isThumbLoading = NO;
        [self configureImage:cachedImage book:self.book thumb:YES];
    } else {
        self.isThumbLoading = YES;
        [self assignRecipeImage];
    }
}

- (void)assignRecipeImage {
    //Set initial image but don't use provided method because we don't want to trigger imageLoaded flag
    if (!self.photoView.thumbnailView.image || !self.recipe || !self.recipe.recipeImage) {
        self.photoView.thumbnailView.image = [CKBookCover recipeEditBackgroundImageForCover:self.book.cover];
    }
    if ([self.recipe hasPhotos]) {
        [[CKPhotoManager sharedInstance] thumbImageForRecipe:self.recipe name:[self photoName] size:[self imageSizeWithMotionOffset]];
    }
}

- (void)assignFullImage {
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //Check with BookNavigation to see if we should run a full load
        if (self.delegate && [self.delegate shouldRunFullLoadForIndex:self.pageIndex]) {
            [[CKPhotoManager sharedInstance] imageForRecipe:self.recipe size:[self imageSizeWithMotionOffset]];
        }
    });
}

- (CGSize)imageSizeWithMotionOffset {
    return self.photoView.frame.size;
}

- (void)reloadWithBook:(CKBook *)book {
    if (!self.isThumbLoading) {
        [self assignRecipeImage];
    }
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
        _photoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
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
    NSString *recipePhotoName = [EventHelper nameForPhotoLoading:notification];
    
    if ([[self photoName] isEqualToString:recipePhotoName]) {
        
        UIImage *image = [EventHelper imageForPhotoLoading:notification];
        
        if ([EventHelper thumbForPhotoLoading:notification]) {
            
            // Thumb image processing
            self.isThumbLoading = NO;

            if (self.delegate && image && [self.delegate respondsToSelector:@selector(retrievedThumb:forRecipe:)]) {
                [self.delegate retrievedThumb:image forRecipe:self.recipe];
            }
            [self configureImage:image book:self.book thumb:YES];
        
            //When image is loaded, delay for an additional second to allow for user to decide if they like this page
            if (!self.fullImageLoaded) {
                [self assignFullImage];
            }
            
        } else {
            
            // Fullsize image processing.
            if ([self.delegate shouldRunFullLoadForIndex:self.pageIndex]) {
                [self configureImage:image book:self.book thumb:NO];
                self.fullImageLoaded = YES;
            }
            
        }
    }
}

- (NSString *)photoName {
    return [NSString stringWithFormat:@"background_%@", self.recipe.objectId];
}

#pragma mark - Public methods

- (void)configureImage:(UIImage *)image book:(CKBook *)book thumb:(BOOL)isThumb {
    if (image) {
        self.vignetteOverlayView.hidden = NO;
        
        if (isThumb) {
            [self.photoView setThumbnailImage:image];
            if (self.delegate && ([self.delegate shouldRunFullLoadForIndex:self.pageIndex] || [self.delegate shouldRunFullLoadForIndex:self.pageIndex - 1] || [self.delegate shouldRunFullLoadForIndex:self.pageIndex + 1])) {
                UIColor *tintColour = [[CKBookCover bookContentTintColourForCover:book.cover] colorWithAlphaComponent:0.58];
                
                __weak BookContentImageView *weakSelf = self;
                [[CKPhotoManager sharedInstance] blurredImageForRecipe:self.recipe
                                                             tintColor:tintColour
                                                            thumbImage:image
                                                            completion:^(UIImage *thumbImage, NSString *name) {
                                                                [weakSelf.photoView setBlurredImage:thumbImage];
                                                                [weakSelf.delegate retrievedBlurredImage:thumbImage forRecipe:weakSelf.recipe];
                                                             }];
            }
        } else {
            DLog(@"Activate FULL LOAD: %@", self.recipe.name);
            [self.photoView setFullImage:image];
        }
        
    } else {
        [self.photoView cleanImageViews];
        self.fullImageLoaded = NO;
        self.vignetteOverlayView.hidden = YES;
    }
}

- (void)configureBlurredImage:(UIImage *)blurredImage {
    if (blurredImage) {
        [self.photoView setBlurredImage:blurredImage];
    }
}

- (void)deactivateImage {
    [self.photoView deactivateImage];
    self.fullImageLoaded = NO;
}

- (void)cleanImage {
    [self.photoView cleanImageViews];
    self.fullImageLoaded = NO;
    self.photoView.thumbnailView.image = [CKBookCover recipeEditBackgroundImageForCover:self.book.cover];
}

- (BOOL)hasImage {
    return self.photoView.thumbnailView.image;
}

@end
