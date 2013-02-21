//
//  RecipeCollectionViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookRecipeCollectionViewCell.h"
#import "CKRecipe.h"
#import "Theme.h"
#import "UIImage+ProportionalFill.h"
#import "MRCEnumerable.h"
#import "Ingredient.h"
#import "GridRecipeStatsView.h"
#import "ImageHelper.h"

@interface BookRecipeCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *ingredientsLabel;
@property (nonatomic, strong) UILabel *ingredientsEllipsisLabel;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) GridRecipeStatsView *statsView;

@end

@implementation BookRecipeCollectionViewCell

#define kViewDebug              0
#define kImageHeight            140.0
#define kTitleOffsetNoImage     70.0
#define kTitleTopGap            20.0
#define kStatsViewTopOffset     30.0
#define kStoryTopOffset         30.0
#define kTextSideOffset         10.0

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // Top thumbnail.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, kImageHeight);
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        // Recipe title that spans 2 lines.
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [self backgroundColorOrDebug];
        titleLabel.font = [Theme recipeGridTitleFont];
        titleLabel.textColor = [Theme recipeGridTitleColour];
        titleLabel.numberOfLines = 2;
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
        CGSize size = [ellipsis sizeWithFont:[Theme recipeGridIngredientsFont]
                           constrainedToSize:self.contentView.bounds.size
                               lineBreakMode:NSLineBreakByClipping];
        UILabel *ingredientsEllipsisLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextSideOffset,
                                                                                      self.ingredientsLabel.frame.size.height,
                                                                                      size.width,
                                                                                      size.height)];
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
        [self.contentView addSubview:storyLabel];
        self.storyLabel = storyLabel;
        
        // Bottom stats view.
        GridRecipeStatsView *statsView = [[GridRecipeStatsView alloc] init];
        statsView.frame = CGRectMake((self.contentView.bounds.size.width - statsView.frame.size.width) / 2.0,
                                     self.contentView.bounds.size.height - statsView.frame.size.height,
                                     statsView.frame.size.width,
                                     statsView.frame.size.height);
        [self.contentView addSubview:statsView];
        self.statsView = statsView;
        
    }
    return self;
}

- (void)configureRecipe:(CKRecipe *)recipe {
    self.recipe = recipe;
    
    [self updateTitle];
    [self updateStory];
    [self updateIngredients];
    [self updateStats];
}

- (void)configureImage:(UIImage *)image {
    [ImageHelper configureImageView:self.imageView image:image];
}

- (CGSize)imageSize {
    return self.imageView.frame.size;
}

#pragma mark - Private methods

- (void)updateTitle {
    NSString *title = [self.recipe.name uppercaseString];
    CGRect frame = self.titleLabel.frame;
    CGSize size = [title sizeWithFont:self.titleLabel.font
                    constrainedToSize:CGSizeMake(self.contentView.bounds.size.width - (kTextSideOffset * 2), self.contentView.bounds.size.height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    if ([self.recipe hasPhotos]) {
        
        // Always a fixed-offset from bottom of image.
        frame.origin = CGPointMake(kTextSideOffset, self.imageView.frame.origin.y + self.imageView.frame.size.height + kTitleTopGap);
        
    } else {
        
        // Always a fixed-offset from top for recipes with no image.
        frame.origin = CGPointMake(kTextSideOffset, kTitleOffsetNoImage);
    }
    frame.size = CGSizeMake(size.width, size.height);
    self.titleLabel.frame = frame;
    self.titleLabel.text = title;
}

- (void)updateStory {
    NSString *story = [NSString stringWithFormat:@"‟ %@ ”", self.recipe.story];
    CGSize size = [story sizeWithFont:self.storyLabel.font
                    constrainedToSize:CGSizeMake(self.contentView.bounds.size.width - (kTextSideOffset * 2), self.contentView.bounds.size.height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    self.storyLabel.frame = CGRectMake(kTextSideOffset, self.statsView.frame.origin.y - kStatsViewTopOffset - size.height, size.width, size.height);
    self.storyLabel.text = story;
}

- (void)updateIngredients {
    if ([[self.recipe ingredients] count] > 0) {
        self.ingredientsLabel.hidden = NO;
        
        // Extract ingredients into line wrapped text.
        NSMutableArray *ingredients = [NSMutableArray arrayWithArray:[[self.recipe ingredients] collect:^id(Ingredient *ingredient) {
            return ingredient.name;
        }]];
        NSString *ingredientsDisplay = [ingredients componentsJoinedByString:@"\n"];
        
        // Now figure out positioning based on story.
        CGFloat titleBottomOffset = [self titleBottomOffset];
        CGSize availableSize = CGSizeMake(self.contentView.bounds.size.width - (kTextSideOffset * 2),
                                          self.storyLabel.frame.origin.y - kStoryTopOffset - self.titleLabel.frame.origin.y - self.titleLabel.frame.size.height - titleBottomOffset);
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
        self.ingredientsLabel.frame = CGRectMake(kTextSideOffset,
                                                 self.titleLabel.frame.origin.y + 60.0,
                                                 size.width,
                                                 size.height);
        self.ingredientsLabel.text = ingredientsDisplay;
        
        // Prepare to update story frame.
        CGRect storyFrame = self.storyLabel.frame;
        storyFrame.origin.y = self.ingredientsLabel.frame.origin.y + self.ingredientsLabel.frame.size.height + kStoryTopOffset;
        
        // Do we need an ellipsis?
        if (!self.ingredientsEllipsisLabel.hidden) {
            self.ingredientsEllipsisLabel.frame = CGRectMake(self.ingredientsEllipsisLabel.frame.origin.x,
                                                             self.ingredientsLabel.frame.origin.y + self.ingredientsLabel.frame.size.height,
                                                             self.ingredientsEllipsisLabel.frame.size.width,
                                                             self.ingredientsEllipsisLabel.frame.size.height);
            storyFrame.origin.y = self.ingredientsEllipsisLabel.frame.origin.y + self.ingredientsEllipsisLabel.frame.size.height + kStoryTopOffset;
        }
        
        // Now adjust the story up so that it fits below ingredients with a gap.
        self.storyLabel.frame = storyFrame;
        
    } else {
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
    
    DLog(@"OFFSET %f", offset);
    return offset;
}

- (UIColor *)backgroundColorOrDebug {
    if (kViewDebug) {
        return [UIColor colorWithRed:0 green:255 blue:0 alpha:0.5];
    } else {
        return [UIColor clearColor];
    }
}

@end
