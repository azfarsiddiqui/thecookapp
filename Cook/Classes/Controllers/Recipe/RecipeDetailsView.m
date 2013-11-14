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
#import "TagListEditViewController.h"
#import "CKEditingTextBoxView.h"
#import "Ingredient.h"
#import "CKBook.h"
#import "DataHelper.h"
#import "CKRecipeTag.h"

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
@property (nonatomic, strong) UIView *storyDividerView;
@property (nonatomic, strong) UIView *contentDividerView;
@property (nonatomic, strong) RecipeServesCookView *servesCookView;
@property (nonatomic, strong) UIView *ingredientsDividerView;
@property (nonatomic, strong) RecipeIngredientsView *ingredientsView;
@property (nonatomic, strong) UILabel *methodLabel;

// Layout
@property (nonatomic, assign) CGPoint layoutOffset;
@property (nonatomic, assign) CGPoint contentOffset;

// Editing.
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKEditViewController *editViewController;
@property (nonatomic, strong) UIView *addDetailsCardView;

@end

@implementation RecipeDetailsView

#define kWidth                  780.0
#define kMaxTitleWidth          780.0
#define kMaxStoryWidth          600.0
#define kMaxLeftWidth           240.0
#define kMaxRightWidth          480.0
#define kMaxMethodHeight        300.0
#define kDividerWidth           600.0
#define kIngredientDividerWidth 170.0
#define kContentInsets          (UIEdgeInsets){ 35.0, 0.0, 35.0, 0.0 }

- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails delegate:(id<RecipeDetailsViewDelegate>)delegate {
    return [self initWithRecipeDetails:recipeDetails editMode:NO delegate:delegate];
}

- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails editMode:(BOOL)editMode
                   delegate:(id<RecipeDetailsViewDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.editMode = editMode;
        self.recipeDetails = recipeDetails;
        self.delegate = delegate;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        self.backgroundColor = [UIColor clearColor];
        
        // Pre-layout updates.
        [self updateFrame];
        
        // Layout components.
        [self layoutComponentsCompletion:^{
            
            // Edit mode on fields.
            if (self.editMode) {
                [self enableFieldsForEditMode:editMode];
            }
            
        } animated:NO]; // TODO Polish up animation.
        
    }
    return self;
}

- (void)enableEditMode:(BOOL)editMode {
    DLog();
    // If already animating something, then ignore.
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    // Mark as editMode.
    self.editMode = editMode;
    
    // Relayout to make sure missing fields appear.
    [self layoutComponentsCompletion:^{
        
        // Edit mode on fields.
        [self enableFieldsForEditMode:editMode];
        
    } animated:NO]; // TODO Polish up animation.
    
    // Hide the pageLabel/textBox.
    CKEditingTextBoxView *pageTextBoxView = [self.editingHelper textBoxViewForEditingView:self.pageLabel];
    CKEditingTextBoxView *tagsTextBoxView = [self.editingHelper textBoxViewForEditingView:self.tagsLabel];
    if (editMode) {
        self.pageLabel.hidden = NO;
        self.pageLabel.alpha = 0.0;
        pageTextBoxView.hidden = NO;
        pageTextBoxView.alpha = 0.0;
        tagsTextBoxView.hidden = NO;
        tagsTextBoxView.alpha = 0.0;
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         // Toggle between the profile photo and page label.
                         self.profilePhotoView.alpha = editMode ? 0.0 : 1.0;
                         self.pageLabel.alpha = editMode ? 1.0 : 0.0;
                         pageTextBoxView.alpha = editMode ? 1.0 : 0.0;
//                         self.tagsLabel.alpha = editMode ? 1.0 : 0.0;
                         tagsTextBoxView.alpha = editMode ? 1.0 : 0.0;
                         
                         // Fade the divider lines.
//                         self.contentDividerView.alpha = editMode ? 0.0 : 1.0;
                         self.ingredientsDividerView.alpha = editMode ? 0.0 : 1.0;
                         
                     }
                     completion:^(BOOL finished)  {
                         
                         if (!editMode) {
                             self.pageLabel.hidden = YES;
                             pageTextBoxView.hidden = YES;
                             tagsTextBoxView.hidden = YES;
                         }
                         
                         self.animating = NO;
                    }];
    
}

- (void)updateWithRecipeDetails:(RecipeDetails *)recipeDetails {
    [self updateWithRecipeDetails:recipeDetails editMode:NO];
}

- (void)updateWithRecipeDetails:(RecipeDetails *)recipeDetails editMode:(BOOL)editMode {
    self.recipeDetails = recipeDetails;
    [self enableEditMode:editMode];
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    if (editingView == self.titleTextView) {
        
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:editingView
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:nil
                                                                                                   characterLimit:38];
        editViewController.textAlignment = NSTextAlignmentCenter;
        editViewController.numLines = 2;
        editViewController.maxHeight = 160;
        editViewController.forceUppercase = YES;
        editViewController.clearOnFocus = ![self.recipeDetails hasTitle];
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
        editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
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
        
    } else if (editingView == self.tagsLabel) {
        TagListEditViewController *editViewController = [[TagListEditViewController alloc] initWithEditView:self.tagsLabel delegate:self allItems:nil selectedItems:self.recipeDetails.tags editingHelper:self.editingHelper];
        editViewController.canAddItems = NO;
        editViewController.canDeleteItems = NO;
        editViewController.canReorderItems = NO;
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        [CKRecipeTag tagListWithSuccess:^(NSArray *tags) {
            [editViewController updateCellsWithTagArray:tags];
      } failure:^(NSError *error) {
          DLog(@"%@", error.description);
      }];
    } else if (editingView == self.storyLabel) {
        
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:editingView
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:nil
                                                                                                   characterLimit:1000];
        editViewController.clearOnFocus = ![self.recipeDetails hasStory];
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
        editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
        [editViewController performEditing:YES];
        self.editViewController = editViewController;
        
    } else if (editingView == self.methodLabel) {
        
        CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:self.methodLabel
                                                                                                         delegate:self
                                                                                                    editingHelper:self.editingHelper
                                                                                                            white:YES
                                                                                                            title:nil];
        editViewController.clearOnFocus = ![self.recipeDetails hasMethod];
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:48.0];
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
                                                                                                                    title:nil];
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
    if (editingView == self.titleTextView) {
        self.recipeDetails.name = value;
    } else if (editingView == self.pageLabel) {
        self.recipeDetails.page = value;
    } else if (editingView == self.storyLabel) {
        self.recipeDetails.story = value;
    } else if (editingView == self.tagsLabel) {
        self.recipeDetails.tags = value;
    } else if (editingView == self.servesCookView) {
        // The Serves Cook View handles updating of it.
    } else if (editingView == self.methodLabel) {
        self.recipeDetails.method = value;
    } else if (editingView == self.ingredientsView) {
        self.recipeDetails.ingredients = value;
    }
    
    // Update onscreen layout.
    [self layoutComponents];
    
    // Update wrapping
    [self updateEditModeOnView:self.titleTextView
               toDisplayAsSize:(CGSize){ [self availableSize].width, 0.0 }
                       updated:[self.recipeDetails nameUpdated]];
    [self updateEditModeOnView:self.pageLabel
                       updated:[self.recipeDetails pageUpdated]];
    [self updateEditModeOnView:self.tagsLabel
                       updated:[self.recipeDetails tagsUpdated]];
    [self updateEditModeOnView:self.storyLabel
               toDisplayAsSize:(CGSize){ kWidth, 0.0 }
                       updated:[self.recipeDetails storyUpdated]];
    [self updateEditModeOnView:self.servesCookView
               toDisplayAsSize:(CGSize){ kMaxLeftWidth + 20.0, 0.0 }
                  padDirection:EditPadDirectionRight
                       updated:[self.recipeDetails servesPrepUpdated]];
    [self updateEditModeOnView:self.ingredientsView
               toDisplayAsSize:(CGSize){ kMaxLeftWidth + 20.0, 0.0 }
                  padDirection:EditPadDirectionRight
                       updated:[self.recipeDetails ingredientsUpdated]];
    [self updateEditModeOnView:self.methodLabel
               toDisplayAsSize:(CGSize){ kMaxRightWidth, kMaxMethodHeight }
                  padDirection:EditPadDirectionBottom
                       updated:[self.recipeDetails methodUpdated]];
    
    [self updateAddDetailsCardView];
}

- (id)editViewControllerInitialValueForEditView:(UIView *)editingView {
    NSString *initialValue = nil;
    if (editingView == self.titleTextView) {
        initialValue = [self.recipeDetails.name CK_lineBreakFormattedString];
    } else if (editingView == self.storyLabel) {
        initialValue = [self.recipeDetails.story CK_lineBreakFormattedString];
    } else if (editingView == self.methodLabel) {
        initialValue = [self.recipeDetails.method CK_lineBreakFormattedString];
    }
    return initialValue;
}

#pragma mark - Properties

- (UIView *)addDetailsCardView {
    if (!_addDetailsCardView) {
        
        CKEditingTextBoxView *storyBoxView = [self.editingHelper textBoxViewForEditingView:self.storyLabel];

        UIImage *whiteBoxImage = [CKEditingTextBoxView textEditingBoxWhite:YES editMode:NO];
        UIImageView *whiteBoxImageView = [[UIImageView alloc] initWithImage:whiteBoxImage];
        whiteBoxImageView.frame = (CGRect){
            storyBoxView.frame.origin.x,
            self.contentDividerView.frame.origin.y + 3.0,
            storyBoxView.frame.size.width,
            280.0
        };
        
        CGFloat chefHatLabelGap = 5.0;
        UIImageView *chefHatImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_customise_icon_chefhat.png"]];
        CGRect chefHatFrame = chefHatImageView.frame;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentJustified;
        label.backgroundColor = [UIColor clearColor];
        label.shadowOffset = CGSizeMake(0.0, 1.0);
        label.shadowColor = [UIColor whiteColor];
        label.userInteractionEnabled = NO;
        
        NSAttributedString *display = [self attributedTextForText:@"TYPE UP A RECIPE" lineSpacing:0.0
                                                             font:[Theme storyFont] colour:[Theme storyColor]
                                                    textAlignment:NSTextAlignmentCenter];
        label.attributedText = display;
        CGSize size = [label sizeThatFits:(CGSize){ 200.0, MAXFLOAT }];
        CGRect labelFrame = label.frame;
        labelFrame.size = size;
        label.frame = CGRectIntegral(labelFrame);
        
        // Position the elements.
        CGFloat xOffset = -7.0;
        CGFloat requiredHeight = chefHatFrame.size.height + chefHatLabelGap + labelFrame.size.height;
        chefHatFrame.origin.x = floorf((whiteBoxImageView.bounds.size.width - chefHatFrame.size.width) / 2.0) + xOffset;
        chefHatFrame.origin.y = floorf((whiteBoxImageView.bounds.size.height - requiredHeight) / 2.0);
        labelFrame.origin.x = floorf((whiteBoxImageView.bounds.size.width - labelFrame.size.width) / 2.0) + xOffset;
        labelFrame.origin.y = chefHatFrame.origin.y + chefHatFrame.size.height + chefHatLabelGap;
        chefHatImageView.frame = chefHatFrame;
        label.frame = labelFrame;
        [whiteBoxImageView addSubview:chefHatImageView];
        [whiteBoxImageView addSubview:label];
        
        // Register tap to dismiss.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailsIntroDismissed:)];
        whiteBoxImageView.userInteractionEnabled = YES;
        [whiteBoxImageView addGestureRecognizer:tapGesture];
        
        // Position it below the divider.
        _addDetailsCardView = whiteBoxImageView;
    }
    return _addDetailsCardView;
}


#pragma mark - Private methods

- (void)layoutComponents {
    [self layoutComponentsAnimated:NO];
}

- (void)layoutComponentsAnimated:(BOOL)animated {
    [self layoutComponentsCompletion:nil animated:animated];
}

- (void)layoutComponentsCompletion:(void (^)())completion animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self updateComponents];
                         }
                         completion:^(BOOL finished) {
                             [self updateFrame];
                             if (completion != nil) {
                                 completion();
                             }
                         }];
        
    } else {
        [self updateComponents];
        [self updateFrame];
        if (completion != nil) {
            completion();
        }
    }
}

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
        CKUserProfilePhotoView *profilePhotoView = nil;
        if (self.recipeDetails.userPhotoUrl) {
            profilePhotoView = [[CKUserProfilePhotoView alloc] initWithProfileSize:ProfileViewSizeSmall];
            [profilePhotoView loadProfileUrl:self.recipeDetails.userPhotoUrl];
        } else {
            profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.recipeDetails.user
                                                                profileSize:ProfileViewSizeSmall];
        }
        profilePhotoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:profilePhotoView];
        self.profilePhotoView = profilePhotoView;
        
        // Page label to be toggle visible when profile photo hides.
        UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        pageLabel.font = [Theme pageNameFont];
        pageLabel.textColor = [Theme pageNameColour];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.backgroundColor = [UIColor clearColor];
        pageLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        pageLabel.shadowColor = [UIColor whiteColor];
        pageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        pageLabel.hidden = YES;
        [self addSubview:pageLabel];
        self.pageLabel  = pageLabel;
        
        // Wrap it immediately as it's only visible in edit mode.
        UIEdgeInsets defaultInsets = [CKEditingViewHelper contentInsetsForEditMode:NO];
        [self.editingHelper wrapEditingView:self.pageLabel contentInsets:(UIEdgeInsets){
            defaultInsets.top + 6.0,
            defaultInsets.left,
            defaultInsets.bottom,
            defaultInsets.right - 2.0
        } delegate:self white:YES iconImage:[UIImage imageNamed:@"cook_customise_icon_page"]];
        
        //- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white iconImage:(UIImage *)iconImage
    }
    // Update photo.
    self.profilePhotoView.frame = (CGRect){
        self.layoutOffset.x + floor(([self availableSize].width - self.profilePhotoView.frame.size.width) / 2.0),
        self.bounds.origin.y + self.layoutOffset.y - 3,
        self.profilePhotoView.frame.size.width,
        self.profilePhotoView.frame.size.height
    };
    
    // Update page.
    self.pageLabel.text = [self.recipeDetails.page uppercaseString];
    [self.pageLabel sizeToFit];
    UIImage *pageIconImage = [UIImage imageNamed:@"cook_customise_icon_page"];
    self.pageLabel.center = CGPointMake(self.profilePhotoView.center.x + pageIconImage.size.width/2, self.profilePhotoView.center.y);
    CGRect pageLabelSize = CGRectIntegral(self.pageLabel.frame);
    self.pageLabel.frame = CGRectMake(pageLabelSize.origin.x, pageLabelSize.origin.y, pageLabelSize.size.width, pageLabelSize.size.height + 6);
    [self.editingHelper updateEditingView:self.pageLabel];
    CKEditingTextBoxView *pageTextBoxView = [self.editingHelper textBoxViewForEditingView:self.pageLabel];
    pageTextBoxView.hidden = !self.editMode;
    
    // Update layout offset.
    [self updateLayoutOffsetVertical:self.profilePhotoView.frame.size.height];
}

- (void)updateTitle {
    if (!self.titleTextView) {
        self.titleTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        self.titleTextView.editable = NO;
        self.titleTextView.scrollEnabled = NO;
        self.titleTextView.userInteractionEnabled = NO;
        self.titleTextView.font = [Theme recipeNameFont];
        self.titleTextView.textColor = [Theme recipeNameColor];
        self.titleTextView.textAlignment = NSTextAlignmentCenter;
        self.titleTextView.backgroundColor = [UIColor clearColor];
        self.titleTextView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.titleTextView.alpha = 0.0;
        [self updateTitleFrame];
        [self addSubview:self.titleTextView];
    }
    
    // Display if not-blank or in editMode.
    if ([self.recipeDetails.name CK_containsText] || self.editMode) {
        self.titleTextView.alpha = 1.0;
        [self updateTitleFrame];
        [self updateLayoutOffsetVertical:self.titleTextView.frame.size.height];
    } else {
        self.titleTextView.alpha = 0.0;
        [self updateTitleFrame];
    }

}

- (void)updateTitleFrame {
    NSString *title = [self currentTitleValue];
    self.titleTextView.attributedText = [self attributedTextForText:title lineSpacing:-15.0
                                                            font:[Theme recipeNameFont]
                                                          colour:[Theme recipeNameColor]
                                                   textAlignment:NSTextAlignmentCenter
                                                    shadowColour:[UIColor whiteColor]
                                                    shadowOffset:(CGSize){ 0.0, 1.0 }];
    CGSize size = [self.titleTextView sizeThatFits:(CGSize){ kWidth, MAXFLOAT }];
    
    // Must round so that fractional frames do not truncate text on retina devices.
    self.titleTextView.frame = CGRectIntegral((CGRect){
        (kWidth - size.width) / 2.0,
        self.layoutOffset.y,
        size.width,
        size.height
    });
}

- (NSString *)currentTitleValue {
    NSString *name = self.recipeDetails.name;
    
    if (![self.recipeDetails.name CK_containsText]) {
        name = @"TITLE";
    }
    
    return [[name CK_lineBreakFormattedString] uppercaseString];
}

- (void)updateTags
{
    if (!self.tagsLabel) {
        self.tagsLabel = [[UILabel alloc] init];
        self.tagsLabel.font = [Theme tagsFont];
        self.tagsLabel.textColor = [Theme tagsNameColor];
        self.tagsLabel.numberOfLines = 1;
        self.tagsLabel.textAlignment = NSTextAlignmentCenter;
        self.tagsLabel.backgroundColor = [UIColor clearColor];
        self.tagsLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.tagsLabel.shadowColor = [UIColor whiteColor];
        self.tagsLabel.userInteractionEnabled = NO;
        [self addSubview:self.tagsLabel];
//        [self addSubview:self.tagsView];
        
//        //Setting up constraints
//        {
//            self.tagsView.translatesAutoresizingMaskIntoConstraints = NO;
//            self.tagsLabel.translatesAutoresizingMaskIntoConstraints = NO;
//            NSDictionary *metrics = @{@"iconOffset":@40};
//            NSDictionary *views = @{@"tagsLabel" : self.tagsLabel, @"titleTextView" : self.titleTextView};
//            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[tagsLabel]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
//            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.tagsLabel
//                                                             attribute:NSLayoutAttributeCenterX
//                                                             relatedBy:NSLayoutRelationEqual
//                                                                toItem:self
//                                                             attribute:NSLayoutAttributeCenterX
//                                                            multiplier:1.f constant:0.f]];
//            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleTextView]-(5)-[tagsLabel]" options:0 metrics:metrics views:views]];
//            NSString *tagsConstraintString = @"|-iconOffset-[tagsLabel]-|";
//            [self.tagsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:tagsConstraintString options:0 metrics:metrics views:views]];
//            [self.tagsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tagsLabel]-|" options:0 metrics:metrics views:views]];
//        }
        
        UIEdgeInsets  defaultInsets = [CKEditingViewHelper contentInsetsForEditMode:NO];
        [self.editingHelper wrapEditingView:self.tagsLabel contentInsets:(UIEdgeInsets){
            defaultInsets.top + 8.0,
            defaultInsets.left,
            defaultInsets.bottom + 4.0,
            defaultInsets.right - 2.0
        } delegate:self white:YES iconImage:[UIImage imageNamed:@"cook_customise_icon_tag"]];
    }
    
    if ([self.recipeDetails.tags count] > 0 || self.editMode) {
        self.tagsLabel.alpha = 1.0;
        [self updateTagsFrame];
        [self updateLayoutOffsetVertical:self.tagsLabel.frame.size.height + 25];
    } else {
        [self updateTagsFrame];
    }
    [self.editingHelper updateEditingView:self.tagsLabel];
    CKEditingTextBoxView *tagsTextBoxView = [self.editingHelper textBoxViewForEditingView:self.tagsLabel];
    tagsTextBoxView.hidden = !self.editMode;
}

- (void)updateTagsFrame {
    NSMutableString *tagsString = [NSMutableString new];
    if ([self.recipeDetails.tags count] > 0)
    {
        for (CKRecipeTag *tag in self.recipeDetails.tags)
        {
            if (tag.objectId)
            {
                //Append spaces and tag name
                if ([tagsString length] > 0)
                    [tagsString appendString:@"   "];
                [tagsString appendString:[tag displayName]];
            }
        }
    }
    else if (self.editMode)
    {
        tagsString = [NSMutableString stringWithString:@"ENTER TAGS"];
    }
    else
    {
        tagsString = [NSMutableString stringWithString:@""];
    }
    NSAttributedString *tagsDisplay = [self attributedTextForText:tagsString font:[Theme tagsFont] colour:[Theme tagsNameColor]];
    self.tagsLabel.attributedText = tagsDisplay;
    self.tagsLabel.numberOfLines = 1;
    
    CGSize size = [self.tagsLabel sizeThatFits:(CGSize){ kWidth, MAXFLOAT }];
    self.tagsLabel.frame = CGRectIntegral((CGRect){
        floorf((kWidth - size.width) / 2.0) > 0 ? floorf((kWidth - size.width) / 2.0) : 0,
        self.layoutOffset.y + 20,
        size.width > kWidth ? kWidth : size.width,
        size.height
    });
}

- (void)updateStory {
    CGFloat dividerStoryGap = 5.0;
    
    if (!self.storyLabel) {
        
        // Top quote divider.
        self.storyDividerView = [self createQuoteDividerView];
        self.storyDividerView.alpha = 0.0;
        [self addSubview:self.storyDividerView];
        
        // Story label.
        self.storyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.storyLabel.font = [Theme storyFont];
        self.storyLabel.textColor = [Theme storyColor];
        self.storyLabel.numberOfLines = 0;
        self.storyLabel.textAlignment = NSTextAlignmentJustified;
        self.storyLabel.backgroundColor = [UIColor clearColor];
        self.storyLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.storyLabel.shadowColor = [UIColor whiteColor];
        self.storyLabel.userInteractionEnabled = NO;
        self.storyLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.storyLabel.alpha = 0.0;
        [self addSubview:self.storyLabel];
        
        [self updateStoryFrame];
    }
    
    // Display if not-blank or in editMode.
    if ([self.recipeDetails.story CK_containsText] || self.editMode) {
        self.storyDividerView.alpha = 1.0;
        self.storyLabel.alpha = 1.0;
        [self updateStoryFrame];
        [self updateLayoutOffsetVertical:self.storyDividerView.frame.size.height + dividerStoryGap + self.storyLabel.frame.size.height];
        
    } else {
        self.storyDividerView.alpha = 0.0;
        self.storyLabel.alpha = 0.0;
        [self updateStoryFrame];
    }
}

- (void)updateStoryFrame {
    NSString *story = self.recipeDetails.story;
    
    if (![self.recipeDetails.story CK_containsText]) {
        story = @"WRITE SOMETHING";
    }
    
    CGFloat dividerStoryGap = 5.0;
    self.storyDividerView.frame = (CGRect){
        floorf((self.bounds.size.width - self.storyDividerView.frame.size.width) / 2.0),
        self.layoutOffset.y,
        self.storyDividerView.frame.size.width,
        self.storyDividerView.frame.size.height
    };
    
    NSAttributedString *storyDisplay = [self attributedTextForText:story font:[Theme storyFont] colour:[Theme storyColor]];
    self.storyLabel.attributedText = storyDisplay;
    CGSize size = [self.storyLabel sizeThatFits:(CGSize){ kMaxStoryWidth, MAXFLOAT }];
    
    //Center story if no ingredients or serves
    if ([self.recipeDetails hasServes] || [self.recipeDetails hasIngredients] || self.editMode) {
        self.storyLabel.frame = CGRectIntegral((CGRect){
            floorf((self.bounds.size.width - size.width) / 2.0),
            self.storyDividerView.frame.origin.y + self.storyDividerView.frame.size.height + dividerStoryGap,
            size.width,
            size.height
        });
    }
    else {
        self.storyLabel.frame = CGRectIntegral((CGRect){
            (kWidth - size.width) / 2.0,
            self.storyDividerView.frame.origin.y + self.storyDividerView.frame.size.height + dividerStoryGap,
            size.width,
            size.height

        });
    }
}

- (void)updateContentDivider {
    if (!self.contentDividerView) {
        self.contentDividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_divider_tile.png"]];
        self.contentDividerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.contentDividerView];
    }
    
    CGFloat dividerGap = (self.storyLabel.alpha == 0.0) ? 5.0 : 30.0;
    CGFloat postDividerGap = (self.storyLabel.alpha == 0.0) ? 20.0 : 30.0;
    
    self.contentDividerView.frame = (CGRect){
        floorf((self.bounds.size.width - kDividerWidth) / 2.0),
        self.layoutOffset.y + dividerGap,
        kDividerWidth,
        self.contentDividerView.frame.size.height
    };
    
    [self updateLayoutOffsetVertical:dividerGap + self.contentDividerView.frame.size.height + postDividerGap];
    
    // Mark this as the offset for content start, so that left/right columns can reference.
    self.contentOffset = self.layoutOffset;
}

- (void)updateAddDetailsCardView {
    CGRect cardFrame = self.addDetailsCardView.frame;
    cardFrame.origin.y = self.contentDividerView.frame.origin.y + 3.0;
    self.addDetailsCardView.frame = cardFrame;
}

- (void)updateServesCook {
    
    if (self.editMode || [self.recipeDetails hasServes]) {
        
        // Add the serves cook view once.
        if (!self.servesCookView) {
            self.servesCookView = [[RecipeServesCookView alloc] initWithRecipeDetails:self.recipeDetails editMode:self.editMode];
            self.servesCookView.userInteractionEnabled = NO;
            [self addSubview:self.servesCookView];
        } else {
            [self.servesCookView updateWithRecipeDetails:self.recipeDetails editMode:self.editMode];
        }
        [self updateServesCookFrame];
        
    } else {
        
        // Remove any edit wrapping.
        [self.editingHelper unwrapEditingView:self.servesCookView animated:YES];
        
        [self.servesCookView removeFromSuperview];
        self.servesCookView = nil;
        
    }
    
}

- (void)updateServesCookFrame {
    CGFloat beforeGap = 0.0;
    self.servesCookView.frame = (CGRect){
        kContentInsets.left,
        self.contentOffset.y + beforeGap,
        self.servesCookView.frame.size.width,
        self.servesCookView.frame.size.height
    };
    [self updateLayoutOffsetVertical:beforeGap + self.servesCookView.frame.size.height];
}

- (void)updateIngredients {
    
    // Add divider once if only we have servesCookView.
    if (self.servesCookView) {
        if (!self.ingredientsDividerView) {
            self.ingredientsDividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_divider_tile.png"]];
            self.ingredientsDividerView.hidden = !self.servesCookView;
            [self addSubview:self.ingredientsDividerView];
        }
    } else {
        [self.ingredientsDividerView removeFromSuperview];
        self.ingredientsDividerView = nil;
    }
    
    // Add ingredients view once, then update thereafter.
    if (!self.ingredientsView) {
        self.ingredientsView = [[RecipeIngredientsView alloc] initWithIngredients:self.recipeDetails.ingredients
                                                                             book:self.recipeDetails.book
                                                                         maxWidth:kMaxLeftWidth];
        self.ingredientsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.ingredientsView.userInteractionEnabled = NO;
        self.ingredientsView.alpha = 1.0;
        [self addSubview:self.ingredientsView];
    }
    
    // Display if not-blank or in editMode.
    if ([self.recipeDetails.ingredients count] > 0 || self.editMode) {
        self.ingredientsView.alpha = 1.0;
        [self updateIngredientsFrame];
    } else {
        self.ingredientsView.alpha = 0.0;
        [self updateIngredientsFrame];
    }
}

- (void)updateIngredientsFrame {
    CGFloat leftOffset = 15.0;
    NSArray *ingredients = self.recipeDetails.ingredients;
    
    if ([ingredients count] == 0) {
        ingredients = @[[Ingredient ingredientwithName:@"INGREDIENTS" measurement:nil]];
    }
    
    // Update divider if exists.
    if (self.ingredientsDividerView) {
        CGFloat preDividerGap = 20.0;
        self.ingredientsDividerView.frame = (CGRect){
            kContentInsets.left + leftOffset,
            self.layoutOffset.y + preDividerGap,
            kMaxLeftWidth - leftOffset,
            self.ingredientsDividerView.frame.size.height
        };
        [self updateLayoutOffsetVertical:preDividerGap + self.ingredientsDividerView.frame.size.height];
    }
    
    // Update ingredients.
    [self.ingredientsView updateIngredients:ingredients];
    CGFloat beforeIngredientsGap = self.ingredientsDividerView ? 23.0 : 0.0;
    self.ingredientsView.frame = (CGRect){
        kContentInsets.left + leftOffset,
        self.layoutOffset.y + beforeIngredientsGap,
        self.ingredientsView.frame.size.width,
        self.ingredientsView.frame.size.height
    };
}

- (void)updateMethod {
    if (!self.methodLabel) {
        self.methodLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.methodLabel.numberOfLines = 0;
        self.methodLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.methodLabel.textAlignment = NSTextAlignmentLeft;
        self.methodLabel.backgroundColor = [UIColor clearColor];
        self.methodLabel.userInteractionEnabled = NO;
        self.methodLabel.alpha = 0.0;
        self.methodLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.methodLabel];
        [self updateMethodFrame];
    }
    
    // Display if not-blank or in editMode.
    if ([self.recipeDetails.method CK_containsText] || self.editMode) {
        self.methodLabel.alpha = 1.0;
        [self updateMethodFrame];
        [self updateLayoutOffsetVertical:self.titleTextView.frame.size.height];
    } else {
        self.methodLabel.alpha = 0.0;
        [self updateMethodFrame];
    }
}

- (void)updateMethodFrame {
    NSString *method = self.recipeDetails.method;
    
    if (![self.recipeDetails.method CK_containsText]) {
        method = @"METHOD OR STEPS";
    }
    
    NSAttributedString *methodDisplay = [self attributedTextForText:method font:[Theme methodFont] colour:[Theme methodColor]];
    self.methodLabel.attributedText = methodDisplay;
    CGSize size = [self.methodLabel sizeThatFits:(CGSize){ kMaxRightWidth, MAXFLOAT }];
    //Center story if no ingredients or serves
    if ([self.recipeDetails hasServes] || [self.recipeDetails hasIngredients] || self.editMode) {
        self.methodLabel.frame = CGRectIntegral((CGRect){
            self.bounds.size.width - kMaxRightWidth,
            self.contentOffset.y,
            size.width,
            size.height
        });
    } else {
        self.methodLabel.frame = CGRectIntegral((CGRect){
            (kWidth - size.width) / 2.0,
            self.contentOffset.y,
            size.width,
            size.height
        });
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
        frame.size.width = kWidth;
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
    
    preStoryDividerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;

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
    
    return [self attributedTextForText:text lineSpacing:8.0 font:font colour:colour];
}

- (NSMutableAttributedString *)attributedTextForText:(NSString *)text font:(UIFont *)font colour:(UIColor *)colour
                                       textAlignment:(NSTextAlignment)textAlignment {
    
    return [self attributedTextForText:text lineSpacing:8.0 font:font colour:colour textAlignment:textAlignment];
}

- (NSMutableAttributedString *)attributedTextForText:(NSString *)text lineSpacing:(CGFloat)lineSpacing
                                                font:(UIFont *)font colour:(UIColor *)colour {
    
    return [self attributedTextForText:text lineSpacing:lineSpacing font:font colour:colour
                         textAlignment:NSTextAlignmentLeft];
}

- (NSMutableAttributedString *)attributedTextForText:(NSString *)text lineSpacing:(CGFloat)lineSpacing
                                                font:(UIFont *)font colour:(UIColor *)colour
                                       textAlignment:(NSTextAlignment)textAlignment {
    
    return [self attributedTextForText:text lineSpacing:lineSpacing font:font colour:colour
                         textAlignment:textAlignment shadowColour:nil shadowOffset:CGSizeZero];
}

- (NSMutableAttributedString *)attributedTextForText:(NSString *)text lineSpacing:(CGFloat)lineSpacing
                                                font:(UIFont *)font colour:(UIColor *)colour
                                       textAlignment:(NSTextAlignment)textAlignment shadowColour:(UIColor *)shadowColour
                                        shadowOffset:(CGSize)shadowOffset {
    
    text = [text length] > 0 ? text : @"";
    NSDictionary *paragraphAttributes = [self paragraphAttributesForFont:font lineSpacing:lineSpacing colour:colour
                                                           textAlignment:textAlignment shadowColour:shadowColour
                                                            shadowOffset:shadowOffset];
    return [[NSMutableAttributedString alloc] initWithString:text attributes:paragraphAttributes];
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing colour:(UIColor *)colour {
    
    return [self paragraphAttributesForFont:font lineSpacing:lineSpacing colour:colour textAlignment:NSTextAlignmentLeft];
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing colour:(UIColor *)colour
                               textAlignment:(NSTextAlignment)textAlignment {
    
    return [self paragraphAttributesForFont:font lineSpacing:lineSpacing colour:colour textAlignment:textAlignment
                               shadowColour:nil shadowOffset:CGSizeZero];
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing colour:(UIColor *)colour
                               textAlignment:(NSTextAlignment)textAlignment shadowColour:(UIColor *)shadowColour
                                shadowOffset:(CGSize)shadowOffset {
    
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = textAlignment;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       font, NSFontAttributeName,
                                       colour, NSForegroundColorAttributeName,
                                       paragraphStyle, NSParagraphStyleAttributeName,
                                       nil];
    if (shadowColour) {
        NSShadow *shadow = [NSShadow new];
        shadow.shadowColor = [UIColor whiteColor];
        shadow.shadowOffset = CGSizeMake(0.0, 1.0);
        [attributes setObject:shadow forKey:NSShadowAttributeName];
    }
    return attributes;
}

- (void)enableFieldsForEditMode:(BOOL)editMode {
    
    // Get the default insets so we can adjust them as we please.
    UIEdgeInsets defaultEditInsets = [CKEditingViewHelper contentInsetsForEditMode:YES];
    
    // Title.
    [self enableEditModeOnView:self.titleTextView editMode:editMode
               toDisplayAsSize:(CGSize){
                   [self availableSize].width, 0.0
               }];
    
    // Story.
    [self enableEditModeOnView:self.storyLabel editMode:editMode
                 minimumInsets:(UIEdgeInsets){
                     defaultEditInsets.top + 10.0,
                     defaultEditInsets.left,
                     defaultEditInsets.bottom + 10.0,
                     defaultEditInsets.right
                 }
               toDisplayAsSize:(CGSize){ kWidth, 0.0 }];
    
    // Serves.
    [self enableEditModeOnView:self.servesCookView editMode:editMode
                 minimumInsets:(UIEdgeInsets){
                     defaultEditInsets.top + 7.0,
                     defaultEditInsets.left - 19.0,
                     defaultEditInsets.bottom + 5.0,
                     defaultEditInsets.right
                 }
               toDisplayAsSize:(CGSize){ kMaxLeftWidth + 20.0, 0.0 }
                  padDirection:EditPadDirectionRight];
    
    // Ingredients.
    [self enableEditModeOnView:self.ingredientsView editMode:editMode
                 minimumInsets:(UIEdgeInsets){
                     defaultEditInsets.top + 10.0,
                     defaultEditInsets.left - 4.0,
                     defaultEditInsets.bottom + 10.0,
                     defaultEditInsets.right - 7.0
                 }
               toDisplayAsSize:(CGSize){ kMaxLeftWidth + 20.0, 0.0 }
                  padDirection:EditPadDirectionRight];
    
    // Method.
    [self enableEditModeOnView:self.methodLabel editMode:editMode
                 minimumInsets:(UIEdgeInsets){
                     defaultEditInsets.top + 8.0,
                     defaultEditInsets.left - 5.0,
                     defaultEditInsets.bottom + 10.0,
                     defaultEditInsets.right - 20.0,
                 }
               toDisplayAsSize:(CGSize){ kMaxRightWidth, kMaxMethodHeight }
                  padDirection:EditPadDirectionBottom];
    
    // Add mode, add
    if ([self.delegate recipeDetailsViewAddMode]) {
        
        if (self.editMode) {
            CKEditingTextBoxView *methodBoxView = [self.editingHelper textBoxViewForEditingView:self.methodLabel];
            CKEditingTextBoxView *servesBoxView = [self.editingHelper textBoxViewForEditingView:self.servesCookView];
            CKEditingTextBoxView *ingredientsBoxView = [self.editingHelper textBoxViewForEditingView:self.ingredientsView];
            
            self.servesCookView.alpha = 0.0;
            servesBoxView.alpha = 0.0;
            self.ingredientsView.alpha = 0.0;
            ingredientsBoxView.alpha = 0.0;
            self.methodLabel.alpha = 0.0;
            methodBoxView.alpha = 0.0;
            
            [self addSubview:self.addDetailsCardView];
        } else {
            [self.addDetailsCardView removeFromSuperview];
        }
        
    }
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
        
        // Pad it to the given minimum size.
        [self padEditView:view minimumSize:size padDirection:padDirection];
        
    } else {
        [self.editingHelper unwrapEditingView:view animated:YES];
    }
}

- (void)updateEditModeOnView:(UIView *)view  {
    [self updateEditModeOnView:view toDisplayAsSize:CGSizeZero];
}

- (void)updateEditModeOnView:(UIView *)view updated:(BOOL)updated {
    [self updateEditModeOnView:view toDisplayAsSize:CGSizeZero updated:updated];
}

- (void)updateEditModeOnView:(UIView *)view toDisplayAsSize:(CGSize)size {
    [self updateEditModeOnView:view toDisplayAsSize:size padDirection:EditPadDirectionLeftRight];
}

- (void)updateEditModeOnView:(UIView *)view toDisplayAsSize:(CGSize)size updated:(BOOL)updated {
    [self updateEditModeOnView:view toDisplayAsSize:size padDirection:EditPadDirectionLeftRight updated:updated];
}

- (void)updateEditModeOnView:(UIView *)view toDisplayAsSize:(CGSize)size padDirection:(EditPadDirection)padDirection {
    [self updateEditModeOnView:view toDisplayAsSize:size padDirection:padDirection updated:NO];
}

- (void)updateEditModeOnView:(UIView *)view toDisplayAsSize:(CGSize)size padDirection:(EditPadDirection)padDirection
                     updated:(BOOL)updated {
    
    // TODO Removed updated cell indivate value changed.
//    [self.editingHelper updateEditingView:view updated:updated animated:YES];
    [self.editingHelper updateEditingView:view updated:NO animated:YES];
    [self padEditView:view minimumSize:size padDirection:padDirection];
}

- (void)padEditView:(UIView *)view minimumSize:(CGSize)size padDirection:(EditPadDirection)padDirection {
    
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
    
}

- (UIEdgeInsets)editInsetsForEditingView:(UIView *)editingView minimumInsets:(UIEdgeInsets)minimumInsets
                         toDisplayAsSize:(CGSize)size {
    
    UIEdgeInsets editInsets = UIEdgeInsetsZero;
    
    return editInsets;
}

- (void)detailsIntroDismissed:(UITapGestureRecognizer *)tapGesture {
    CKEditingTextBoxView *methodBoxView = [self.editingHelper textBoxViewForEditingView:self.methodLabel];
    CKEditingTextBoxView *servesBoxView = [self.editingHelper textBoxViewForEditingView:self.servesCookView];
    CKEditingTextBoxView *ingredientsBoxView = [self.editingHelper textBoxViewForEditingView:self.ingredientsView];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.addDetailsCardView.alpha = 0.0;
                         
                         self.servesCookView.alpha = 1.0;
                         servesBoxView.alpha = 1.0;
                         self.ingredientsView.alpha = 1.0;
                         ingredientsBoxView.alpha = 1.0;
                         self.methodLabel.alpha = 1.0;
                         methodBoxView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self.addDetailsCardView removeFromSuperview];
                     }];
}

@end
