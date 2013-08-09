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
#import "NSString+Utilities.h"
#import "Theme.h"

@interface RecipeDetailsView ()

@property (nonatomic, strong) CKRecipe *recipe;

@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *tagsView;
@property (nonatomic, strong) UIView *storyDividerView;
@property (nonatomic, strong) UIView *contentDividerView;
@property (nonatomic, strong) UILabel *storyLabel;

// Layout
@property (nonatomic, assign) CGPoint layoutOffset;

@end

@implementation RecipeDetailsView

#define kWidth              756.0
#define kMaxTitleWidth      756.0
#define kMaxStoryWidth      600.0
#define kDividerWidth       568.0
#define kContentInsets      (UIEdgeInsets){ 35.0, 0.0, 35.0, 0.0 }

- (id)initWithRecipe:(CKRecipe *)recipe {
    if (self = [super initWithFrame:CGRectZero]) {
        self.recipe = recipe;
        self.backgroundColor = [UIColor clearColor];
        
        // Pre-layout updates.
        [self updateFrame];
        
        [self updateComponents];
        
        // Post-layout updates.
        [self updateFrame];
    }
    return self;
}

#pragma mark - Properties

- (UIView *)storyDividerView {
    if (!_storyDividerView) {
        CGFloat dividerViewWidth = kDividerWidth;
        UIImage *quoteImage = [UIImage imageNamed:@"cook_book_recipe_icon_quote.png"];
        UIImage *dividerImage = [UIImage imageNamed:@"cook_book_recipe_divider_tile.png"];
        
        _storyDividerView = [[UIView alloc] initWithFrame:(CGRect){
            0.0,
            0.0,
            dividerViewWidth,
            quoteImage.size.height
        }];
        
        // Quote is in the middle.
        UIImageView *quoteView = [[UIImageView alloc] initWithImage:quoteImage];
        quoteView.frame = (CGRect){
            floorf((_storyDividerView.bounds.size.width - quoteView.frame.size.width) / 2.0),
            _storyDividerView.bounds.origin.y,
            quoteView.frame.size.width,
            quoteView.frame.size.height
        };
        [_storyDividerView addSubview:quoteView];
        
        // Left/right dividers.
        UIImageView *leftDividerView = [[UIImageView alloc] initWithImage:dividerImage];
        leftDividerView.frame = (CGRect){
            _storyDividerView.bounds.origin.x,
            floorf((_storyDividerView.bounds.size.height - leftDividerView.frame.size.height) / 2.0),
            quoteView.frame.origin.x,
            leftDividerView.frame.size.height
        };
        UIImageView *rightDividerView = [[UIImageView alloc] initWithImage:dividerImage];
        rightDividerView.frame = (CGRect){
            quoteView.frame.origin.x + quoteView.frame.size.width,
            floorf((_storyDividerView.bounds.size.height - rightDividerView.frame.size.height) / 2.0),
            _storyDividerView.bounds.size.width - quoteView.frame.origin.x + quoteView.frame.size.width,
            rightDividerView.frame.size.height
        };
        
        [_storyDividerView addSubview:leftDividerView];
        [_storyDividerView addSubview:rightDividerView];
    }
    return _storyDividerView;
}

- (UIView *)contentDividerView {
    if (!_contentDividerView) {
        _contentDividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_divider_tile.png"]];
        _contentDividerView.frame = (CGRect){
            0.0,
            0.0,
            kDividerWidth,
            _contentDividerView.frame.size.height
        };
    }
    return _contentDividerView;
}

#pragma mark - Private methods

- (void)updateComponents {
    
    // Init the offset to layout from the top.
    self.layoutOffset = (CGPoint){ kContentInsets.left, kContentInsets.top };
    
    [self updateProfilePhoto];
    [self updateTitle];
    [self updateTags];
    [self updateStory];
}

- (void)updateProfilePhoto {
    if (!self.profilePhotoView) {
        CKUserProfilePhotoView *profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.recipe.user profileSize:ProfileViewSizeSmall];
        profilePhotoView.frame = (CGRect){
            self.layoutOffset.x + floor(([self availableSize].width - profilePhotoView.frame.size.width) / 2.0),
            self.bounds.origin.y + self.layoutOffset.y,
            profilePhotoView.frame.size.width,
            profilePhotoView.frame.size.height
        };
        [self addSubview:profilePhotoView];
        self.profilePhotoView = profilePhotoView;
        
        // Update layout offset.
        [self updateLayoutOffsetVertical:profilePhotoView.frame.size.height];
    }
}

- (void)updateTitle {
    if (!self.titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [Theme recipeNameFont];
        titleLabel.textColor = [Theme recipeNameColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.hidden = YES;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    
    // Do we have a title to display.
    if (![self.recipe.name CK_blank]) {
        self.titleLabel.hidden = NO;
        self.titleLabel.text = [[self.recipe.name CK_whitespaceTrimmed] uppercaseString];
        CGSize size = [self.titleLabel sizeThatFits:(CGSize){ kMaxTitleWidth, MAXFLOAT }];
        self.titleLabel.frame = (CGRect){
            floorf((self.bounds.size.width - size.width) / 2.0),
            self.layoutOffset.y,
            size.width,
            size.height
        };
        
        // Update layout offset.
        [self updateLayoutOffsetVertical:size.height];
    }
    
}

- (void)updateTags {
    if (!self.tagsView) {
        UIView *tagsView = [[UIView alloc] initWithFrame:CGRectZero];
        tagsView.hidden = YES;
        [self addSubview:tagsView];
        self.tagsView = tagsView;
    }
    
    // Do we have any tags to display.
    if ([self.recipe.tags count] > 0) {
        
        // TODO adjust frame
        
        self.tagsView.hidden = NO;
    }
}

- (void)updateStory {
    if (!self.storyLabel) {
        
        // Top quote divider.
        self.storyDividerView = [self createQuoteDividerView];
        self.storyDividerView.hidden = YES;
        [self addSubview:self.storyDividerView];
        
        self.storyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.storyLabel.font = [Theme storyFont];
        self.storyLabel.textColor = [Theme storyColor];
        self.storyLabel.numberOfLines = 0;
        self.storyLabel.textAlignment = NSTextAlignmentJustified;
        self.storyLabel.backgroundColor = [UIColor clearColor];
        self.storyLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.storyLabel.shadowColor = [UIColor whiteColor];
        self.storyLabel.userInteractionEnabled = NO;
        self.storyLabel.hidden = YES;
        [self addSubview:self.storyLabel];
    }
    
    // Do we have a story to display.
    if (![self.recipe.story CK_blank]) {
        self.storyDividerView.hidden = NO;
        self.storyLabel.hidden = NO;
        
        CGFloat dividerStoryGap = 5.0;
        
        self.storyDividerView.frame = (CGRect){
            floorf((self.bounds.size.width - self.storyDividerView.frame.size.width) / 2.0),
            self.layoutOffset.y,
            self.storyDividerView.frame.size.width,
            self.storyDividerView.frame.size.height
        };
        
        self.storyLabel.text = self.recipe.story;
        CGSize size = [self.storyLabel sizeThatFits:(CGSize){ kMaxStoryWidth, MAXFLOAT }];
        self.storyLabel.frame = (CGRect){
            floorf((self.bounds.size.width - size.width) / 2.0),
            self.storyDividerView.frame.origin.y + self.storyDividerView.frame.size.height + dividerStoryGap,
            size.width,
            size.height
        };
        
        [self updateLayoutOffsetVertical:self.storyDividerView.frame.size.height + dividerStoryGap + size.height];
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
    CGFloat dividerViewWidth = kDividerWidth;
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

- (void)updateLayoutOffsetHorizontal:(CGFloat)horizontal {
    [self updateLayoutOffsetHorizontal:horizontal vertical:0.0];
}

- (void)updateLayoutOffsetVertical:(CGFloat)vertical {
    [self updateLayoutOffsetHorizontal:0.0 vertical:vertical];
}

- (void)updateLayoutOffsetHorizontal:(CGFloat)horizontal vertical:(CGFloat)vertical {
    CGPoint currentOffset = self.layoutOffset;
    currentOffset.x += horizontal;
    currentOffset.y += vertical;
    self.layoutOffset = currentOffset;
}

@end
