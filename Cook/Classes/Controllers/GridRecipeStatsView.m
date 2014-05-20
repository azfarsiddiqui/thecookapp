//
//  GridRecipeActionsView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "GridRecipeStatsView.h"
#import "MRCEnumerable.h"
#import "UIColor+Expanded.h"
#import "CKRecipe.h"
#import "Theme.h"
#import "NSString+Utilities.h"
#import "CKBookCover.h"
#import "CKSocialManager.h"
#import "DataHelper.h"
#import "DateHelper.h"
#import "RecipeDetails.h"

@interface GridRecipeStatsView ()

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) NSMutableArray *iconViews;
@property (nonatomic, strong) UIImageView *servesImageView;
@property (nonatomic, strong) UIImageView *timeImageView;
@property (nonatomic, strong) UIImageView *commentsImageView;
@property (nonatomic, strong) UIImageView *likesImageView;

@end

@implementation GridRecipeStatsView

#define kIconLabelGap       -6.0
#define kContentInsets      UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
#define kUnitStatSize       CGSizeMake(60.0, 40.0)
#define kContainerIconTag   301
#define kContainerLabelTag  302
#define kStatGap            0.0

- (id)initWithWidth:(CGFloat)width {
    if (self = [super initWithFrame:(CGRect){ 0.0, 0.0, width, kContentInsets.top + kUnitStatSize.height + kContentInsets.bottom}]) {
        [self initIconViews];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configureRecipe:(CKRecipe *)recipe {
    [self reset];
    
    self.recipe = recipe;
    
    if (self.recipe.quantityType == CKQuantityServes) {
        [self configureValue:[self servesDisplayForPrepTime:recipe.numServes] iconIndex:0];
    } else {
        [self configureValue:[self makesDisplayForPrepTime:recipe.numServes] iconIndex:0];
    }
    
    [self configureValue:[self prepCookTotalDisplayForPrepTime:recipe.prepTimeInMinutes cookTime:recipe.cookingTimeInMinutes] iconIndex:1];
    [self configureValue:[DataHelper friendlyDisplayForCount:[[CKSocialManager sharedInstance] numCommentsForRecipe:recipe]] iconIndex:2];
    [self configureValue:[DataHelper friendlyDisplayForCount:[[CKSocialManager sharedInstance] numLikesForRecipe:recipe]] iconIndex:3];
    
    [self layoutIconViews];
    
    //Set serves/makes icon
    UIView *iconContainerView = [self.iconViews firstObject];
    UIImageView *iconImageView = (UIImageView *)[iconContainerView viewWithTag:kContainerIconTag];
    iconImageView.image = [UIImage imageNamed:self.recipe.quantityType == CKQuantityMakes ? @"cook_book_inner_icon_small_makes" : @"cook_book_inner_icon_small_serves.png"];
}

#pragma mark - Private methods

- (void)initIconViews {
    self.iconViews = [NSMutableArray array];
    [self configureIcon:@"cook_book_inner_icon_small_serves.png"];
    [self configureIcon:@"cook_book_inner_icon_small_time.png"];
    [self configureIcon:@"cook_book_inner_icon_small_comments.png"];
    [self configureIcon:@"cook_book_inner_icon_small_likes_off.png"];
}

- (void)configureIcon:(NSString *)iconName {
    UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){
        0.0, 0.0, kUnitStatSize.width, kUnitStatSize.height
    }];
    containerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    imageView.tag = kContainerIconTag;
    imageView.frame = (CGRect){
        floorf((containerView.bounds.size.width - imageView.frame.size.width) / 2.0),
        0.0,
        imageView.frame.size.width,
        imageView.frame.size.height
    };
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [Theme recipeGridStatFont];
    label.textColor = [Theme recipeGridStatColour];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = (CGSize){0.0, 1.0};
    label.text = @"";
    label.tag = kContainerLabelTag;
    [label sizeToFit];
    label.frame = (CGRect){
        floorf((containerView.bounds.size.width - label.frame.size.width) / 2.0),
        imageView.frame.origin.y + imageView.frame.size.height + kIconLabelGap,
        label.frame.size.width,
        label.frame.size.height
    };
    
    [containerView addSubview:imageView];
    [containerView addSubview:label];
    [self.iconViews addObject:containerView];
}

- (void)configureValue:(NSString *)value iconIndex:(NSInteger)iconIndex {
    UIView *iconContainerView = [self.iconViews objectAtIndex:iconIndex];
    if ([value length] > 0) {
        
        // Update label.
        UILabel *label = (UILabel *)[iconContainerView viewWithTag:kContainerLabelTag];
        label.text = value;
        [label sizeToFit];
        label.frame = (CGRect){
            floorf((iconContainerView.bounds.size.width - label.frame.size.width) / 2.0),
            label.frame.origin.y,
            label.frame.size.width,
            label.frame.size.height
        };
    } else {
        iconContainerView.hidden = YES;
    }
}

- (void)reset {
    for (UIView *iconContainerView in self.iconViews) {
        iconContainerView.hidden = NO;
        [iconContainerView removeFromSuperview];
    }
}

- (void)layoutIconViews {
    
    CGFloat availableWidth = self.bounds.size.width - kContentInsets.left - kContentInsets.right;
    
    // Figure out the required width to occupy based on hidden property of container.
    CGFloat requiredWidth = 0.0;
    for (UIView *iconContainerView in self.iconViews) {
        if (!iconContainerView.hidden) {
            requiredWidth += iconContainerView.frame.size.width;
        }
    }
    
    // Lay them out.
    CGFloat xOffset = kContentInsets.left + floorf((availableWidth - requiredWidth) / 2.0);
    for (UIView *iconContainerView in self.iconViews) {
        if (!iconContainerView.hidden) {
            iconContainerView.frame = (CGRect){
                xOffset,
                kContentInsets.top,
                iconContainerView.frame.size.width,
                iconContainerView.frame.size.height
            };
            [self addSubview:iconContainerView];
            
            xOffset += iconContainerView.frame.size.width + kStatGap;
        }
    }
    
}

- (NSString *)prepCookTotalDisplayForPrepTime:(NSNumber *)prepTime cookTime:(NSNumber *)cookTime {
    NSString *totalDisplay = nil;
    NSInteger totalTimeInMinutes = 0;
    if (prepTime || cookTime) {
        totalTimeInMinutes = [prepTime integerValue] + [cookTime integerValue];
        if (totalTimeInMinutes >= [RecipeDetails maxPrepCookMinutes]) {
            totalDisplay = [NSString stringWithFormat:@"%@+", [[DateHelper sharedInstance] formattedDurationDisplayForMinutes:[RecipeDetails maxPrepCookMinutes]]];
        } else {
            totalDisplay = [[DateHelper sharedInstance] formattedDurationDisplayForMinutes:totalTimeInMinutes];
        }
    }
    return totalDisplay;
}

- (NSString *)servesDisplayForPrepTime:(NSNumber *)serves {
    NSString *servesDisplay = [NSString CK_stringOrNilForNumber:serves];
    if (serves && [serves integerValue] > [RecipeDetails maxServes]) {
        servesDisplay = [NSString stringWithFormat:@"%ld+", [RecipeDetails maxServes]];
    }
    return servesDisplay;
}

- (NSString *)makesDisplayForPrepTime:(NSNumber *)makes {
    NSString *makesDisplay = [NSString CK_stringOrNilForNumber:makes];
    if (makes && [makes integerValue] > [RecipeDetails maxMakes]) {
        makesDisplay = [NSString stringWithFormat:@"%li+", (long)[RecipeDetails maxMakes]];
    }
    return makesDisplay;
}

- (UIImage *)likesIcon {
    return [CKBookCover likeImageForCover:self.recipe.book.cover selected:(self.recipe.numLikes > 0)];
}

@end
