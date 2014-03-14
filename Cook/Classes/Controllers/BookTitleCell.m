//
//  BookTitleCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleCell.h"
#import "ImageHelper.h"
#import "Theme.h"
#import "CKBook.h"
#import "CKBookCover.h"
#import "CKRecipe.h"
#import "EventHelper.h"
#import "CKPhotoManager.h"

@interface BookTitleCell ()

@property (nonatomic, strong) CKRecipe *coverRecipe;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *imageOverlayView;
@property (nonatomic, strong) UIImageView *stackImageView;
@property (nonatomic, strong) UIImageView *blankOverlayView;
@property (nonatomic, strong) UIImageView *addView;
@property (nonatomic, strong) UIImageView *newIndicatorView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation BookTitleCell

#define kCellInsets             (UIEdgeInsets){10.0, 10.0, 18.0, 10.0}
#define kTitleSubtitleGap       -7
#define kSingleStackThreshold   2
#define kDoubleStackThreshold   4

+ (CGSize)cellSize {
    return (CGSize) { 256.0, 192.0 };
}

- (void)dealloc {
    [EventHelper unregisterPhotoLoading:self];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.stackImageView];
        [self.contentView addSubview:self.imageOverlayView];
        [self.contentView addSubview:self.blankOverlayView];
        [self.contentView addSubview:self.addView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subtitleLabel];
        [self.contentView addSubview:self.newIndicatorView];
        
        // Register photo loading events.
        [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.coverRecipe = nil;
    self.imageView.image = nil;
}

- (void)configurePage:(NSString *)page numRecipes:(NSInteger)numRecipes containNewRecipes:(BOOL)newRecipes
                 book:(CKBook *)book {
    self.titleLabel.hidden = NO;
    self.subtitleLabel.hidden = NO;
    self.blankOverlayView.hidden = YES;
    self.addView.hidden = YES;
    
    [self addStacksWithNumRecipes:numRecipes];

    self.titleLabel.text = [page uppercaseString];
    
    NSMutableString *numRecipesDisplay = [NSMutableString stringWithFormat:@"%d RECIPE", numRecipes];
    if (numRecipes != 1) {
        [numRecipesDisplay appendString:@"S"];
    }
    self.subtitleLabel.text = numRecipesDisplay;
    
    [self.titleLabel sizeToFit];
    [self.subtitleLabel sizeToFit];
    
    CGFloat requiredheight = self.titleLabel.frame.size.height + kTitleSubtitleGap + self.subtitleLabel.frame.size.height;
    self.titleLabel.frame = (CGRect){
        floorf((self.contentView.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
        floorf((self.contentView.bounds.size.height - requiredheight) / 2.0),
        self.titleLabel.frame.size.width,
        self.titleLabel.frame.size.height
    };
    self.subtitleLabel.frame = (CGRect){
        floorf((self.contentView.bounds.size.width - self.subtitleLabel.frame.size.width) / 2.0),
        self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleSubtitleGap,
        self.subtitleLabel.frame.size.width,
        self.subtitleLabel.frame.size.height
    };
    
    // New indicator.
    self.newIndicatorView.image = [CKBookCover newIndicatorImageForCover:book.cover selected:NO];
    self.newIndicatorView.hidden = !newRecipes;
}

- (void)configureCoverRecipe:(CKRecipe *)recipe {
    self.coverRecipe = recipe;
    
    CGSize imageSize = [BookTitleCell cellSize];
    if ([recipe hasPhotos]) {
        [[CKPhotoManager sharedInstance] thumbImageForRecipe:recipe name:nil size:imageSize];
    }
}

- (void)configureAsAddCellForBook:(CKBook *)book {
    self.imageView.hidden = YES;
    self.stackImageView.hidden = YES;
    self.imageOverlayView.hidden = YES;
    self.titleLabel.hidden = YES;
    self.subtitleLabel.hidden = YES;
    self.blankOverlayView.hidden = NO;
    self.addView.image = [CKBookCover addCategoryImageForCover:book.cover selected:NO];
    self.addView.hidden = NO;
    self.newIndicatorView.hidden = YES;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.imageOverlayView.image = [UIImage imageNamed:@"cook_book_inner_category_overlay_onpress.png"];
        self.blankOverlayView.image = [UIImage imageNamed:@"cook_book_inner_category_blank_onpress.png"];
    }
    else {
        self.imageOverlayView.image = [UIImage imageNamed:@"cook_book_inner_category_overlay.png"];
        self.blankOverlayView.image = [UIImage imageNamed:@"cook_book_inner_category_blank.png"];
    }
}

#pragma mark - Properties

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    }
    return _imageView;
}

- (UIImageView *)imageOverlayView {
    if (!_imageOverlayView) {
        _imageOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_category_overlay.png"]];
        _imageOverlayView.frame = (CGRect){
            -kCellInsets.left,
            -kCellInsets.top,
            _imageOverlayView.frame.size.width,
            _imageOverlayView.frame.size.height
        };
    }
    return _imageOverlayView;
}

- (UIImageView *)stackImageView {
    if (!_stackImageView) {
        _stackImageView = [[UIImageView alloc] initWithImage:[self imageForStackSingle:YES]];
        _stackImageView.hidden = YES;
        _stackImageView.frame = (CGRect){
            self.imageOverlayView.frame.origin.x,
            self.imageOverlayView.frame.origin.y - _stackImageView.frame.size.height + kCellInsets.top,
            _stackImageView.frame.size.width,
            _stackImageView.frame.size.height
        };
    }
    return _stackImageView;
}

- (UIImageView *)blankOverlayView {
    if (!_blankOverlayView) {
        _blankOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_category_blank.png"]];
        _blankOverlayView.frame = self.imageOverlayView.frame;
    }
    return _blankOverlayView;
}

- (UIImageView *)addView {
    if (!_addView) {
        _addView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_category_add.png"]];
        _addView.frame = (CGRect){
            floorf((self.contentView.bounds.size.width - _addView.frame.size.width) / 2.0),
            floorf((self.contentView.bounds.size.height - _addView.frame.size.height) / 2.0),
            _addView.frame.size.width,
            _addView.frame.size.height
        };
    }
    return _addView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [Theme bookIndexFont];
        _titleLabel.textColor = [Theme bookIndexColour];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.font = [Theme bookIndexSubtitleFont];
        _subtitleLabel.textColor = [Theme bookIndexSubtitleColour];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
    }
    return _subtitleLabel;
}

- (UIImageView *)newIndicatorView {
    if (!_newIndicatorView) {
        _newIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_category_new.png"]];
        _newIndicatorView.frame = (CGRect){
            floorf((self.contentView.bounds.size.width - _newIndicatorView.frame.size.width) / 2.0),
            38.0,
            _newIndicatorView.frame.size.width,
            _newIndicatorView.frame.size.height
        };
    }
    return _newIndicatorView;
}

#pragma mark - Private methods

- (UIImage *)imageForStackSingle:(BOOL)single {
    if (single) {
        return [UIImage imageNamed:@"cook_book_inner_category_stack_one.png"];
    } else {
        return [UIImage imageNamed:@"cook_book_inner_category_stack_two.png"];
    }
}

- (void)addStacksWithNumRecipes:(NSInteger)numRecipes {
    if (numRecipes > kDoubleStackThreshold) {
        self.stackImageView.image = [self imageForStackSingle:NO];
        self.stackImageView.hidden = NO;
    } else if (numRecipes > kSingleStackThreshold) {
        self.stackImageView.image = [self imageForStackSingle:YES];
        self.stackImageView.hidden = NO;
    } else {
        self.stackImageView.hidden = YES;
    }
}

- (void)configureImage:(UIImage *)image {
    self.imageView.hidden = NO;
    self.imageOverlayView.hidden = NO;
    if (!image) {
        self.imageView.hidden = YES;
        self.blankOverlayView.hidden = NO;
    }
    [ImageHelper configureImageView:self.imageView image:image];
}

- (void)photoLoadingReceived:(NSNotification *)notification {
    NSString *name = [EventHelper nameForPhotoLoading:notification];
    BOOL thumb = [EventHelper thumbForPhotoLoading:notification];
    NSString *recipePhotoName = [[CKPhotoManager sharedInstance] photoNameForRecipe:self.coverRecipe];
    
    if ([recipePhotoName isEqualToString:name] && thumb) {
        if ([EventHelper hasImageForPhotoLoading:notification]) {
            UIImage *image = [EventHelper imageForPhotoLoading:notification];
            [self configureImage:image];
        }
    }
}

@end
