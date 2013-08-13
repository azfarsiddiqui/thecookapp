//
//  BookRecipeGridCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookRecipeGridCell.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "GridRecipeStatsView.h"
#import "Theme.h"
#import "NSString+Utilities.h"
#import "CKBookCover.h"
#import "RecipeIngredientsView.h"

@interface BookRecipeGridCell ()

@end

@implementation BookRecipeGridCell

#define kViewDebug              0
#define kImageSize              (CGSize){316.0, 260.0}
#define kBlockUnitHeight        200.0
#define kContentInsets          (UIEdgeInsets){50.0, 20.0, 45.0, 20.0}

#define kTitleOffsetNoImage     45.0
#define kTitleTopGap            45.0
#define kTitleDividerGap        20.0
#define kDividerStoryGap        25.0
#define kDividerIngredientsGap  20.0
#define kStatsViewTopOffset     30.0
#define kStoryTopOffset         30.0

+ (CGSize)imageSize {
    return kImageSize;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initBackground];
        [self initImageView];
        [self initTitleLabel];
        [self initIngredientsView];
        [self initStoryLabel];
        [self initMethodLabel];
        [self initStatsView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // Nil the image and stop spinning.
    self.imageView.image = nil;
    [self.activityView stopAnimating];
}

- (void)configureRecipe:(CKRecipe *)recipe book:(CKBook *)book {
    self.recipe = recipe;
    self.book = book;
    
    [self updateImageView];
    [self updateTitle];
    [self updateStory];
    [self updateMethod];
    [self updateIngredients];
    [self updateStats];
}

- (void)configureImage:(UIImage *)image {
    if (image) {
        [self.activityView stopAnimating];
    }
    
    if (image) {
        
        // Fade image in if there were no prior images.
        if (!self.imageView.image) {
            self.imageView.alpha = 0.0;
            self.imageView.image = image;
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.imageView.alpha = 1.0;
                                 self.topRoundedMaskImageView.alpha = 1.0;
                                 self.bottomShadowImageView.alpha = 1.0;
                             }
                             completion:^(BOOL finished)  {
                             }];
            
        } else {
            
            // Otherwise change image straight away.
            self.imageView.image = image;
            self.topRoundedMaskImageView.alpha = 1.0;
            self.bottomShadowImageView.alpha = 1.0;
        }
        
    } else {
        
        // Clear it straight away if none.
        self.imageView.image = nil;
        self.topRoundedMaskImageView.alpha = 0.0;
        self.bottomShadowImageView.alpha = 0.0;
    }
}

- (void)updateImageView {
    if ([self.recipe hasPhotos]) {
        self.imageView.hidden = NO;
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
    } else {
        self.activityView.hidden = YES;
        self.imageView.hidden = YES;
    }
}

- (void)updateTitle {
    
    if ([self.recipe.name CK_containsText]) {
        self.titleLabel.hidden = NO;
        
        // Book specific text colour.
        self.titleLabel.textColor = [CKBookCover textColourForCover:self.book.cover];
        NSString *title = [self.recipe.name uppercaseString];
        NSMutableDictionary *attributes = [NSMutableDictionary new];
        [attributes setObject:self.titleLabel.font forKey:NSFontAttributeName];
        self.titleLabel.text = title;
        
    } else {
        self.titleLabel.hidden = YES;
    }
}

- (void)updateStory {
    if ([self.recipe.story CK_containsText]) {
        self.storyLabel.hidden = NO;
        NSString *story = self.recipe.story;
        CGSize availableSize = (CGSize) {
            self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
            self.statsView.frame.origin.y - self.dividerQuoteImageView.frame.origin.y - self.dividerQuoteImageView.frame.size.height - kDividerStoryGap,
        };
        self.storyLabel.text = story;
        CGSize size = [self.storyLabel sizeThatFits:availableSize];
        self.storyLabel.frame = (CGRect){
            kContentInsets.left,
            self.dividerQuoteImageView.frame.origin.y + self.dividerQuoteImageView.frame.size.height + kDividerStoryGap,
            size.width,
            size.height};
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateMethod {
    if ([self.recipe.method CK_containsText]) {
        self.storyLabel.hidden = NO;
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateIngredients {
    if ([self.recipe.ingredients count] > 0) {
        self.ingredientsView.hidden = NO;
    } else {
        self.ingredientsView.hidden = YES;
    }
}

- (void)updateStats {
    [self.statsView configureRecipe:self.recipe];
}

- (CGSize)availableSize {
    return (CGSize){
        self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
        self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom
    };
}

- (CGSize)availableBlockSize {
    return (CGSize){
        self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
        kBlockUnitHeight
    };
}

- (UIEdgeInsets)contentInsets {
    return kContentInsets;
}

- (BOOL)hasTitle {
    return [self.recipe.name CK_containsText];
}

- (BOOL)hasStory {
    return [self.recipe.story CK_containsText];
}

- (BOOL)hasMethod {
    return [self.recipe.method CK_containsText];
}

- (BOOL)hasIngredients {
    return ([self.recipe.ingredients count] > 0);
}

#pragma mark - UICollectionViewCell methods

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.cellBackgroundImageView.image = [self backgroundImageForSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.cellBackgroundImageView.image = [self backgroundImageForSelected:highlighted];
}

#pragma mark - Private methods

- (void)initBackground {
    self.contentView.backgroundColor = [UIColor clearColor];
    
    // Shadow is outside of cell bounds..
    UIEdgeInsets backgroundInsets = (UIEdgeInsets){ 3.0, 5.0, 7.0, 5.0 };
    
    UIImageView *cellBackgroundImageView = [[UIImageView alloc] initWithFrame:(CGRect){
        self.contentView.bounds.origin.x - backgroundInsets.left,
        self.contentView.bounds.origin.y - backgroundInsets.top,
        self.contentView.bounds.size.width + backgroundInsets.left + backgroundInsets.right,
        self.contentView.bounds.size.height + backgroundInsets.top + backgroundInsets.bottom
    }];
    [self.contentView addSubview:cellBackgroundImageView];
    self.cellBackgroundImageView = cellBackgroundImageView;
    
    [self setSelected:NO];
}

- (void)initImageView {
    
    // Image is 2-in.
    UIEdgeInsets imageInsets = (UIEdgeInsets){ 2.0, 2.0, 0.0, 2.0 };
    
    // Top thumbnail.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){
        self.contentView.bounds.origin.x + imageInsets.left,
        self.contentView.bounds.origin.y + imageInsets.top,
        kImageSize.width,
        kImageSize.height
    }];
    imageView.backgroundColor = [Theme recipeGridImageBackgroundColour];
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    // Image spinner.
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(floorf((self.imageView.bounds.size.width - activityView.frame.size.width) / 2.0),
                                    floorf((self.imageView.bounds.size.height - activityView.frame.size.height) / 2.0),
                                    activityView.frame.size.width,
                                    activityView.frame.size.height);
    [self.imageView addSubview:activityView];
    self.activityView = activityView;
    
    // Top rounded mask image.
    self.topRoundedMaskImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    self.topRoundedMaskImageView.frame = (CGRect){
        self.imageView.bounds.origin.x,
        self.imageView.bounds.origin.y,
        self.imageView.bounds.size.width,
        self.topRoundedMaskImageView.frame.size.height
    };
    self.topRoundedMaskImageView.alpha = 0.0;   // Clear to start off with.
    [self.imageView addSubview:self.topRoundedMaskImageView];
    
    // Bottom shadow image.
    self.bottomShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.bottomShadowImageView.frame = (CGRect){
        self.imageView.bounds.origin.x,
        self.imageView.bounds.size.height - self.bottomShadowImageView.frame.size.height,
        self.imageView.bounds.size.width,
        self.bottomShadowImageView.frame.size.height
    };
    self.bottomShadowImageView.alpha = 0.0;   // Clear to start off with.
    [self.imageView addSubview:self.bottomShadowImageView];
}

- (void)initTitleLabel {
    // Recipe title that spans 2 lines.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [self backgroundColorOrDebug];
    titleLabel.font = [Theme recipeGridTitleFont];
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)initIngredientsView {
    RecipeIngredientsView *ingredientsView = [[RecipeIngredientsView alloc] initWithIngredients:nil
                                                                                        maxSize:[self availableBlockSize]];
    [self.contentView addSubview:ingredientsView];
    self.ingredientsView = ingredientsView;
}

- (void)initStoryLabel {
    UILabel *storyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    storyLabel.backgroundColor = [self backgroundColorOrDebug];
    storyLabel.font = [Theme recipeGridIngredientsFont];
    storyLabel.textColor = [Theme recipeGridIngredientsColour];
    storyLabel.numberOfLines = 0;
    storyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    storyLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:storyLabel];
    self.storyLabel = storyLabel;
}

- (void)initMethodLabel {
    UILabel *methodLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    methodLabel.backgroundColor = [self backgroundColorOrDebug];
    methodLabel.font = [Theme recipeGridIngredientsFont];
    methodLabel.textColor = [Theme recipeGridIngredientsColour];
    methodLabel.numberOfLines = 0;
    methodLabel.lineBreakMode = NSLineBreakByWordWrapping;
    methodLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:methodLabel];
    self.methodLabel = methodLabel;
}

- (void)initStatsView {
    
    // Bottom stats view.
    CGFloat availableWidth = self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right;
    GridRecipeStatsView *statsView = [[GridRecipeStatsView alloc] initWithWidth:availableWidth];
    statsView.frame = (CGRect) {
        kContentInsets.left + floorf((self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right - statsView.frame.size.width) / 2.0),
        self.contentView.bounds.size.height - statsView.frame.size.height - kContentInsets.bottom,
        statsView.frame.size.width,
        statsView.frame.size.height
    };
    [self.contentView addSubview:statsView];
    self.statsView = statsView;
}

- (UIColor *)backgroundColorOrDebug {
    if (kViewDebug) {
        return [UIColor colorWithRed:0 green:255 blue:0 alpha:0.5];
    } else {
        return [UIColor clearColor];
    }
}

- (UIImage *)backgroundImageForSelected:(BOOL)selected {
    return [[UIImage imageNamed:@"cook_book_inner_grid_cell.png"]
            resizableImageWithCapInsets:(UIEdgeInsets){ 8.0, 11.0, 12.0, 11.0 }];
}

@end