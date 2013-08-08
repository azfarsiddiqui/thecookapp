//
//  RecipeDetailsView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeDetailsView.h"
#import "CKRecipe.h"
#import "CKUserProfilePhotoView.h"
#import "Theme.h"

@interface RecipeDetailsView ()

@property (nonatomic, strong) CKRecipe *recipe;

@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *preStoryDividerView;
@property (nonatomic, strong) UIView *preMethodDividerView;
@property (nonatomic, strong) UILabel *storyLabel;

@end

@implementation RecipeDetailsView

#define kWidth              756.0
#define kMaxTitleWidth      756.0
#define kMaxStoryWidth      600.0
#define kQuoteDividerWidth  568.0
#define kContentInsets      (UIEdgeInsets){ 35.0, 0.0, 35.0, 0.0 }

- (id)initWithRecipe:(CKRecipe *)recipe {
    if (self = [super initWithFrame:CGRectZero]) {
        self.recipe = recipe;
        
        // Pre-layout updates.
        [self updateFrame];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self initProfilePhotoView];
        [self initTitleView];
        [self initStoryView];
        
        // Post-layout updates.
        [self updateFrame];
    }
    return self;
}

#pragma mark - Properties

- (UIView *)preStoryDividerView {
    if (!_preStoryDividerView) {
        CGFloat dividerViewWidth = kQuoteDividerWidth;
        UIImage *quoteImage = [UIImage imageNamed:@"cook_book_recipe_icon_quote.png"];
        UIImage *dividerImage = [UIImage imageNamed:@"cook_book_recipe_divider_tile.png"];
        
        _preStoryDividerView = [[UIView alloc] initWithFrame:(CGRect){
            0.0,
            0.0,
            dividerViewWidth,
            quoteImage.size.height
        }];
        
        // Quote is in the middle.
        UIImageView *quoteView = [[UIImageView alloc] initWithImage:quoteImage];
        quoteView.frame = (CGRect){
            floorf((_preStoryDividerView.bounds.size.width - quoteView.frame.size.width) / 2.0),
            _preStoryDividerView.bounds.origin.y,
            quoteView.frame.size.width,
            quoteView.frame.size.height
        };
        [_preStoryDividerView addSubview:quoteView];
        
        // Left/right dividers.
        UIImageView *leftDividerView = [[UIImageView alloc] initWithImage:dividerImage];
        leftDividerView.frame = (CGRect){
            _preStoryDividerView.bounds.origin.x,
            floorf((_preStoryDividerView.bounds.size.height - leftDividerView.frame.size.height) / 2.0),
            quoteView.frame.origin.x,
            leftDividerView.frame.size.height
        };
        UIImageView *rightDividerView = [[UIImageView alloc] initWithImage:dividerImage];
        rightDividerView.frame = (CGRect){
            quoteView.frame.origin.x + quoteView.frame.size.width,
            floorf((_preStoryDividerView.bounds.size.height - rightDividerView.frame.size.height) / 2.0),
            _preStoryDividerView.bounds.size.width - quoteView.frame.origin.x + quoteView.frame.size.width,
            rightDividerView.frame.size.height
        };
        
        [_preStoryDividerView addSubview:leftDividerView];
        [_preStoryDividerView addSubview:rightDividerView];
    }
    return _preStoryDividerView;
}

#pragma mark - Private methods

- (void)initProfilePhotoView {
    CKUserProfilePhotoView *profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.recipe.user profileSize:ProfileViewSizeSmall];
    profilePhotoView.frame = (CGRect){
        kContentInsets.left + floor(([self availableSize].width - profilePhotoView.frame.size.width) / 2.0),
        self.bounds.origin.y + kContentInsets.top,
        profilePhotoView.frame.size.width,
        profilePhotoView.frame.size.height
    };
    [self addSubview:profilePhotoView];
    self.profilePhotoView = profilePhotoView;
}

- (void)initTitleView {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [Theme recipeNameFont];
    titleLabel.textColor = [Theme recipeNameColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    titleLabel.shadowColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [self setTitle:self.recipe.name];
}

- (void)initStoryView {
    UILabel *storyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    storyLabel.font = [Theme storyFont];
    storyLabel.textColor = [Theme storyColor];
    storyLabel.numberOfLines = 0;
    storyLabel.textAlignment = NSTextAlignmentJustified;
    storyLabel.backgroundColor = [UIColor clearColor];
    storyLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    storyLabel.shadowColor = [UIColor whiteColor];
    storyLabel.userInteractionEnabled = NO;
    [self addSubview:storyLabel];
    self.storyLabel = storyLabel;
    [self setStory:self.recipe.story];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = [title uppercaseString];
    CGSize size = [self.titleLabel sizeThatFits:(CGSize){ kMaxTitleWidth, MAXFLOAT }];
    self.titleLabel.frame = (CGRect){
        floorf((self.bounds.size.width - size.width) / 2.0),
        self.profilePhotoView.frame.origin.y + self.profilePhotoView.frame.size.height,
        size.width,
        size.height
    };
}

- (void)setStory:(NSString *)story {
    CGFloat titleDividerGap = 0.0;
    CGFloat dividerStoryGap = 5.0;
    self.storyLabel.text = story;
    
    if ([story length] > 0) {
        self.preStoryDividerView = [self createQuoteDividerView];
        self.preStoryDividerView.frame = (CGRect){
            floorf((self.bounds.size.width - self.preStoryDividerView.frame.size.width) / 2.0),
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + titleDividerGap,
            self.preStoryDividerView.frame.size.width,
            self.preStoryDividerView.frame.size.height
        };
        [self addSubview:self.preStoryDividerView];
        
        self.storyLabel.hidden = NO;
        CGSize size = [self.storyLabel sizeThatFits:(CGSize){ kMaxStoryWidth, MAXFLOAT }];
        self.storyLabel.frame = (CGRect){
            floorf((self.bounds.size.width - size.width) / 2.0),
            self.preStoryDividerView.frame.origin.y + self.preStoryDividerView.frame.size.height + dividerStoryGap,
            size.width,
            size.height
        };
        
    } else {
        
        [self.preStoryDividerView removeFromSuperview];
        self.storyLabel.hidden = YES;
    }
}

- (void)updateFrame {
    CGRect frame = (CGRect){ 0.0, 0.0, kWidth, 0.0 };;
    for (UIView *subview in self.subviews) {
        frame = (CGRectUnion(frame, subview.frame));
    }
    self.frame = frame;
}

- (CGRect)unionFrameForView:(UIView *)view {
    CGRect frame = CGRectZero;
    for (UIView *subview in self.subviews) {
        frame = (CGRectUnion(frame, subview.frame));
    }
    return frame;
}

- (CGSize)availableSize {
    return (CGSize){ kWidth - kContentInsets.left - kContentInsets.right, MAXFLOAT };
}

- (UIView *)createQuoteDividerView {
    CGFloat dividerViewWidth = kQuoteDividerWidth;
    UIImage *quoteImage = [UIImage imageNamed:@"cook_book_recipe_icon_quote.png"];
    UIImage *dividerImage = [UIImage imageNamed:@"cook_book_recipe_divider_tile.png"];
    
    UIView *preStoryDividerView = [[UIView alloc] initWithFrame:(CGRect){
        0.0,
        0.0,
        dividerViewWidth,
        quoteImage.size.height
    }];
    preStoryDividerView.backgroundColor = [UIColor clearColor];
    
    // Quote is in the middle.
    UIImageView *quoteView = [[UIImageView alloc] initWithImage:quoteImage];
    quoteView.frame = (CGRect){
        floorf((preStoryDividerView.bounds.size.width - quoteView.frame.size.width) / 2.0),
        preStoryDividerView.bounds.origin.y,
        quoteView.frame.size.width,
        quoteView.frame.size.height
    };
    [preStoryDividerView addSubview:quoteView];
    
    // Left/right dividers.
    UIImageView *leftDividerView = [[UIImageView alloc] initWithImage:dividerImage];
    leftDividerView.frame = (CGRect){
        preStoryDividerView.bounds.origin.x,
        floorf((preStoryDividerView.bounds.size.height - leftDividerView.frame.size.height) / 2.0),
        quoteView.frame.origin.x,
        leftDividerView.frame.size.height
    };
    UIImageView *rightDividerView = [[UIImageView alloc] initWithImage:dividerImage];
    rightDividerView.frame = (CGRect){
        quoteView.frame.origin.x + quoteView.frame.size.width,
        floorf((preStoryDividerView.bounds.size.height - rightDividerView.frame.size.height) / 2.0),
        preStoryDividerView.bounds.size.width - quoteView.frame.origin.x - quoteView.frame.size.width,
        rightDividerView.frame.size.height
    };
    
    [preStoryDividerView addSubview:leftDividerView];
    [preStoryDividerView addSubview:rightDividerView];
    return preStoryDividerView;
}

@end
