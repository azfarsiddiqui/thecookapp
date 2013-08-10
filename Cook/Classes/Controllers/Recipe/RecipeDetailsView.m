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
#import "CKTextFieldEditViewController.h"
#import "CKTextViewEditViewController.h"
#import "ServesAndTimeEditViewController.h"
#import "IngredientListEditViewController.h"
#import "PageListEditViewController.h"
#import "CKEditingTextBoxView.h"

typedef NS_ENUM(NSUInteger, EditPadDirection) {
    EditPadDirectionLeft,
    EditPadDirectionRight,
    EditPadDirectionLeftRight,
    EditPadDirectionTop,
    EditPadDirectionBottom,
    EditPadDirectionTopBottom
};

@interface RecipeDetailsView () <CKEditingTextBoxViewDelegate, CKEditViewControllerDelegate>

@property (nonatomic, weak) id<RecipeDetailsViewDelegate> delegate;
@property (nonatomic, strong) RecipeDetails *recipeDetails;

@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UILabel *pageLabel;
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
@property (nonatomic, strong) CKEditViewController *editViewController;
@property (nonatomic, strong) NSMutableArray *pageComponents;

@end

@implementation RecipeDetailsView

#define kWidth                  756.0
#define kMaxTitleWidth          756.0
#define kMaxStoryWidth          600.0
#define kMaxLeftWidth           222.0
#define kMaxRightWidth          465.0
#define kMaxMethodHeight        300.0
#define kDividerWidth           568.0
#define kIngredientDividerWidth 170.0
#define kContentInsets          (UIEdgeInsets){ 35.0, 0.0, 35.0, 0.0 }

- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails delegate:(id<RecipeDetailsViewDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.recipeDetails = recipeDetails;
        self.delegate = delegate;
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
    
    // Edit mode on fields.
    [self enableFieldsForEditMode:editMode];
    
    // Hide the pageLabel/textBox.
    CKEditingTextBoxView *pageTextBoxView = [self.editingHelper textBoxViewForEditingView:self.pageLabel];
    if (editMode) {
        self.pageLabel.hidden = NO;
        self.pageLabel.alpha = 0.0;
        pageTextBoxView.hidden = NO;
        pageTextBoxView.alpha = 0.0;
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         // Toggle between the profile photo and page label.
                         self.profilePhotoView.alpha = editMode ? 0.0 : 1.0;
                         self.pageLabel.alpha = editMode ? 1.0 : 0.0;
                         pageTextBoxView.alpha = editMode ? 1.0 : 0.0;
                         
                         // Fade the divider lines.
                         self.storyDividerView.alpha = editMode ? 0.0 : 1.0;
                         self.contentDividerView.alpha = editMode ? 0.0 : 1.0;
                         self.ingredientsDividerView.alpha = editMode ? 0.0 : 1.0;
                         
                     }
                     completion:^(BOOL finished)  {
                         
                         if (!editMode) {
                             self.pageLabel.hidden = YES;
                             pageTextBoxView.hidden = YES;
                         }
                    }];
    
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    if (editingView == self.titleLabel) {
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:YES
                                                                                                              title:@"Name"
                                                                                                     characterLimit:30];
        editViewController.forceUppercase = YES;
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.pageLabel) {
        
        PageListEditViewController *editViewController = [[PageListEditViewController alloc] initWithEditView:self.pageLabel
                                                                                                recipeDetails:self.recipeDetails
                                                                                                     delegate:self
                                                                                                editingHelper:self.editingHelper
                                                                                                        white:YES];
        editViewController.canAddItems = NO;
        editViewController.canDeleteItems = NO;
        editViewController.canReorderItems = NO;
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.storyLabel) {
        
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:editingView
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:@"Story"
                                                                                                   characterLimit:120];
        ((CKTextViewEditViewController *)editViewController).numLines = 2;
        editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.methodLabel) {
        
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:self.methodLabel
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:@"Method"];
        editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.servesCookView) {
        
        ServesAndTimeEditViewController *editViewController = [[ServesAndTimeEditViewController alloc] initWithEditView:editingView
                                                                                                          recipeDetails:self.recipeDetails
                                                                                                               delegate:self
                                                                                                          editingHelper:self.editingHelper
                                                                                                                  white:YES];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.ingredientsView) {
        
        IngredientListEditViewController *editViewController = [[IngredientListEditViewController alloc] initWithEditView:editingView
                                                                                                                 delegate:self
                                                                                                                    items:self.recipeDetails.ingredients
                                                                                                            editingHelper:self.editingHelper white:YES
                                                                                                                    title:@"Ingredients"];
        editViewController.canAddItems = YES;
        editViewController.canDeleteItems = YES;
        editViewController.canReorderItems = YES;
        editViewController.allowSelection = NO;
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
    }
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
    [self.delegate recipeDetailsViewEditing:appear];
}

- (void)editViewControllerDidAppear:(BOOL)appear {
    if (!appear) {
        [self.editViewController.view removeFromSuperview];
        self.editViewController = nil;
    }
}

- (void)editViewControllerDismissRequested {
    [self.editViewController performEditing:NO];
}

- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value {
    
    // Transfer updated values to the recipe details transfer object.
    if (editingView == self.titleLabel) {
    } else if (editingView == self.pageLabel) {
        self.recipeDetails.page = value;
    } else if (editingView == self.storyLabel) {
        self.recipeDetails.story = value;
    } else if (editingView == self.servesCookView) {
        // The Serves Cook View handles updating of it.
    } else if (editingView == self.methodLabel) {
        self.recipeDetails.method = value;
    } else if (editingView == self.ingredientsView) {
        self.recipeDetails.ingredients = value;
    }
    
    // Update onscreen layout.
    [self updateComponents];
    [self updateFrame];
    
    // Update wrapping
    if (editingView == self.titleLabel) {
        [self.editingHelper updateEditingView:self.titleLabel];
    } else if (editingView == self.pageLabel) {
        [self.editingHelper updateEditingView:self.pageLabel];
    } else if (editingView == self.storyLabel) {
        [self.editingHelper updateEditingView:self.storyLabel];
    } else if (editingView == self.servesCookView) {
        [self.editingHelper updateEditingView:self.servesCookView];
    } else if (editingView == self.methodLabel) {
        [self.editingHelper updateEditingView:self.methodLabel];
    } else if (editingView == self.ingredientsView) {
        [self.editingHelper updateEditingView:self.ingredientsView];
    }
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
        [self addSubview:profilePhotoView];
        self.profilePhotoView = profilePhotoView;
        [self.pageComponents addObject:profilePhotoView];
        
        // Page label to be toggle visible when profile photo hides.
        UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        pageLabel.font = [Theme pageNameFont];
        pageLabel.textColor = [Theme pageNameColour];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.backgroundColor = [UIColor clearColor];
        pageLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        pageLabel.shadowColor = [UIColor whiteColor];
        pageLabel.hidden = YES;
        [self addSubview:pageLabel];
        self.pageLabel  = pageLabel;
        [self.pageComponents addObject:pageLabel];
        
        // Wrap it immediately as it's only visible in edit mode.
        UIEdgeInsets defaultInsets = [CKEditingViewHelper contentInsetsForEditMode:NO];
        [self.editingHelper wrapEditingView:self.pageLabel contentInsets:(UIEdgeInsets){
            defaultInsets.top + 3.0,
            defaultInsets.left,
            defaultInsets.bottom,
            defaultInsets.right - 2.0
        } delegate:self white:YES editMode:NO];
        CKEditingTextBoxView *pageTextBoxView = [self.editingHelper textBoxViewForEditingView:pageLabel];
        pageTextBoxView.hidden = YES;
    }
    
    // Update photo.
    self.profilePhotoView.frame = (CGRect){
        self.layoutOffset.x + floor(([self availableSize].width - self.profilePhotoView.frame.size.width) / 2.0),
        self.bounds.origin.y + self.layoutOffset.y,
        self.profilePhotoView.frame.size.width,
        self.profilePhotoView.frame.size.height
    };
    
    // Update page.
    self.pageLabel.text = [self.recipeDetails.page uppercaseString];
    [self.pageLabel sizeToFit];
    self.pageLabel.center = self.profilePhotoView.center;
    self.pageLabel.frame = CGRectIntegral(self.pageLabel.frame);
    [self.editingHelper updateEditingView:self.pageLabel];
    CKEditingTextBoxView *pageTextBoxView = [self.editingHelper textBoxViewForEditingView:self.pageLabel];
    pageTextBoxView.hidden = YES;
    
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
        [self.pageComponents addObject:titleLabel];
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
        [self.pageComponents addObject:tagsView];
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
        [self.pageComponents addObject:self.storyDividerView];
        
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
        [self.pageComponents addObject:self.storyLabel];
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
        [self.pageComponents addObject:self.contentDividerView];
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
    
    // Add the serves cook view once.
    if (!self.servesCookView) {
        self.servesCookView = [[RecipeServesCookView alloc] initWithRecipeDetails:self.recipeDetails];
        self.servesCookView.hidden = YES;
        self.servesCookView.userInteractionEnabled = NO;
        [self addSubview:self.servesCookView];
        [self.pageComponents addObject:self.servesCookView];
    } else {
        [self.servesCookView update];
    }
    
    CGFloat beforeGap = 0.0;
    
    if (self.recipeDetails.numServes >= 0 || self.recipeDetails.prepTimeInMinutes >= 0
        || self.recipeDetails.cookingTimeInMinutes >= 0) {
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
    
    // Add divider once.
    if (!self.ingredientsDividerView) {
        self.ingredientsDividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_divider_tile.png"]];
        [self addSubview:self.ingredientsDividerView];
    }
    
    // Update divider.
    CGFloat dividerGap = 10.0;
    self.ingredientsDividerView.frame = (CGRect){
        kContentInsets.left,
        self.layoutOffset.y + dividerGap,
        kMaxLeftWidth,
        self.ingredientsDividerView.frame.size.height
    };
    [self updateLayoutOffsetVertical:dividerGap + self.ingredientsDividerView.frame.size.height + dividerGap];
    
    // Add ingredients view once, then update thereafter.
    if (!self.ingredientsView) {
        self.ingredientsView = [[RecipeIngredientsView alloc] initWithRecipeDetails:self.recipeDetails maxWidth:kMaxLeftWidth];
        self.ingredientsView.userInteractionEnabled = NO;
        [self addSubview:self.ingredientsView];
        [self.pageComponents addObject:self.ingredientsView];
    } else {
        [self.ingredientsView updateIngredients];
    }
    
    CGFloat beforeIngredientsGap = 10.0;
    self.ingredientsView.frame = (CGRect){
        kContentInsets.left + 15.0,
        self.layoutOffset.y + dividerGap + self.ingredientsDividerView.frame.size.height + dividerGap + beforeIngredientsGap,
        self.ingredientsView.frame.size.width,
        self.ingredientsView.frame.size.height
    };
    
    [self updateLayoutOffsetVertical:beforeIngredientsGap + self.ingredientsDividerView.frame.size.height];
    
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
        [self.pageComponents addObject:self.methodLabel];
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
    CGRect frame = (CGRect){ 0.0, 0.0, kWidth, 0.0 };
    for (UIView *subview in self.subviews) {
        
        // Bypass editing boxes as they could jut out from the parent view.
        if ([subview isKindOfClass:[CKEditingTextBoxView class]]) {
            continue;
        }
        
        frame = (CGRectUnion(frame, subview.frame));
        frame.size.height += kContentInsets.bottom;
    }
    self.frame = frame;
    
    [self.delegate recipeDetailsViewUpdated];
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

- (void)enableFieldsForEditMode:(BOOL)editMode {
    
    // Get the default insets so we can adjust them as we please.
    UIEdgeInsets defaultEditInsets = [CKEditingViewHelper contentInsetsForEditMode:YES];
    
    [self enableEditModeOnView:self.titleLabel editMode:editMode
               toDisplayAsSize:(CGSize){ [self availableSize].width, 0.0 }];
    [self enableEditModeOnView:self.storyLabel editMode:editMode
                 minimumInsets:(UIEdgeInsets){
                     defaultEditInsets.top + 10.0,
                     defaultEditInsets.left,
                     defaultEditInsets.bottom + 10.0,
                     defaultEditInsets.right
                 }
               toDisplayAsSize:(CGSize){ kWidth, 0.0 }];
    [self enableEditModeOnView:self.servesCookView editMode:editMode
                 minimumInsets:(UIEdgeInsets){
                     defaultEditInsets.top + 2.0,
                     defaultEditInsets.left - 19.0,
                     defaultEditInsets.bottom + 3.0,
                     defaultEditInsets.right
                 }
               toDisplayAsSize:(CGSize){ kMaxLeftWidth + 20.0, 0.0 }
                  padDirection:EditPadDirectionRight];
    [self enableEditModeOnView:self.ingredientsView editMode:editMode
                 minimumInsets:(UIEdgeInsets){
                     defaultEditInsets.top + 10.0,
                     defaultEditInsets.left - 4.0,
                     defaultEditInsets.bottom + 10.0,
                     defaultEditInsets.right + 10.0
                 }
               toDisplayAsSize:(CGSize){ kMaxLeftWidth + 20.0, 0.0 }
                  padDirection:EditPadDirectionRight];
    [self enableEditModeOnView:self.ingredientsView editMode:editMode
                 minimumInsets:(UIEdgeInsets){
                     defaultEditInsets.top + 10.0,
                     defaultEditInsets.left - 4.0,
                     defaultEditInsets.bottom + 10.0,
                     defaultEditInsets.right + 10.0
                 }
               toDisplayAsSize:(CGSize){ kMaxLeftWidth + 20.0, 0.0 }
                  padDirection:EditPadDirectionRight];
    [self enableEditModeOnView:self.methodLabel editMode:editMode
                 minimumInsets:(UIEdgeInsets){
                     defaultEditInsets.top + 8.0,
                     defaultEditInsets.left - 5.0,
                     defaultEditInsets.bottom + 10.0,
                     defaultEditInsets.right - 20.0,
                 }
               toDisplayAsSize:(CGSize){ kMaxRightWidth, kMaxMethodHeight }
                  padDirection:EditPadDirectionBottom];
}

- (void)enableEditModeOnView:(UIView *)view editMode:(BOOL)editMode  {
    [self enableEditModeOnView:view editMode:editMode minimumInsets:UIEdgeInsetsZero];
}

- (void)enableEditModeOnView:(UIView *)view editMode:(BOOL)editMode toDisplayAsSize:(CGSize)size {
    [self enableEditModeOnView:view editMode:editMode minimumInsets:UIEdgeInsetsZero toDisplayAsSize:size];
}

- (void)enableEditModeOnView:(UIView *)view editMode:(BOOL)editMode minimumInsets:(UIEdgeInsets)minimumInsets {
    [self enableEditModeOnView:view editMode:editMode minimumInsets:minimumInsets toDisplayAsSize:CGSizeZero];
}

- (void)enableEditModeOnView:(UIView *)view editMode:(BOOL)editMode minimumInsets:(UIEdgeInsets)minimumInsets
             toDisplayAsSize:(CGSize)size {
    
    [self enableEditModeOnView:view editMode:editMode minimumInsets:minimumInsets toDisplayAsSize:size
                  padDirection:EditPadDirectionLeftRight];
}

- (void)enableEditModeOnView:(UIView *)view editMode:(BOOL)editMode minimumInsets:(UIEdgeInsets)minimumInsets
             toDisplayAsSize:(CGSize)size padDirection:(EditPadDirection)padDirection {
    
    if (editMode) {
        
        if (!UIEdgeInsetsEqualToEdgeInsets(minimumInsets, UIEdgeInsetsZero)) {
            [self.editingHelper wrapEditingView:view contentInsets:minimumInsets delegate:self white:YES
                                       editMode:editMode animated:YES];
        } else {
            [self.editingHelper wrapEditingView:view delegate:self white:YES editMode:editMode animated:YES];
        }
        
        // Get the resulting textBoxView to stretch to the displayed size.
        CKEditingTextBoxView *textBoxView = [self.editingHelper textBoxViewForEditingView:view];
        textBoxView.backgroundColor = [UIColor clearColor];
        CGRect textBoxFrame = textBoxView.frame;
        
        // Do we need to display to a minimum size.
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            
            // Check horizontal padding.
            if (size.width > 0.0 && size.width > textBoxFrame.size.width) {
                
                // Insets of the box image.
                UIEdgeInsets textBoxInsets = [CKEditingViewHelper textBoxInsets];
                
                // Effective width of the required width + the textbox insets around it.
                CGFloat effectiveWidth = size.width + textBoxInsets.left + textBoxInsets.right;
                
                // Extra width to pad horizontally.
                CGFloat extraWidth = effectiveWidth - textBoxFrame.size.width;
                
                // Update textboxFrame and adjust insets so it is centered.
                textBoxFrame.size.width = effectiveWidth;
                
                // Padding directions.
                if (padDirection == EditPadDirectionLeftRight) {
                    
                    // Padding both ways equally.
                    textBoxFrame.origin.x = textBoxFrame.origin.x - floorf(extraWidth / 2.0);
                    
                } else if (padDirection == EditPadDirectionLeft) {
                    
                    // Padding towards the left.
                    textBoxFrame.origin.x = textBoxFrame.origin.x - extraWidth;
                    
                }
                
            }
            
            // Check vertical padding.
            if (size.height > 0.0 && size.height > textBoxFrame.size.height) {
                textBoxFrame.size.height = size.height;
            }
            
            textBoxView.frame = textBoxFrame;
        }
        
    } else {
        [self.editingHelper unwrapEditingView:view animated:YES];
    }
}

- (UIEdgeInsets)editInsetsForEditingView:(UIView *)editingView minimumInsets:(UIEdgeInsets)minimumInsets
                         toDisplayAsSize:(CGSize)size {
    
    UIEdgeInsets editInsets = UIEdgeInsetsZero;
    
    return editInsets;
}

@end
