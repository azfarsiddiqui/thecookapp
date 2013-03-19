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
#import "RecipePhotoEditViewController.h"
#import "ServesCookPrepEditingViewController.h"
#import "NSArray+Enumerable.h"
#import "FacebookUserView.h"
#import "Ingredient.h"
#import "Theme.h"
#import "AppHelper.h"
#import "ViewHelper.h"
#import "ParsePhotoStore.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kEditableInsets             UIEdgeInsetsMake(5.0, 5.0, 5.0f, 30.0f) //tlbr
#define kCookPrepTimeLabelSize      CGSizeMake(200.0f,20.0f)
#define kCookLabelTag               112233445566
#define kServesLabelTag             223344556677
#define kCookPrepLabelLeftPadding   5.0f
#define kPhotoPeekWindowOffset      150.0
#define kPhotoCollapseOffset        75.0
#define kPhotoExpandOffset          225.0

#define  kPlaceholderTextRecipeName     @"RECIPE NAME"
#define  kPlaceholderTextStory          @"STORY - TELL US A LITTLE ABOUT YOUR RECIPE"
#define  kPlaceholderTextIngredients        @"INGREDIENTS"
#define  kPlaceholderTextRecipeDescription  @"INSTRUCTIONS"
#define  kPlaceholderTextCategory                @"CATEGORY"

#define kEditableColor  [UIColor whiteColor]
#define kNonEditableColor  [UIColor blackColor]
#define kButtonEdgeInsets   UIEdgeInsetsMake(15.0,20.0f,0,50.0f)
#define kTableViewCellIdentifier               @"TableViewCellIdentifier"

@interface TestViewController ()<CKEditableViewDelegate, CKEditingViewControllerDelegate, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate>

//ui

@property(nonatomic,strong)  UITableView *tableView;
@property(nonatomic,strong)  CKEditableView *nameEditableView;
@property(nonatomic,strong)  CKEditableView *methodViewEditableView;
@property(nonatomic,strong)  CKEditableView *ingredientsViewEditableView;
@property(nonatomic,strong)  CKEditableView *storyEditableView;
@property(nonatomic,strong)  CKEditableView *categoryEditableView;
@property(nonatomic,strong)  CKEditableView *photoEditableView;
@property(nonatomic,strong)  CKEditableView *servesCookPrepEditableView;
@property(nonatomic,strong)  FacebookUserView *facebookUserView;
@property(nonatomic,strong)  UIImageView *recipeImageView;
@property(nonatomic,strong)  UIButton *editButton;
@property(nonatomic,strong)  UIButton *closeButton;
@property(nonatomic,strong)  UIButton *cancelButton;
@property(nonatomic,strong)  UIButton *saveButton;
@property(nonatomic,strong)  UIProgressView *uploadProgressView;
@property(nonatomic,strong)  UILabel *uploadLabel;

//recipe mask view
@property(nonatomic,strong)  UIView  *recipeMaskView;
@property(nonatomic,strong)  UIImageView  *recipeMaskBackgroundImageView;
@property(nonatomic,strong)  UIImageView  *typeUpImageView;
@property(nonatomic,strong)  UILabel *typeItUpLabel;
@property(nonatomic,strong)  UILabel *orJustAddLabel;

@property(nonatomic,strong) CKEditingViewController *editingViewController;

//data/state
@property(nonatomic,assign) BOOL inEditMode;
@property(nonatomic,strong) ParsePhotoStore *parsePhotoStore;
@property(nonatomic,strong) UIImage *recipePickerImage;
@property(nonatomic,assign) BOOL isNewRecipe;
@property(nonatomic,strong) CKRecipe *recipe;
@property(nonatomic,strong) CKBook *selectedBook;
@property (nonatomic, assign) BOOL photoExpanded;

// delegates
@property(nonatomic, assign) id<BookModalViewControllerDelegate> modalDelegate;

@end

@implementation TestViewController

-(id) initWithRecipe:(CKRecipe*)recipe selectedBook:(CKBook*)book
{
    if (self=[super init]) {
        self.recipe = recipe;
        self.selectedBook = book;
        self.parsePhotoStore = [[ParsePhotoStore alloc]init];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog();
    [super viewWillAppear:animated];
    [self configAndInitUIComponents];
    [self configData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog();
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return (!self.inEditMode && !self.tableView.scrollEnabled);
    } else {
        return YES;
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Disable scrolling when we've reached the top of tableView content.
    if (scrollView.contentOffset.y <= 0.0) {
        self.tableView.scrollEnabled = NO;
    }
}

#pragma mark - UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //second row is just padding
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == 0) {
        [cell.contentView addSubview:self.servesCookPrepEditableView];
        [cell.contentView addSubview:self.ingredientsViewEditableView];
        [cell.contentView addSubview:self.methodViewEditableView];
        [cell.contentView addSubview:self.storyEditableView];
        [cell.contentView addSubview:self.recipeMaskView];
    }
    
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //customised view with username, recipe title, recipe story
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectZero];
    [containerView addSubview:self.nameEditableView];
    [containerView addSubview:self.facebookUserView];
    [containerView addSubview:self.storyEditableView];
    [containerView addSubview:self.categoryEditableView];
    containerView.backgroundColor = [UIColor whiteColor];
    [containerView setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, [self tableView:self.tableView heightForHeaderInSection:0])];
    return containerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        float leftSideHeight = self.ingredientsViewEditableView.frame.origin.y + self.ingredientsViewEditableView.frame.size.height;
        float rightSideHeight = self.methodViewEditableView.frame.origin.y + self.methodViewEditableView.frame.size.height;
        return leftSideHeight > rightSideHeight ? leftSideHeight : rightSideHeight;
    } else {
        return 200.0f;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.nameEditableView.frame.origin.y + self.nameEditableView.frame.size.height +
    self.facebookUserView.frame.size.height + self.storyEditableView.frame.size.height;
}

#pragma mark - button actions / gesture recognizers
-(IBAction)closeTapped:(id)sender
{
    if (self.modalDelegate) {
        [self.modalDelegate closeRequestedForBookModalViewController:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelTapped:(id)sender {
    if (self.isNewRecipe) {
        [self closeTapped:nil];
    } else {
        [self toggleEditModeValidateAndSave:NO];
    }
}

- (IBAction)toggledEditMode:(UIButton*)editModeButton {
    [self toggleEditModeValidateAndSave:YES];
}

- (void)toggleEditModeValidateAndSave:(BOOL)save {
    
    //validate if editing
    if (self.inEditMode && save && ![self validate]) {
        return;
    }
    
    self.inEditMode = !self.inEditMode;
    [self updateNavButtons];
    
    if (self.inEditMode) {
        [self resetTableView];
    }
    
    [self.nameEditableView enableEditMode:self.inEditMode];
    [self setLabelForEditableView:self.nameEditableView asEditable:self.inEditMode];
    
    [self.methodViewEditableView enableEditMode:self.inEditMode];
    [self setLabelForEditableView:self.methodViewEditableView asEditable:self.inEditMode];
    
    [self.ingredientsViewEditableView enableEditMode:self.inEditMode];
    [self setLabelForEditableView:self.ingredientsViewEditableView asEditable:self.inEditMode];
    
    [self.storyEditableView enableEditMode:self.inEditMode];
    [self setLabelForEditableView:self.storyEditableView asEditable:self.inEditMode];
    
    [self.categoryEditableView enableEditMode:self.inEditMode];
    self.categoryEditableView.hidden = !self.inEditMode;
    self.facebookUserView.hidden = self.inEditMode;
    
    [self setLabelForEditableView:self.categoryEditableView asEditable:self.inEditMode];
    
    //TODO extend photoeditableview
    UILabel *photoLabel = (UILabel*)self.photoEditableView.contentView;
    photoLabel.hidden = !self.inEditMode;
    [self.photoEditableView enableEditMode:self.inEditMode];
    
    [self.servesCookPrepEditableView enableEditMode:self.inEditMode];
    [self setServesCookPrepColorAsEditable:self.inEditMode];
    
    if (!self.inEditMode && save) {
        //done editing
        [self save];
        self.recipeMaskView.hidden = YES;
        self.isNewRecipe = NO;
    }
}

-(void) newRecipeMaskTapped:(UITapGestureRecognizer*)tapGesture
{
    [self toggleViewsForNewRecipe:NO];
}
#pragma mark - Private Methods
-(void)configData
{
    self.isNewRecipe = !self.recipe;

    if (self.isNewRecipe) {
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
    [self.facebookUserView setUser:self.recipe.user];
    self.categoryEditableView.hidden = YES;
    [self loadRecipeImage];
    [self setPhotoValue:nil];

    if (self.isNewRecipe) {
        [self toggledEditMode:self.editButton];
        UITapGestureRecognizer *newRecipeMaskViewTapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(newRecipeMaskTapped:)];
        [self.recipeMaskView addGestureRecognizer:newRecipeMaskViewTapped];
    }
    
    [self toggleViewsForNewRecipe:self.isNewRecipe];
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_close_white.png"]
                                                     target:self
                                                   selector:@selector(closeTapped:)];
        closeButton.frame = CGRectMake(kButtonEdgeInsets.left,
                                       kButtonEdgeInsets.top,
                                       closeButton.frame.size.width,
                                       closeButton.frame.size.height);
        [self.view addSubview:closeButton];
        _closeButton = closeButton;
    }
    return _closeButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
        UIButton *editButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_edit.png"] target:self
                                                  selector:@selector(toggledEditMode:)];
        editButton.frame = CGRectMake(self.view.frame.size.width - kButtonEdgeInsets.right,
                                      kButtonEdgeInsets.top,
                                      editButton.frame.size.width,
                                      editButton.frame.size.height);
        [self.view addSubview:editButton];
        _editButton = editButton;
    }
    return _editButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        UIButton *cancelButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_cancel.png"]
                                                     target:self
                                                   selector:@selector(cancelTapped:)];
        cancelButton.frame = CGRectMake(kButtonEdgeInsets.left,
                                        kButtonEdgeInsets.top,
                                        cancelButton.frame.size.width,
                                        cancelButton.frame.size.height);
        [self.view addSubview:cancelButton];
        _cancelButton = cancelButton;
    }
    return _cancelButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        UIButton *saveButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"] target:self
                                                  selector:@selector(toggledEditMode:)];
        saveButton.frame = CGRectMake(self.view.frame.size.width - kButtonEdgeInsets.right,
                                      kButtonEdgeInsets.top,
                                      saveButton.frame.size.width,
                                      saveButton.frame.size.height);
        [self.view addSubview:saveButton];
        _saveButton = saveButton;
    }
    return _saveButton;
}

#pragma mark - CKEditableViewDelegate

-(void)editableViewEditRequestedForView:(UIView *)view
{

    if (view == self.nameEditableView) {
        CKTextFieldEditingViewController *textFieldEditingVC = [[CKTextFieldEditingViewController alloc] initWithDelegate:self sourceEditingView:self.nameEditableView];
        textFieldEditingVC.textAlignment = NSTextAlignmentCenter;
        
        UILabel *textFieldLabel = (UILabel *)self.nameEditableView.contentView;
        textFieldEditingVC.editableTextFont = [Theme bookCoverEditableAuthorTextFont];
        textFieldEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        textFieldEditingVC.characterLimit = 20;
        textFieldEditingVC.text = textFieldLabel.text;
        textFieldEditingVC.editingTitle = @"RECIPE TITLE";

        self.editingViewController = textFieldEditingVC;

    } else if (view == self.methodViewEditableView){
        TextViewEditingViewController *textViewEditingVC = [[TextViewEditingViewController alloc] initWithDelegate:self
                                                                                                 sourceEditingView:self.methodViewEditableView];
        textViewEditingVC.characterLimit = 1000;
        UILabel *textViewLabel = (UILabel *)self.methodViewEditableView.contentView;
        textViewEditingVC.text = textViewLabel.text;
        textViewEditingVC.editingTitle = @"RECIPE METHOD";
        self.editingViewController = textViewEditingVC;
        
    } else if (view == self.ingredientsViewEditableView) {
        IngredientsEditingViewController *ingredientsEditingVC = [[IngredientsEditingViewController alloc] initWithDelegate:self sourceEditingView:self.ingredientsViewEditableView];
        ingredientsEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        ingredientsEditingVC.characterLimit = 300;
        ingredientsEditingVC.ingredientList = self.recipe.ingredients;
        ingredientsEditingVC.editingTitle = @"INGREDIENTS";

        self.editingViewController = ingredientsEditingVC;
        
    } else if (view == self.servesCookPrepEditableView) {
        ServesCookPrepEditingViewController *servesEditingVC = [[ServesCookPrepEditingViewController alloc] initWithDelegate:self sourceEditingView:self.servesCookPrepEditableView];
        
        servesEditingVC.numServes = self.recipe.numServes;
        servesEditingVC.cookingTimeInMinutes = self.recipe.cookingTimeInMinutes;
        servesEditingVC.prepTimeInMinutes = self.recipe.prepTimeInMinutes;

        self.editingViewController = servesEditingVC;

    } else if (view == self.storyEditableView) {
        TextViewEditingViewController *textViewEditingVC = [[TextViewEditingViewController alloc] initWithDelegate:self sourceEditingView:self.storyEditableView];
        textViewEditingVC.characterLimit = 160;
        
        UILabel *textViewLabel = (UILabel *)self.storyEditableView.contentView;
        textViewEditingVC.text = textViewLabel.text;
        textViewEditingVC.editingTitle = @"YOUR RECIPE STORY";
        self.editingViewController = textViewEditingVC;
        
    } else if (view == self.categoryEditableView) {
        CategoryEditViewController *categoryEditingVC = [[CategoryEditViewController alloc] initWithDelegate:self sourceEditingView:self.categoryEditableView];
        categoryEditingVC.selectedCategory = self.recipe.category;
        categoryEditingVC.editingTitle = @"RECIPE CATEGORY";
        categoryEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        self.editingViewController = categoryEditingVC;

    } else if (view == self.photoEditableView){
        [self displayPhotoPicker];
    }

    self.editingViewController.view.frame = [[AppHelper sharedInstance] rootView].bounds;
    [self.view addSubview:self.editingViewController.view];
    [self.editingViewController enableEditing:YES completion:nil];

}

#pragma mark - CKEditableViewControllerDelegate
- (void)editingViewWillAppear:(BOOL)appear {
    
}

- (void)editingViewDidAppear:(BOOL)appear {
    if (!appear) {
        [self.editingViewController.view removeFromSuperview];
        self.editingViewController = nil;
    }
}

-(void)editingView:(CKEditableView *)editingView saveRequestedWithResult:(id)result {
    
    if (editingView == self.nameEditableView) {
        [self setRecipeNameValue:(NSString *)result];
    } else if (editingView == self.methodViewEditableView) {
        [self setMethodValue:(NSString *)result];
    } else if (editingView == self.ingredientsViewEditableView){
        [self setIngredientsValue:(NSMutableArray*)result];
    } else if (editingView == self.storyEditableView) {
        [self setStoryValue:(NSString *)result];
    } else if (editingView == self.servesCookPrepEditableView){
        NSDictionary *values = (NSDictionary*)result;
        
        [self setServesCookPrepWithNumServes:[[values objectForKey:@"serves"]intValue]
                                cookTimeMins:[[values objectForKey:@"cookTime"]intValue]
                                prepTimeMins:[[values objectForKey:@"prepTime"]intValue]];
    } else if (editingView == self.categoryEditableView) {
        [self setCategoryValue:(Category*)result];
    }
    [editingView enableEditMode:YES];
}

#pragma mark - BookModalViewController methods

- (void)setModalViewControllerDelegate:(id<BookModalViewControllerDelegate>)modalViewControllerDelegate {
    self.modalDelegate = modalViewControllerDelegate;
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSParameterAssert(image);
    [self setPhotoValue:image];
    [self.photoEditableView enableEditMode:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Image/Photo related
-(void)setPhotoValue:(UIImage*)image
{
    UILabel *label = (UILabel *)self.photoEditableView.contentView;
    if (!label) {
        label = [self newLabelForEditableView:self.photoEditableView withFont:[Theme ingredientsListFont] withColor:[Theme ingredientsListColor] withTextAlignment:NSTextAlignmentCenter];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.frame = self.photoEditableView.frame;
        label.hidden = YES;
        self.photoEditableView.contentView = label;
    }
    label.text = @"ADD PHOTO";
    self.recipeImageView.image = image;
    self.recipePickerImage = image;
}

-(void)displayPhotoPicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        //attempt to retrieve from photo library
        DLog(@"no picker available");
    }
    
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

#pragma mark - label configuration

-(UILabel*)displayableLabelWithFont:(UIFont*)viewFont withColor:(UIColor*)color withTextAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.autoresizingMask = UIViewAutoresizingNone;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = textAlignment;
    label.font = viewFont;
    label.textColor = color;
    label.numberOfLines = 0;
//    label.lineBreakMode = NSLineBreakByWordWrapping;
    return label;
}

-(UILabel*)newLabelForEditableView:(CKEditableView*)editableView  withFont:(UIFont*)viewFont  withColor:(UIColor*)color
                 withTextAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [self displayableLabelWithFont:viewFont withColor:color withTextAlignment:textAlignment];
    editableView.delegate = self;
    editableView.contentInsets = kEditableInsets;
    return label;
}

-(void) configLabelForEditableView:(CKEditableView*)editableView withValue:(NSString*)value withFont:(UIFont*)viewFont  withColor:(UIColor*)color withTextAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = (UILabel *)editableView.contentView;
    
    if (!label) {
        label = [self newLabelForEditableView:editableView withFont:viewFont withColor:color withTextAlignment:textAlignment];
        label.backgroundColor=[UIColor clearColor];
    }
    
    label.text = value;
    label.frame = editableView.frame;
    
    editableView.contentView = label;
}

#pragma mark - setting values
- (void)setRecipeNameValue:(NSString *)recipeValue {
    [self configLabelForEditableView:self.nameEditableView withValue:recipeValue withFont:[Theme recipeNameFont]
                 withColor:[Theme recipeNameColor] withTextAlignment:NSTextAlignmentCenter];
    UILabel *label = (UILabel *)self.nameEditableView.contentView;
    if (!recipeValue) {
        label.text = kPlaceholderTextRecipeName;
    } else if (![self.recipe.name isEqualToString:recipeValue]) {
        self.recipe.name = recipeValue;
    }
    label.text = [label.text uppercaseString];
}

- (void)setCategoryValue:(Category*)category {
    [self configLabelForEditableView:self.categoryEditableView withValue:category.name withFont:[Theme categoryFont]
                   withColor:[Theme recipeNameColor] withTextAlignment:NSTextAlignmentCenter];
    UILabel *label = (UILabel *)self.categoryEditableView.contentView;
    [label setFont:[Theme categoryFont]];
    if (!category) {
        label.text = kPlaceholderTextCategory;
    } else if (![self.recipe.category.name isEqualToString:category.name]) {
        self.recipe.category = category;
    }
    label.text = [label.text uppercaseString];
}

- (void)setStoryValue:(NSString *)storyValue {
    
    [self configLabelForEditableView:self.storyEditableView withValue:storyValue withFont:[Theme storyFont] withColor:[Theme storyColor] withTextAlignment:NSTextAlignmentCenter];
    if (!storyValue) {
        UILabel *label = (UILabel *)self.storyEditableView.contentView;
        label.text = kPlaceholderTextStory;
    } else if (![self.recipe.story isEqualToString:storyValue]) {
        self.recipe.story = storyValue;
    }
}

- (void)setIngredientsValue:(NSMutableArray *)ingredientsArray {
    UILabel *label = (UILabel *)self.ingredientsViewEditableView.contentView;
    if (!label) {
        label = [self newLabelForEditableView:self.ingredientsViewEditableView withFont:[Theme ingredientsListFont]
                                       withColor:[Theme ingredientsListColor] withTextAlignment:NSTextAlignmentLeft];
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
    
    label.frame = self.ingredientsViewEditableView.frame;
    self.ingredientsViewEditableView.contentView = label;

    //now size label correctly
    CGSize constrainedSize = [label.text sizeWithFont:[Theme ingredientsListFont]
                                    constrainedToSize:
                              CGSizeMake(self.ingredientsViewEditableView.frame.size.width-kEditableInsets.left-kEditableInsets.right,
                                         self.ingredientsViewEditableView.frame.size.height -kEditableInsets.top-kEditableInsets.bottom)
                                        lineBreakMode:NSLineBreakByWordWrapping];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, constrainedSize.height);
    
}

- (void)setMethodValue:(NSString *)methodValue {
    UILabel *label = (UILabel *)self.methodViewEditableView.contentView;
    if (!label) {
        label = [self newLabelForEditableView:self.methodViewEditableView withFont:[Theme methodFont]
                                       withColor:[Theme methodColor] withTextAlignment:NSTextAlignmentLeft];
    }
    
    if (!methodValue) {
        label.text = kPlaceholderTextRecipeDescription;
    } else {
        label.text = methodValue;
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

        UILabel *servesLabel = [self displayableLabelWithFont:[Theme servesFont] withColor:[Theme servesColor] withTextAlignment:NSTextAlignmentLeft];
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
        UILabel *prepCookingTimeLabel = [self displayableLabelWithFont:[Theme cookingTimeFont] withColor:[Theme cookingTimeColor]
                                                     withTextAlignment:NSTextAlignmentLeft];
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

#pragma mark - editable view color settings
-(void) setServesCookPrepColorAsEditable:(BOOL)editable
{
    UIView *containerView = (UIView *)self.servesCookPrepEditableView.contentView;
    if (containerView) {
        UILabel *servesLabel = (UILabel*) [containerView viewWithTag:kServesLabelTag];
        if (servesLabel) {
            servesLabel.textColor = editable? kEditableColor: kNonEditableColor;
            
        }
        UILabel *cookingTimeLabel = (UILabel*) [containerView viewWithTag:kCookLabelTag];
        if (cookingTimeLabel) {
            cookingTimeLabel.textColor = editable? kEditableColor: kNonEditableColor;
        }
    }
}


-(void)setLabelForEditableView:(CKEditableView*)editableView asEditable:(BOOL)editable
{
    UILabel *label = (UILabel *) editableView.contentView;
    if (label) {
        label.textColor = editable? kEditableColor: kNonEditableColor;
    }
}

-(BOOL)validate
{
    NSMutableString *validationErrors = [NSMutableString string];
    if (!self.recipe.name) {
        [validationErrors appendString:@"Your recipe has no name\n"];
    }
    
    if (!self.recipe.story) {
        [validationErrors appendString:@"Your recipe has no story.\nTell us a freekin' story!\n"];
    }
    if (!self.recipe.category) {
        [validationErrors appendString:@"Your recipe has no category."];
    }
    
    if ([validationErrors length] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Cannot create Recipe" message:validationErrors
    delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
  
    return [validationErrors length] == 0;
    
}

-(void)save
{
    //validation
    //name, story and categoyr was must be filled in
    
    if (self.recipePickerImage) {
        self.recipe.image = self.recipePickerImage;
        [self displayProgress:YES];
        //a new image was picked
        [self.recipe saveAndUploadImageWithSuccess:^{
            [self displayProgress:NO];
        } failure:^(NSError *error) {
            DLog(@"An error occurred: %@", [error description]);
            [self displayProgress:NO];
        } imageUploadProgress:^(int percentDone) {
            float percentage = percentDone/100.0f;
            [self.uploadProgressView setProgress:percentage animated:YES];
            self.uploadLabel.text = [NSString stringWithFormat:@"Uploading (%i%%)",percentDone];
        }];
    } else {
        [self.recipe saveWithSuccess:^{
        } failure:^(NSError *error) {
            DLog(@"An error occurred: %@", [error description]);
        }];
    }
}

-(void)displayProgress:(BOOL)progress
{
    self.uploadLabel.text = @"";
    self.uploadLabel.hidden = !progress;
    self.uploadProgressView.hidden = !progress;
}

-(void) configAndInitUIComponents
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.recipeImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    self.recipeImageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.recipeImageView];
    
    self.photoEditableView = [[CKEditableView alloc]initWithDelegate:self];
    self.photoEditableView.frame = CGRectMake(416.0f, 80.0f, 192.0f, 45.0f);
    [self.view addSubview:self.photoEditableView];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, kPhotoPeekWindowOffset, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellIdentifier];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //instantiate ui components for section header
    self.facebookUserView = [[FacebookUserView alloc] initWithFrame:CGRectMake(416.0f,44.0f,232.0f,17.0f)];
    
    self.categoryEditableView = [[CKEditableView alloc] initWithDelegate:self];
    self.categoryEditableView.frame = CGRectMake(416.0f, 20.0f,192.0f,45.0f);
    
    self.nameEditableView = [[CKEditableView alloc] initWithDelegate:self];
    self.nameEditableView.frame = CGRectMake(135.0f, self.facebookUserView.frame.origin.y + self.facebookUserView.frame.size.height, 754.0f, 68.0f);
    self.storyEditableView = [[CKEditableView alloc] initWithDelegate:self];
    self.storyEditableView.frame = CGRectMake(135.0f,self.nameEditableView.frame.origin.y + self.nameEditableView.frame.size.height,754.0f,56.0f);

    //instaniate ui components for table view cell
    self.servesCookPrepEditableView = [[CKEditableView alloc] initWithDelegate:self];
    self.servesCookPrepEditableView.frame = CGRectMake(135.0f,0.0f,230.0f,71.0f);

    self.ingredientsViewEditableView = [[CKEditableView alloc] initWithDelegate:self];
    self.ingredientsViewEditableView.frame = CGRectMake(135.0f,self.servesCookPrepEditableView.frame.origin.y + self.servesCookPrepEditableView.frame.size.height,230.0f,240.0f);

    self.methodViewEditableView = [[CKEditableView alloc] initWithDelegate:self];
    self.methodViewEditableView.frame = CGRectMake(396.0f,0.0f,493.0f,311.0f);

    [self updateNavButtons];
    [self addUploadViews];
    [self addNewRecipeMaskView];
    
    // Register panning if there was an image.
    self.tableView.scrollEnabled = NO;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
}

-(void) toggleViewsForNewRecipe:(BOOL)isNewRecipe
{
        self.recipeMaskView.hidden = !isNewRecipe;
        self.servesCookPrepEditableView.hidden = isNewRecipe;
        self.ingredientsViewEditableView.hidden = isNewRecipe;
        self.methodViewEditableView.hidden = isNewRecipe;
}

#pragma mark - subView additions

- (void)updateNavButtons {
    self.editButton.hidden = self.inEditMode;
    self.closeButton.hidden = self.inEditMode;
    self.cancelButton.hidden = !self.inEditMode;
    self.saveButton.hidden = !self.inEditMode;
}

-(void) addUploadViews
{
    self.uploadProgressView = [[UIProgressView alloc]initWithFrame:CGRectMake(416.0f,135.0f,192,9)];
    self.uploadLabel = [[UILabel alloc]initWithFrame:CGRectMake(416.0f, 133.0f, 192.0f, 21.0f)];
}

-(void) addNewRecipeMaskView
{
    self.recipeMaskView = [[UIView alloc] initWithFrame:CGRectMake(135.0f, 0.0f, 740.0f, 311.0f)];
    self.recipeMaskBackgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 740.0f, 311.0f)];
    self.recipeMaskBackgroundImageView.image = [[UIImage imageNamed:@"cook_editrecipe_textbox"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f,4.0f,4.0f,4.0f)];
    [self.recipeMaskView addSubview:self.recipeMaskBackgroundImageView];
    
    
    float totalHeight = 0.0f;
    float vertPadding = 10.0f;
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 270.0f,220.0f)];
    CGPoint centerPoint = [ViewHelper centerPointForSmallerView:containerView inLargerView:self.recipeMaskView];
    containerView.frame = CGRectMake(centerPoint.x, centerPoint.y, containerView.frame.size.width, containerView.frame.size.height);
    [self.recipeMaskView addSubview:containerView];

    UIButton *typeItUpButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_editrecipe_typeup.png"] target:self
                                                  selector:@selector(newRecipeMaskTapped:)];
    typeItUpButton.frame = CGRectMake(0.0f,
                                      0.0f,
                                      typeItUpButton.frame.size.width,
                                      typeItUpButton.frame.size.height);
    
    centerPoint = [ViewHelper centerPointForSmallerView:typeItUpButton inLargerView:containerView];
    typeItUpButton.frame = CGRectMake(centerPoint.x, 0.0f, typeItUpButton.frame.size.width, typeItUpButton.frame.size.height);
    [containerView addSubview:typeItUpButton];
    totalHeight = typeItUpButton.frame.size.height;
    
    self.typeItUpLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, typeItUpButton.frame.origin.y + typeItUpButton.frame.size.height + vertPadding,
                                                                  containerView.frame.size.width, 27.0f)];
    self.typeItUpLabel.backgroundColor = [UIColor clearColor];
    self.typeItUpLabel.textAlignment = NSTextAlignmentCenter;
    self.typeItUpLabel.font = [Theme typeItUpFont];
    self.typeItUpLabel.textColor = [UIColor whiteColor];
    self.typeItUpLabel.text = @"TYPE IT UP";
    [containerView addSubview:self.typeItUpLabel];
    totalHeight+= typeItUpButton.frame.size.height + vertPadding;
    
    self.orJustAddLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f,self.typeItUpLabel.frame.origin.y+self.typeItUpLabel.frame.size.height,
                                                                   containerView.frame.size.width, 50.0f)];
    self.orJustAddLabel.textColor = [UIColor whiteColor];
    self.orJustAddLabel.backgroundColor = [UIColor clearColor];
    self.orJustAddLabel.textAlignment = NSTextAlignmentCenter;
    self.orJustAddLabel.numberOfLines = 2;
    self.orJustAddLabel.font = [Theme orJustAddFont];
    self.orJustAddLabel.text = @"OR JUST ADD A PHOTO OF THE ORIGINAL AT THE TOP";
    [containerView addSubview:self.orJustAddLabel];
    totalHeight+=self.typeItUpLabel.frame.size.height;
    
    containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, totalHeight);
    centerPoint = [ViewHelper centerPointForSmallerView:containerView inLargerView:self.recipeMaskView];
    containerView.frame = CGRectMake(containerView.frame.origin.x, centerPoint.y, containerView.frame.size.width, containerView.frame.size.height);
}

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint translation = [panGesture translationInView:self.view];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self panWithTranslation:translation];
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self snapIfRequired];
    }
    
    [panGesture setTranslation:CGPointZero inView:self.view];
}

- (void)panWithTranslation:(CGPoint)translation {
    CGFloat dragRatio = 0.5;
    CGFloat panOffset = ceilf(translation.y * dragRatio);
    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.y += panOffset;
    
    // Reached the top
    if (tableFrame.origin.y <= 0.0) {
//        self.tableView.scrollEnabled = YES;
        tableFrame.origin.y = 0.0;
    }
    
    self.tableView.frame = tableFrame;
}

- (void)snapIfRequired {
    CGRect tableFrame = self.tableView.frame;
    CGFloat snapDuration = 0.2;
    CGFloat expandedOffset = self.view.bounds.size.height - [self tableView:self.tableView heightForHeaderInSection:0];
    
    if (self.photoExpanded && tableFrame.origin.y < expandedOffset - 100.0) {
        
        // Restore to peek from expanded.
        tableFrame.origin.y = kPhotoPeekWindowOffset;
        self.photoExpanded = NO;
        
    } else if (tableFrame.origin.y <= kPhotoCollapseOffset) {
        
        // Collapse photo.
        tableFrame.origin.y = 0.0;
        self.photoExpanded = NO;
        snapDuration = 0.2;
        self.tableView.scrollEnabled = YES;
        
    } else if (tableFrame.origin.y >= kPhotoExpandOffset) {
        
        // Expand photo.
        tableFrame.origin.y = expandedOffset;
        self.photoExpanded = YES;
        snapDuration = 0.2;
        
    } else {
        
        // Restore peek.
        tableFrame.origin.y = kPhotoPeekWindowOffset;
        self.photoExpanded = NO;
        snapDuration = 0.2;
    }
    
    [self snapTableViewToFrame:tableFrame duration:snapDuration];
}

- (void)resetTableView {
    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.y = kPhotoPeekWindowOffset;
    self.photoExpanded = NO;
    [self snapTableViewToFrame:tableFrame duration:0.2];
}

- (void)snapTableViewToFrame:(CGRect)tableFrame duration:(CGFloat)duration {
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.tableView.frame = tableFrame;
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
