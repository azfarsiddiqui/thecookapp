//
//  TestViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 1/23/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "TestViewController.h"
#import "CKEditableView.h"
#import "CKTextFieldEditingViewController.h"
#import "TextViewEditingViewController.h"
#import "CategoryEditViewController.h"
#import "IngredientsEditingViewController.h"
#import "BookModalViewControllerDelegate.h"
#import "ServesCookPrepEditingViewController.h"
#import "NSArray+Enumerable.h"
#import "FacebookUserView.h"
#import "Ingredient.h"
#import "Theme.h"
#import "ViewHelper.h"
#import "ParsePhotoStore.h"

#define  kEditableInsets    UIEdgeInsetsMake(2.0, 5.0, 2.0f, 25.0f) //tlbr
#define  kCookPrepTimeLabelSize CGSizeMake(200.0f,20.0f)
#define  kCookLabelTag      112233445566
#define  kServesLabelTag      223344556677
#define  kCookPrepLabelLeftPadding  5.0f

#define  kPlaceholderTextRecipeName     @"RECIPE NAME"
#define  kPlaceholderTextStory          @"STORY"
#define  kPlaceholderTextIngredients        @"INGREDIENTS"
#define  kPlaceholderTextRecipeDescription  @"INSTRUCTIONS"
#define  kPlaceholderTextCategory                @"RECIPE CATEGORY"

@interface TestViewController ()<CKEditableViewDelegate, CKEditingViewControllerDelegate>

//ui
@property(nonatomic,strong) IBOutlet CKEditableView *nameEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *methodViewEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *ingredientsViewEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *storyEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *categoryEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *servesCookPrepEditableView;
@property(nonatomic,strong) IBOutlet FacebookUserView *facebookUserView;
@property(nonatomic,strong) IBOutlet UIImageView *recipeImageView;
@property(nonatomic,strong) IBOutlet UIButton *editButton;

@property(nonatomic,strong) CKEditingViewController *editingViewController;

//data/state
@property(nonatomic,assign) BOOL inEditMode;
@property(nonatomic,strong) ParsePhotoStore *parsePhotoStore;

// delegates
@property(nonatomic, assign) id<BookModalViewControllerDelegate> modalDelegate;

@end

@implementation TestViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.parsePhotoStore = [[ParsePhotoStore alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog();
    [super viewWillAppear:animated];
    [self config];
}

#pragma mark - IBActions
-(IBAction)dismissTapped:(id)sender
{
    if (self.modalDelegate) {
        [self.modalDelegate closeRequestedForBookModalViewController:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(IBAction)toggledEditMode:(UIButton*)editModeButton
{
    self.inEditMode = !self.inEditMode;
    [self.nameEditableView enableEditMode:self.inEditMode];
    [self.methodViewEditableView enableEditMode:self.inEditMode];
    [self.ingredientsViewEditableView enableEditMode:self.inEditMode];
    [self.storyEditableView enableEditMode:self.inEditMode];
    [self.categoryEditableView enableEditMode:self.inEditMode];
    [self.servesCookPrepEditableView enableEditMode:self.inEditMode];
    [editModeButton setTitle:self.inEditMode ? @"End Editing" : @"Start Editing" forState:UIControlStateNormal];
    if (self.inEditMode == NO) {
        if (self.recipe) {
            //just completed edit
            [self.recipe saveWithSuccess:^{
                DLog(@"Recipe successfully saved");
            } failure:^(NSError *error) {
                DLog(@"An error occurred: %@", [error description]);
            }];
        }
    }
}

#pragma mark - Private Methods
-(void)config
{
    BOOL newRecipe = !self.recipe;
    
    if (newRecipe) {
        self.recipe = [CKRecipe recipeForUser:[CKUser currentUser] book:self.selectedBook];
    }
    
    [self setRecipeNameValue:self.recipe.name];
    [self setMethodValue:self.recipe.description];
    [self setCategoryValue:self.recipe.category];
    [self setIngredientsValue:self.recipe.ingredients];
    [self setServesCookPrepWithNumServes:self.recipe.numServes
                            cookTimeMins:self.recipe.cookingTimeInMinutes
                            prepTimeMins:self.recipe.prepTimeInMinutes];
    [self setStoryValue:self.recipe.story];
    [self.facebookUserView setUser:self.recipe.user inFrame:self.view.frame];
    
    [self loadRecipeImage];

    //new recipe. toggle edit mode
    if (newRecipe) {
        [self toggledEditMode:self.editButton];
    }
}

- (UIView *)rootView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

#pragma mark - CKEditableViewDelegate

-(void)editableViewEditRequestedForView:(UIView *)view
{

    if (view == self.nameEditableView) {
        CKTextFieldEditingViewController *textFieldEditingVC = [[CKTextFieldEditingViewController alloc] initWithDelegate:self sourceEditingView:self.nameEditableView];
        textFieldEditingVC.textAlignment = NSTextAlignmentCenter;
        textFieldEditingVC.view.frame = [self rootView].bounds;
        [self.view addSubview:textFieldEditingVC.view];
        self.editingViewController = textFieldEditingVC;
        UILabel *textFieldLabel = (UILabel *)self.nameEditableView.contentView;
        textFieldEditingVC.editableTextFont = [Theme bookCoverEditableAuthorTextFont];
        textFieldEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        textFieldEditingVC.characterLimit = 20;
        textFieldEditingVC.text = textFieldLabel.text;
        textFieldEditingVC.editingTitle = @"RECIPE TITLE";
        [textFieldEditingVC enableEditing:YES completion:nil];
    } else if (view == self.methodViewEditableView){
        TextViewEditingViewController *textViewEditingVC = [[TextViewEditingViewController alloc] initWithDelegate:self sourceEditingView:self.methodViewEditableView];
        textViewEditingVC.view.frame = [self rootView].bounds;
        [self.view addSubview:textViewEditingVC.view];
        self.editingViewController = textViewEditingVC;
        textViewEditingVC.characterLimit = 1000;
        UILabel *textViewLabel = (UILabel *)self.methodViewEditableView.contentView;
        textViewEditingVC.text = textViewLabel.text;
        textViewEditingVC.editingTitle = @"RECIPE METHOD";
        [textViewEditingVC enableEditing:YES completion:nil];
    } else if (view == self.ingredientsViewEditableView) {
        IngredientsEditingViewController *ingredientsEditingVC = [[IngredientsEditingViewController alloc] initWithDelegate:self sourceEditingView:self.ingredientsViewEditableView];
        ingredientsEditingVC.view.frame = [self rootView].bounds;
        ingredientsEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        ingredientsEditingVC.characterLimit = 300;
        [self.view addSubview:ingredientsEditingVC.view];
        self.editingViewController = ingredientsEditingVC;
        
        ingredientsEditingVC.ingredientList = self.recipe.ingredients;
        ingredientsEditingVC.editingTitle = @"INGREDIENTS";
        [ingredientsEditingVC enableEditing:YES completion:nil];
        
    } else if (view == self.servesCookPrepEditableView) {
        ServesCookPrepEditingViewController *servesEditingVC = [[ServesCookPrepEditingViewController alloc] initWithDelegate:self sourceEditingView:self.servesCookPrepEditableView];
        servesEditingVC.view.frame = [self rootView].bounds;
        servesEditingVC.numServes = self.recipe.numServes;
        servesEditingVC.cookingTimeInMinutes = self.recipe.cookingTimeInMinutes;
        servesEditingVC.prepTimeInMinutes = self.recipe.prepTimeInMinutes;
        
        [self.view addSubview:servesEditingVC.view];
        self.editingViewController = servesEditingVC;
        [servesEditingVC enableEditing:YES completion:nil];
    } else if (view == self.storyEditableView) {
        TextViewEditingViewController *textViewEditingVC = [[TextViewEditingViewController alloc] initWithDelegate:self sourceEditingView:self.storyEditableView];
        textViewEditingVC.view.frame = [self rootView].bounds;
        [self.view addSubview:textViewEditingVC.view];
        self.editingViewController = textViewEditingVC;
        textViewEditingVC.characterLimit = 160;
        
        UILabel *textViewLabel = (UILabel *)self.storyEditableView.contentView;
        textViewEditingVC.text = textViewLabel.text;
        textViewEditingVC.editingTitle = @"YOUR RECIPE STORY";
        [textViewEditingVC enableEditing:YES completion:nil];
    } else if (view == self.categoryEditableView) {
        CategoryEditViewController *categoryEditingVC = [[CategoryEditViewController alloc] initWithDelegate:self sourceEditingView:self.categoryEditableView];
        categoryEditingVC.view.frame = [self rootView].bounds;
        categoryEditingVC.selectedCategory = self.recipe.category;
        [self.view addSubview:categoryEditingVC.view];
        self.editingViewController = categoryEditingVC;
        [categoryEditingVC enableEditing:YES completion:nil];
    }

}

#pragma mark CKEditableViewControllerDelegate
- (void)editingViewWillAppear:(BOOL)appear {
    
}

- (void)editingViewDidAppear:(BOOL)appear {
    if (!appear) {
        [self.editingViewController.view removeFromSuperview];
        self.editingViewController = nil;
    }
}

-(void)editingView:(UIView *)editingView saveRequestedWithResult:(id)result {
    NSString *value = nil;
    if (editingView!= self.ingredientsViewEditableView && editingView!=self.servesCookPrepEditableView) {
        value = (NSString *)result;
    }
    if (editingView == self.nameEditableView) {
        [self setRecipeNameValue:value];
        [self.nameEditableView enableEditMode:YES];
    } else if (editingView == self.methodViewEditableView) {
        [self setMethodValue:value];
        [self.methodViewEditableView enableEditMode:YES];
    } else if (editingView == self.ingredientsViewEditableView){
        [self setIngredientsValue:(NSArray*)result];
        [self.ingredientsViewEditableView enableEditMode:YES];
    } else if (editingView == self.storyEditableView) {
        [self setStoryValue:value];
        [self.storyEditableView enableEditMode:YES];
    } else if (editingView == self.servesCookPrepEditableView){
        NSDictionary *values = (NSDictionary*)result;
        
        [self setServesCookPrepWithNumServes:[[values objectForKey:@"serves"]intValue]
                                cookTimeMins:[[values objectForKey:@"cookTime"]intValue]
                                prepTimeMins:[[values objectForKey:@"prepTime"]intValue]];
        [self.servesCookPrepEditableView enableEditMode:YES];
    } else if (editingView == self.categoryEditableView) {
        [self setCategoryValue:(Category*)result];
        [self.categoryEditableView enableEditMode:YES];
    }
    
}

#pragma mark - BookModalViewController methods

- (void)setModalViewControllerDelegate:(id<BookModalViewControllerDelegate>)modalViewControllerDelegate {
    self.modalDelegate = modalViewControllerDelegate;
}

#pragma mark - Private Methods

-(UILabel*)displayableLabelWithTextAlignment:(NSTextAlignment)textAlignment withFont:(UIFont*)viewFont  withColor:(UIColor*)color
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.autoresizingMask = UIViewAutoresizingNone;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = textAlignment;
    label.font = viewFont;
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

-(UILabel*)newLabelForEditableView:(CKEditableView*)editableView withTextAlignment:(NSTextAlignment)textAlignment withFont:(UIFont*)viewFont  withColor:(UIColor*)color
{
    UILabel *label = [self displayableLabelWithTextAlignment:textAlignment withFont:viewFont withColor:color];
    editableView.delegate = self;
    editableView.contentInsets = kEditableInsets;
    return label;
}

-(void) configEditableView:(CKEditableView*)editableView withValue:(NSString*)value withFont:(UIFont*)viewFont  withColor:(UIColor*)color withTextAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = (UILabel *)editableView.contentView;
    
    if (!label) {
        label = [self newLabelForEditableView:editableView withTextAlignment:textAlignment withFont:viewFont withColor:color];
    }
    
    label.text = value;
    label.frame = editableView.frame;
    
    editableView.contentView = label;
}

- (void)setRecipeNameValue:(NSString *)recipeValue {
    [self configEditableView:self.nameEditableView withValue:recipeValue withFont:[Theme recipeNameFont]
                 withColor:[Theme recipeNameColor] withTextAlignment:NSTextAlignmentCenter];
    if (!recipeValue) {
        UILabel *label = (UILabel *)self.nameEditableView.contentView;
        label.text = kPlaceholderTextRecipeName;
    } else if (![self.recipe.name isEqualToString:recipeValue]) {
        self.recipe.name = recipeValue;
    }
}

- (void)setCategoryValue:(Category*)category {
    [self configEditableView:self.categoryEditableView withValue:category.name withFont:[Theme recipeNameFont]
                   withColor:[Theme recipeNameColor] withTextAlignment:NSTextAlignmentCenter];
    UILabel *label = (UILabel *)self.categoryEditableView.contentView;
    [label setFont:[Theme categoryFont]];
    if (!category) {
        label.text = kPlaceholderTextCategory;
    } else if (![self.recipe.category.name isEqualToString:category.name]) {
        self.recipe.category = category;
    }
}

- (void)setStoryValue:(NSString *)storyValue {
    
    [self configEditableView:self.storyEditableView withValue:storyValue withFont:[Theme storyFont] withColor:[Theme storyColor] withTextAlignment:NSTextAlignmentCenter];
    if (!storyValue) {
        UILabel *label = (UILabel *)self.storyEditableView.contentView;
        label.text = kPlaceholderTextStory;
    } else if (![self.recipe.story isEqualToString:storyValue]) {
        self.recipe.story = storyValue;
    }
}

- (void)setIngredientsValue:(NSArray *)ingredientsArray {
    UILabel *label = (UILabel *)self.ingredientsViewEditableView.contentView;
    if (!label) {
        label = [self newLabelForEditableView:self.ingredientsViewEditableView withTextAlignment:NSTextAlignmentLeft withFont:[Theme ingredientsListFont]
                                       withColor:[Theme ingredientsListColor]];
    }

    if (!ingredientsArray || [ingredientsArray count] == 0) {
        label.text = kPlaceholderTextIngredients;
    } else {
        NSArray *displayableArray = [ingredientsArray collect:^id(Ingredient *ingredient) {
            return [NSString stringWithFormat:@"%@ %@",
                    ingredient.measurement ? ingredient.measurement : @"",
                    ingredient.name ? ingredient.name : @""];
        }];
        
        label.text = [displayableArray componentsJoinedByString:@"\n"];
        self.recipe.ingredients = ingredientsArray;
    }
    
    CGSize constrainedSize = [label.text sizeWithFont:[Theme ingredientsListFont] constrainedToSize:
                        CGSizeMake(self.ingredientsViewEditableView.frame.size.width,
                                   self.ingredientsViewEditableView.frame.size.height)];
    
    label.frame = CGRectMake(self.ingredientsViewEditableView.frame.origin.x,
                             self.ingredientsViewEditableView.frame.origin.y,
                             self.ingredientsViewEditableView.frame.size.width,
                             constrainedSize.height);
    
    self.ingredientsViewEditableView.contentView = label;
    
}

- (void)setMethodValue:(NSString *)methodValue {
    UILabel *label = (UILabel *)self.methodViewEditableView.contentView;
    if (!label) {
        label = [self newLabelForEditableView:self.methodViewEditableView withTextAlignment:NSTextAlignmentLeft withFont:[Theme methodFont]
                                       withColor:[Theme methodColor]];
    }
    
    if (!methodValue) {
        label.text = kPlaceholderTextRecipeDescription;
    } else {
        label.text = methodValue;
        //change the value if recipe is not nil, and there was a change
        if (![self.recipe.description isEqualToString:methodValue]) {
            self.recipe.description = methodValue;
        }
    }
    
    CGSize constrainedSize = [label.text sizeWithFont:[Theme methodFont] constrainedToSize:
                              CGSizeMake(self.methodViewEditableView.frame.size.width,
                                         self.methodViewEditableView.frame.size.height)];
    
    label.frame = CGRectMake(self.methodViewEditableView.frame.origin.x,
                             self.methodViewEditableView.frame.origin.y,
                             self.methodViewEditableView.frame.size.width,
                             constrainedSize.height);
    
    self.methodViewEditableView.contentView = label;
    
}

- (void)setServesCookPrepWithNumServes:(NSInteger)serves cookTimeMins:(NSInteger)cooktimeMins prepTimeMins:(NSInteger)prepTimeMins {
    UIView *containerView = (UIView *)self.servesCookPrepEditableView.contentView;
    if (!containerView) {
        containerView = [[UIView alloc]initWithFrame:self.servesCookPrepEditableView.frame];
        self.servesCookPrepEditableView.contentInsets = kEditableInsets;
        self.servesCookPrepEditableView.delegate = self;

        UIImageView *servesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_icon_serves"]];
        UIImageView *prepCookTimeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_icon_time"]];
        
        CGFloat verticalSpacingThird = floorf(0.33*(self.servesCookPrepEditableView.frame.size.height - servesImageView.frame.size.height -
                                         prepCookTimeImageView.frame.size.height - kEditableInsets.top - kEditableInsets.bottom));
        
        servesImageView.frame = CGRectMake(2*kEditableInsets.left,
                                           verticalSpacingThird,
                                           servesImageView.frame.size.width,
                                           servesImageView.frame.size.height);
        [containerView addSubview:servesImageView];

        UILabel *servesLabel = [self displayableLabelWithTextAlignment:NSTextAlignmentLeft withFont:[Theme servesFont] withColor:[Theme servesColor]];
        servesLabel.tag = kServesLabelTag;
        servesLabel.frame = CGRectMake(servesImageView.frame.origin.x + servesImageView.frame.size.width + kCookPrepLabelLeftPadding,
                                       verticalSpacingThird,
                                       kCookPrepTimeLabelSize.width,
                                       kCookPrepTimeLabelSize.height);
        [containerView addSubview:servesLabel];
        
        prepCookTimeImageView.frame = CGRectMake(servesImageView.frame.origin.x,
                                                 servesImageView.frame.origin.y + servesImageView.frame.size.height + verticalSpacingThird,
                                                 prepCookTimeImageView.frame.size.width,
                                                 prepCookTimeImageView.frame.size.height);
        [containerView addSubview:prepCookTimeImageView];
        UILabel *prepCookingTimeLabel = [self displayableLabelWithTextAlignment:NSTextAlignmentLeft withFont:[Theme cookingTimeFont] withColor:[Theme cookingTimeColor]];
        prepCookingTimeLabel.frame = CGRectMake(servesLabel.frame.origin.x,
                                                prepCookTimeImageView.frame.origin.y,
                                                kCookPrepTimeLabelSize.width,
                                                kCookPrepTimeLabelSize.height);
        prepCookingTimeLabel.tag = kCookLabelTag;
        [containerView addSubview:prepCookingTimeLabel];
    }
    
    UILabel *servesLabel = (UILabel*) [containerView viewWithTag:kServesLabelTag];
    if (servesLabel) {
        servesLabel.text = [NSString stringWithFormat:@"Serves %i", serves];
    }
    
    UILabel *cookingTimeLabel = (UILabel*) [containerView viewWithTag:kCookLabelTag];
    if (cookingTimeLabel) {
        cookingTimeLabel.text = [NSString stringWithFormat:@"Prep %im | Cook %im", prepTimeMins, cooktimeMins];
    }
    
    self.recipe.numServes = serves;
    self.recipe.cookingTimeInMinutes = cooktimeMins;
    self.recipe.prepTimeInMinutes = prepTimeMins;
    self.servesCookPrepEditableView.contentView = containerView;
}

-(void)loadRecipeImage
{
    if ([self.recipe hasPhotos]) {
        CGSize imageSize = CGSizeMake(self.recipeImageView.frame.size.width, self.recipeImageView.frame.size.height);
        [self.parsePhotoStore imageForParseFile:[self.recipe imageFile] size:imageSize completion:^(UIImage *image) {
            self.recipeImageView.image = image;
        }];
    }
}

@end
