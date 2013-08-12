//
//  RecipeCollectionViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookRecipeCollectionViewCell.h"
#import "CKRecipe.h"
#import "CKBook.h"
#import "Theme.h"
#import "UIImage+ProportionalFill.h"
#import "MRCEnumerable.h"
#import "Ingredient.h"
#import "GridRecipeStatsView.h"
#import "ImageHelper.h"
#import "CKBookCover.h"
#import "ViewHelper.h"

@interface BookRecipeCollectionViewCell ()

@property (nonatomic, strong) CKBook *book;

@property (nonatomic, strong) UIImageView *cellBackgroundImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *topRoundedMaskImageView;
@property (nonatomic, strong) UIImageView *bottomShadowImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *dividerImageView;
@property (nonatomic, strong) UIImageView *dividerQuoteImageView;
@property (nonatomic, strong) UILabel *ingredientsLabel;
@property (nonatomic, strong) UILabel *ingredientsEllipsisLabel;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) GridRecipeStatsView *statsView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation BookRecipeCollectionViewCell

#define kViewDebug              0
#define kImageSize              CGSizeMake(316.0, 260.0)
#define kTitleOffsetNoImage     45.0
#define kTitleTopGap            45.0
#define kTitleDividerGap        20.0
#define kDividerStoryGap        25.0
#define kDividerIngredientsGap  20.0
#define kStatsViewTopOffset     30.0
#define kStoryTopOffset         30.0
#define kContentInsets          UIEdgeInsetsMake(30.0, 40.0, 20.0, 40.0)

+ (CGSize)imageSize {
    return kImageSize;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self initBackground];
        [self initImageView];
        
        // Recipe title that spans 2 lines.
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [self backgroundColorOrDebug];
        titleLabel.font = [Theme recipeGridTitleFont];
        titleLabel.numberOfLines = 2;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        // Recipe ingredients.
        UILabel *ingredientsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        ingredientsLabel.backgroundColor = [self backgroundColorOrDebug];
        ingredientsLabel.font = [Theme recipeGridIngredientsFont];
        ingredientsLabel.textColor = [Theme recipeGridIngredientsColour];
        ingredientsLabel.numberOfLines = 0;
        ingredientsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:ingredientsLabel];
        self.ingredientsLabel = ingredientsLabel;
        
        // Recipe ingredients ellipsis.
        NSString *ellipsis = @"...";
        CGRect ingredientsFrame = [ellipsis boundingRectWithSize:self.contentView.bounds.size
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:nil context:nil];
        UILabel *ingredientsEllipsisLabel = [[UILabel alloc] initWithFrame:CGRectMake(kContentInsets.left,
                                                                                      self.ingredientsLabel.frame.size.height,
                                                                                      ingredientsFrame.size.width,
                                                                                      ingredientsFrame.size.height)];
        ingredientsEllipsisLabel.backgroundColor = [self backgroundColorOrDebug];
        ingredientsEllipsisLabel.font = [Theme recipeGridIngredientsFont];
        ingredientsEllipsisLabel.textColor = [Theme recipeGridIngredientsColour];
        ingredientsEllipsisLabel.numberOfLines = 1;
        ingredientsEllipsisLabel.lineBreakMode =NSLineBreakByClipping;
        ingredientsEllipsisLabel.text = @"...";
        [self.contentView addSubview:ingredientsEllipsisLabel];
        self.ingredientsEllipsisLabel = ingredientsEllipsisLabel;
        
        // Story.
        UILabel *storyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        storyLabel.backgroundColor = [self backgroundColorOrDebug];
        storyLabel.font = [Theme recipeGridIngredientsFont];
        storyLabel.textColor = [Theme recipeGridIngredientsColour];
        storyLabel.numberOfLines = 0;
        storyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        storyLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:storyLabel];
        self.storyLabel = storyLabel;
        
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
    return self;
}

- (void)configureRecipe:(CKRecipe *)recipe book:(CKBook *)book {
    self.recipe = recipe;
    self.book = book;
    
    [self updateTitle];
    [self updateDivider];
    [self updateStory];
    [self updateIngredients];
    [self updateStats];
    
    // Nil the image and start spinning if required.
    self.imageView.image = nil;
    if ([recipe hasPhotos]) {
        [self.activityView startAnimating];
        self.imageView.backgroundColor = [Theme recipeGridImageBackgroundColour];
    } else {
        self.imageView.backgroundColor = [UIColor clearColor];
    }
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

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.cellBackgroundImageView.image = [self backgroundImageForSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.cellBackgroundImageView.image = [self backgroundImageForSelected:highlighted];
}

#pragma mark - Properties

- (UIImageView *)dividerImageView {
    if (!_dividerImageView) {
        _dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_titledivider_solid.png"]];
    }
    return _dividerImageView;
}

- (UIImageView *)dividerQuoteImageView {
    if (!_dividerQuoteImageView) {
        _dividerQuoteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_titledivider_quote.png"]];
    }
    return _dividerQuoteImageView;
}

- (UIImageView *)topRoundedMaskImageView {
    if (!_topRoundedMaskImageView) {
        UIImage *topRoundedMaskImage = [[UIImage imageNamed:@"cook_book_inner_grid_image_top.png"]
                                        resizableImageWithCapInsets:(UIEdgeInsets){ 0.0, 2.0, 0.0, 2.0 }];
        _topRoundedMaskImageView = [[UIImageView alloc] initWithImage:topRoundedMaskImage];
    }
    return _topRoundedMaskImageView;
}

- (UIImageView *)bottomShadowImageView {
    if (!_bottomShadowImageView) {
        UIImage *bottomShadowImage = [UIImage imageNamed:@"cook_book_inner_grid_image_bottom.png"];
        _bottomShadowImageView = [[UIImageView alloc] initWithImage:bottomShadowImage];
    }
    return _bottomShadowImageView;
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

- (void)updateTitle {
    self.titleLabel.textColor = [CKBookCover textColourForCover:self.book.cover];
    
    NSString *title = [self.recipe.name uppercaseString];
    CGRect frame = self.titleLabel.frame;
    CGSize availableSize = [self availableSize];
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes setObject:self.titleLabel.font forKey:NSFontAttributeName];
    if (![self.recipe hasPhotos]) {
        frame.origin.y = kTitleOffsetNoImage;
    }
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = title;
    CGSize size = [self.titleLabel sizeThatFits:availableSize];
    self.titleLabel.frame = (CGRect){
        kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
        self.imageView.frame.origin.y + self.imageView.frame.size.height + kTitleTopGap,
        size.width,
        size.height};
}

- (void)updateDivider {
    [self.dividerImageView removeFromSuperview];
    [self.dividerQuoteImageView removeFromSuperview];
    
    if ([self.recipe hasPhotos]) {
        self.dividerQuoteImageView.frame = (CGRect){
            floorf((self.contentView.bounds.size.width - self.dividerQuoteImageView.frame.size.width) / 2.0),
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleDividerGap,
            self.dividerQuoteImageView.frame.size.width,
            self.dividerQuoteImageView.frame.size.height
        };
        [self.contentView addSubview:self.dividerQuoteImageView];
        
    } else if (![self.recipe hasPhotos]) {
        self.dividerImageView.frame = (CGRect){
            floorf((self.contentView.bounds.size.width - self.dividerImageView.frame.size.width) / 2.0),
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleDividerGap - 5.0,
            self.dividerImageView.frame.size.width,
            self.dividerImageView.frame.size.height
        };
        [self.contentView addSubview:self.dividerImageView];
    }
}

- (void)updateStory {
    if ([self.recipe hasPhotos] && [self.recipe.story length] > 0) {
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

- (void)updateIngredients {

    if (![self.recipe hasPhotos]) {
        self.ingredientsLabel.hidden = NO;
        
        // Extract ingredients into line wrapped text.
        NSMutableArray *ingredients = [NSMutableArray arrayWithArray:[[self.recipe ingredients] collect:^id(Ingredient *ingredient) {
            if (ingredient.measurement) {
                return [NSString stringWithFormat:@"%@ %@", ingredient.measurement, ingredient.name];
            } else {
                return ingredient.name;
            }
        }]];
        NSString *ingredientsDisplay = [ingredients componentsJoinedByString:@"\n"];
        
        // Now figure out positioning based on story.
        CGSize availableSize = CGSizeMake(self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                                          self.statsView.frame.origin.y - self.dividerImageView.frame.origin.y - self.dividerImageView.frame.size.height - kDividerIngredientsGap);
        CGSize size = [ingredientsDisplay sizeWithFont:self.ingredientsLabel.font
                                     constrainedToSize:CGSizeMake(availableSize.width, availableSize.height + 100.0)    // Makes sure we have more than enough to know we have more text.
                                  lineBreakMode:NSLineBreakByWordWrapping];
        
        // If we exceeded the available height, then we need to display ellipsis by replacing last ingredient.
        if (size.height > availableSize.height) {
            
            self.ingredientsEllipsisLabel.hidden = NO;
            
            // Remove one line of text height to make way for the ellipsis.
            size = [ingredientsDisplay sizeWithFont:self.ingredientsLabel.font constrainedToSize:availableSize lineBreakMode:NSLineBreakByWordWrapping];
            size.height = size.height - [self singleLineIngredientHeight];
            
        } else {
            self.ingredientsEllipsisLabel.hidden = YES;
        }
        
        // Update frame.
        self.ingredientsLabel.frame = CGRectMake(kContentInsets.left,
                                                 self.dividerImageView.frame.origin.y + self.dividerImageView.frame.size.height + kDividerIngredientsGap,
                                                 size.width,
                                                 size.height);
        self.ingredientsLabel.text = ingredientsDisplay;
        
        // Update ellipsis.
        if (!self.ingredientsEllipsisLabel.hidden) {
            self.ingredientsEllipsisLabel.frame = (CGRect){
                self.ingredientsEllipsisLabel.frame.origin.x,
                self.ingredientsLabel.frame.origin.y + self.ingredientsLabel.frame.size.height,
                self.ingredientsEllipsisLabel.frame.size.width,
                self.ingredientsEllipsisLabel.frame.size.height
            };
        }
        
    } else {
        self.ingredientsEllipsisLabel.hidden = YES;
        self.ingredientsLabel.hidden = YES;
    }
    
}

- (void)updateStats {
    [self.statsView configureRecipe:self.recipe];
}

- (CGFloat)singleLineTitleHeight {
    return [@"A" sizeWithFont:[Theme recipeGridTitleFont] constrainedToSize:self.contentView.bounds.size
                lineBreakMode:NSLineBreakByWordWrapping].height;
}

- (CGFloat)singleLineIngredientHeight {
    return [@"A" sizeWithFont:[Theme recipeGridIngredientsFont] constrainedToSize:self.contentView.bounds.size
                lineBreakMode:NSLineBreakByWordWrapping].height;
}

- (CGFloat)titleBottomOffset {
    CGFloat offset = 0.0;
    CGFloat singleLineHeight = [self singleLineTitleHeight];
    
    if (self.titleLabel.frame.size.height >= singleLineHeight) {
        offset = 24.0;
    } else {
        offset = 48.0;
    }
    
    return offset;
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

- (CGSize)availableSize {
    return CGSizeMake(self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

@end
