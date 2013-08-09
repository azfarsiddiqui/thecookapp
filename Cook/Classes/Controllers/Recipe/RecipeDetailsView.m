//
//  RecipeDetailsView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeDetailsView.h"
#import "RecipeDetails.h"
#import "CKUserProfilePhotoView.h"
#import "NSString+Utilities.h"
#import "Theme.h"
#import "RecipeServesCookView.h"
#import "RecipeIngredientsView.h"
#import "CKEditingViewHelper.h"

@interface RecipeDetailsView () <CKEditingTextBoxViewDelegate>

@property (nonatomic, strong) RecipeDetails *recipeDetails;

@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *tagsView;
@property (nonatomic, strong) UIView *storyDividerView;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) UIView *contentDividerView;
@property (nonatomic, strong) RecipeServesCookView *servesCookView;
@property (nonatomic, strong) UIView *ingredientsDividerView;
@property (nonatomic, strong) RecipeIngredientsView *ingredientsView;
@property (nonatomic, strong) UILabel *methodLabel;

// Layout
@property (nonatomic, assign) CGPoint layoutOffset;
@property (nonatomic, assign) CGPoint contentOffset;

// Editing.
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;


@end

@implementation RecipeDetailsView

#define kWidth                  756.0
#define kMaxTitleWidth          756.0
#define kMaxStoryWidth          600.0
#define kMaxLeftWidth           222.0
#define kMaxRightWidth          465.0
#define kDividerWidth           568.0
#define kIngredientDividerWidth 170.0
#define kContentInsets          (UIEdgeInsets){ 35.0, 0.0, 35.0, 0.0 }

- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.recipeDetails = recipeDetails;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        
        self.backgroundColor = [UIColor clearColor];
        
        // Pre-layout updates.
        [self updateFrame];
        
        [self updateComponents];
        
        // Post-layout updates.
        [self updateFrame];
    }
    return self;
}

- (void)enableEditMode:(BOOL)editMode {
    
    // Fade out the divider lines.
    self.storyDividerView.alpha = editMode ? 0.0 : 1.0;
    self.contentDividerView.alpha = editMode ? 0.0 : 1.0;
    self.ingredientsDividerView.alpha = editMode ? 0.0 : 1.0;
    
    [self enableEditModeOnView:self.titleLabel editMode:editMode
                 minimumInsets:(UIEdgeInsets){ 8.0, 20.0, 2.0, 20.0 }
               toDisplayAsSize:(CGSize){ kMaxTitleWidth, 0.0 }];
    [self enableEditModeOnView:self.storyLabel editMode:editMode
                 minimumInsets:(UIEdgeInsets){ 30.0, 20.0, 30.0, 20.0 }
               toDisplayAsSize:(CGSize){ kWidth, 0.0 }];
    [self enableEditModeOnView:self.servesCookView editMode:editMode
                 minimumInsets:(UIEdgeInsets){ 30.0, 10.0, 15.0, 30.0 }
               toDisplayAsSize:(CGSize){ 0.0, 0.0 }];
    
    // Set fields to be editable/non
    if (editMode) {
        [self.editingHelper wrapEditingView:self.servesCookView
                              contentInsets:UIEdgeInsetsMake(20.0, 30.0, 10.0, 30.0)
                                   delegate:self white:YES];
        [self.editingHelper wrapEditingView:self.ingredientsView
                              contentInsets:UIEdgeInsetsMake(20.0, 30.0, 10.0, 30.0)
                                   delegate:self white:YES];
        [self.editingHelper wrapEditingView:self.methodLabel
                              contentInsets:UIEdgeInsetsMake(25.0, 30.0, 2.0, 20.0)
                                   delegate:self white:YES];
    } else {
        [self.editingHelper unwrapEditingView:self.servesCookView];
        [self.editingHelper unwrapEditingView:self.ingredientsView];
        [self.editingHelper unwrapEditingView:self.methodLabel];
    }
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
//    if (editingView == self.photoLabel) {
//        
//        [self snapContentToPhotoWindowHeight:PhotoWindowHeightFullScreen bounce:NO completion:^{
//            [self showPhotoPicker:YES];
//        }];
//        
//    } else if (editingView == self.titleLabel) {
//        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
//                                                                                                           delegate:self
//                                                                                                      editingHelper:self.editingHelper
//                                                                                                              white:YES
//                                                                                                              title:@"Name"
//                                                                                                     characterLimit:30];
//        editViewController.forceUppercase = YES;
//        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
//        [editViewController performEditing:YES];
//        self.editViewController = editViewController;
//        
//    } else if (editingView == self.categoryLabel) {
//        
//        PageListEditViewController *editViewController = [[PageListEditViewController alloc] initWithEditView:self.categoryLabel
//                                                                                                       recipe:self.recipe
//                                                                                                     delegate:self
//                                                                                                editingHelper:self.editingHelper
//                                                                                                        white:YES];
//        editViewController.canAddItems = NO;
//        editViewController.canDeleteItems = NO;
//        editViewController.canReorderItems = NO;
//        [editViewController performEditing:YES];
//        self.editViewController = editViewController;
//        
//    } else if (editingView == self.storyLabel) {
//        
//        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:editingView
//                                                                                                         delegate:self
//                                                                                                    editingHelper:self.editingHelper
//                                                                                                            white:YES
//                                                                                                            title:@"Story"
//                                                                                                   characterLimit:120];
//        ((CKTextViewEditViewController *)editViewController).numLines = 2;
//        editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
//        [editViewController performEditing:YES];
//        self.editViewController = editViewController;
//        
//    } else if (editingView == self.methodLabel) {
//        
//        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:self.methodLabel
//                                                                                                         delegate:self
//                                                                                                    editingHelper:self.editingHelper
//                                                                                                            white:YES
//                                                                                                            title:@"Method"];
//        editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
//        [editViewController performEditing:YES];
//        self.editViewController = editViewController;
//        
//    } else if (editingView == self.servesCookView) {
//        
//        ServesAndTimeEditViewController *editViewController = [[ServesAndTimeEditViewController alloc] initWithEditView:editingView
//                                                                                                        recipeClipboard:self.clipboard
//                                                                                                               delegate:self
//                                                                                                          editingHelper:self.editingHelper
//                                                                                                                  white:YES];
//        [editViewController performEditing:YES];
//        self.editViewController = editViewController;
//        
//    } else if (editingView == self.ingredientsView) {
//        
//        IngredientListEditViewController *editViewController = [[IngredientListEditViewController alloc] initWithEditView:editingView delegate:self items:self.clipboard.ingredients editingHelper:self.editingHelper white:YES title:@"Ingredients"];
//        editViewController.canAddItems = YES;
//        editViewController.canDeleteItems = YES;
//        editViewController.canReorderItems = YES;
//        editViewController.allowSelection = NO;
//        [editViewController performEditing:YES];
//        self.editViewController = editViewController;
//    }
}

#pragma mark - Private methods

- (void)updateComponents {
    
    // Init the offset to layout from the top.
    self.layoutOffset = (CGPoint){ kContentInsets.left, kContentInsets.top };
    
    [self updateProfilePhoto];
    [self updateTitle];
    [self updateTags];
    [self updateStory];
    [self updateContentDivider];
    [self updateServesCook];
    [self updateIngredients];
    [self updateMethod];
}

- (void)updateProfilePhoto {
    if (!self.profilePhotoView) {
        CKUserProfilePhotoView *profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.recipeDetails.user
                                                                                    profileSize:ProfileViewSizeSmall];
        profilePhotoView.frame = (CGRect){
            self.layoutOffset.x + floor(([self availableSize].width - profilePhotoView.frame.size.width) / 2.0),
            self.bounds.origin.y + self.layoutOffset.y,
            profilePhotoView.frame.size.width,
            profilePhotoView.frame.size.height
        };
        [self addSubview:profilePhotoView];
        self.profilePhotoView = profilePhotoView;
    }
    
    // Update layout offset.
    [self updateLayoutOffsetVertical:self.profilePhotoView.frame.size.height];
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
    if (![self.recipeDetails.name CK_blank]) {
        self.titleLabel.hidden = NO;
        self.titleLabel.text = [[self.recipeDetails.name CK_whitespaceTrimmed] uppercaseString];
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
    if ([self.recipeDetails.tags count] > 0) {
        
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
    if (![self.recipeDetails.story CK_blank]) {
        self.storyDividerView.hidden = NO;
        self.storyLabel.hidden = NO;
        
        CGFloat dividerStoryGap = 5.0;
        
        self.storyDividerView.frame = (CGRect){
            floorf((self.bounds.size.width - self.storyDividerView.frame.size.width) / 2.0),
            self.layoutOffset.y,
            self.storyDividerView.frame.size.width,
            self.storyDividerView.frame.size.height
        };
        
        self.storyLabel.text = self.recipeDetails.story;
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

- (void)updateContentDivider {
    if (!self.contentDividerView) {
        self.contentDividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_divider_tile.png"]];
        [self addSubview:self.contentDividerView];
    }
    
    CGFloat dividerGap = 30.0;
    
    self.contentDividerView.frame = (CGRect){
        floorf((self.bounds.size.width - kWidth) / 2.0),    // use kDividerWidth
        self.layoutOffset.y + dividerGap,
        kWidth,                                             // use kDividerWidth
        self.contentDividerView.frame.size.height
    };
    
    [self updateLayoutOffsetVertical:dividerGap + self.contentDividerView.frame.size.height + dividerGap];
    
    // Mark this as the offset for content start, so that left/right columns can reference.
    self.contentOffset = self.layoutOffset;
}

- (void)updateServesCook {
    if (!self.servesCookView) {
        self.servesCookView = [[RecipeServesCookView alloc] initWithRecipeDetails:self.recipeDetails];
        self.servesCookView.hidden = YES;
        [self addSubview:self.servesCookView];
    }
    
    CGFloat beforeGap = 0.0;
    
    if (self.recipeDetails.numServes >= 0 || self.recipeDetails.prepTimeInMinutes >= 0 || self.recipeDetails.cookingTimeInMinutes >= 0) {
        self.servesCookView.hidden = NO;
        self.servesCookView.frame = (CGRect){
            kContentInsets.left,
            self.contentOffset.y + beforeGap,
            self.servesCookView.frame.size.width,
            self.servesCookView.frame.size.height
        };
        [self updateLayoutOffsetVertical:beforeGap + self.servesCookView.frame.size.height];
    }
    
}

- (void)updateIngredients {
    if ([self.recipeDetails.ingredients count] > 0) {
        if (!self.ingredientsView) {
            
            self.ingredientsDividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_divider_tile.png"]];
            [self addSubview:self.ingredientsDividerView];
            
            self.ingredientsView = [[RecipeIngredientsView alloc] initWithRecipeDetails:self.recipeDetails maxWidth:kMaxLeftWidth];
            [self addSubview:self.ingredientsView];
        }
        
        CGFloat dividerGap = 10.0;
        self.ingredientsDividerView.frame = (CGRect){
            kContentInsets.left,
            self.layoutOffset.y + dividerGap,
            kMaxLeftWidth,
            self.ingredientsDividerView.frame.size.height
        };
        
        CGFloat beforeIngredientsGap = 10.0;
        self.ingredientsView.frame = (CGRect){
            kContentInsets.left,
            self.layoutOffset.y + dividerGap + self.ingredientsDividerView.frame.size.height + dividerGap + beforeIngredientsGap,
            self.ingredientsView.frame.size.width,
            self.ingredientsView.frame.size.height
        };
        
        [self updateLayoutOffsetVertical:dividerGap + self.ingredientsDividerView.frame.size.height + dividerGap + beforeIngredientsGap + self.ingredientsDividerView.frame.size.height];
    }
    
}

- (void)updateMethod {
    if (!self.methodLabel) {
        self.methodLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.methodLabel.numberOfLines = 0;
        self.methodLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.methodLabel.textAlignment = NSTextAlignmentLeft;
        self.methodLabel.backgroundColor = [UIColor clearColor];
        self.methodLabel.userInteractionEnabled = NO;
        self.methodLabel.hidden = YES;
        [self addSubview:self.methodLabel];
    }
    
    // Do we have a story to display.
    if (![self.recipeDetails.method CK_blank]) {
        self.methodLabel.hidden = NO;
        NSAttributedString *method = [self attributedTextForText:self.recipeDetails.method font:[Theme methodFont] colour:[Theme methodColor]];
        self.methodLabel.attributedText = method;
        CGSize size = [self.methodLabel sizeThatFits:(CGSize){ kMaxRightWidth, MAXFLOAT }];
        self.methodLabel.frame = (CGRect){
            self.bounds.size.width - kMaxRightWidth,
            self.contentOffset.y,
            size.width,
            size.height
        };
    }
    
}

- (void)updateFrame {
    CGRect frame = (CGRect){ 0.0, 0.0, kWidth, 0.0 };;
    for (UIView *subview in self.subviews) {
        frame = (CGRectUnion(frame, subview.frame));
        frame.size.height += kContentInsets.bottom;
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

- (NSMutableAttributedString *)attributedTextForText:(NSString *)text font:(UIFont *)font colour:(UIColor *)colour {
    return [self attributedTextForText:text lineSpacing:10.0 font:font colour:colour];
}

- (NSMutableAttributedString *)attributedTextForText:(NSString *)text lineSpacing:(CGFloat)lineSpacing
                                                font:(UIFont *)font colour:(UIColor *)colour {
    text = [text length] > 0 ? text : @"";
    NSDictionary *paragraphAttributes = [self paragraphAttributesForFont:font lineSpacing:lineSpacing colour:colour];
    return [[NSMutableAttributedString alloc] initWithString:text attributes:paragraphAttributes];
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing colour:(UIColor *)colour {
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            colour, NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}

- (void)enableEditModeOnView:(UIView *)view editMode:(BOOL)editMode minimumInsets:(UIEdgeInsets)minimumInsets {
    [self enableEditModeOnView:view editMode:editMode minimumInsets:minimumInsets toDisplayAsSize:CGSizeZero];
}

- (void)enableEditModeOnView:(UIView *)view editMode:(BOOL)editMode minimumInsets:(UIEdgeInsets)minimumInsets
             toDisplayAsSize:(CGSize)size {
    
    if (editMode) {
        [self.editingHelper wrapEditingView:view contentInsets:minimumInsets delegate:self white:YES];
        
        // Get the resulting textBoxView to stretch to the displayed size.
        CKEditingTextBoxView *textBoxView = [self.editingHelper textBoxViewForEditingView:view];
        CGRect frame = textBoxView.frame;
        
        // Do we need to display to a minimum size.
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            
            // Check horizontal padding.
            if (size.width > 0.0) {
                
                // Figure out the appropriate proportions to pad on left/right.
                CGFloat totalInsets = textBoxView.contentInsets.left + textBoxView.contentInsets.right;
                CGFloat leftInsetsRatio = textBoxView.contentInsets.left / totalInsets;
                
                // Effective width of the required width + the textbox insets around it.
                CGFloat effectiveWidth = size.width + totalInsets;
                frame.size.width = effectiveWidth;
                
                // Extra width to pad horizontally.
                CGFloat extraWidth = effectiveWidth - view.frame.size.width;
                frame.origin.x -= floorf(extraWidth * leftInsetsRatio);
                
            }
            
            // Check vertical padding.
            if (size.height > 0.0) {
                
                frame.size.height = size.height;
            }
            textBoxView.frame = frame;
        }
        
    } else {
        [self.editingHelper unwrapEditingView:view];
    }
}

- (UIEdgeInsets)editInsetsForEditingView:(UIView *)editingView minimumInsets:(UIEdgeInsets)minimumInsets
                         toDisplayAsSize:(CGSize)size {
    
    UIEdgeInsets editInsets = UIEdgeInsetsZero;
    
    return editInsets;
}

@end
