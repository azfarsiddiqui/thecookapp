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

#define  kEditableInsets    UIEdgeInsetsMake(5.0, 5.0, 5.0f, 30.0f) //tlbr
#define  kCookPrepTimeLabelSize CGSizeMake(200.0f,20.0f)
#define  kCookLabelTag      112233445566
#define  kServesLabelTag      223344556677
#define  kCookPrepLabelLeftPadding  5.0f

#define  kPlaceholderTextRecipeName     @"RECIPE NAME"
#define  kPlaceholderTextStory          @"STORY - TELL US A LITTLE ABOUT YOUR RECIPE"
#define  kPlaceholderTextIngredients        @"INGREDIENTS"
#define  kPlaceholderTextRecipeDescription  @"INSTRUCTIONS"
#define  kPlaceholderTextCategory                @"CATEGORY"

#define kEditableColor  [UIColor whiteColor]
#define kNonEditableColor  [UIColor blackColor]

@interface TestViewController ()<CKEditableViewDelegate, CKEditingViewControllerDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>

//ui
@property(nonatomic,strong) IBOutlet CKEditableView *nameEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *methodViewEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *ingredientsViewEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *storyEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *categoryEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *photoEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *servesCookPrepEditableView;
@property(nonatomic,strong) IBOutlet FacebookUserView *facebookUserView;
@property(nonatomic,strong) IBOutlet UIImageView *recipeImageView;
@property(nonatomic,strong) IBOutlet UIButton *editButton;
@property(nonatomic,strong) IBOutlet UIProgressView *uploadProgressView;
@property(nonatomic,strong) IBOutlet UILabel *uploadLabel;

//recipe mask view
@property(nonatomic,strong) IBOutlet UIView  *recipeMaskView;
@property(nonatomic,strong) IBOutlet UIImageView  *recipeMaskBackgroundImageView;
@property(nonatomic,strong) IBOutlet UILabel *typeItUpLabel;
@property(nonatomic,strong) IBOutlet UILabel *orJustAddLabel;

@property(nonatomic,strong) CKEditingViewController *editingViewController;

//data/state
@property(nonatomic,assign) BOOL inEditMode;
@property(nonatomic,strong) ParsePhotoStore *parsePhotoStore;
@property(nonatomic,strong) UIImage *recipePickerImage;
@property(nonatomic,assign) BOOL isNewRecipe;

// delegates
@property(nonatomic, assign) id<BookModalViewControllerDelegate> modalDelegate;

@end

@implementation TestViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.parsePhotoStore = [[ParsePhotoStore alloc]init];
    [self configAndStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog();
    [super viewWillAppear:animated];
    [self config];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DLog();
}

#pragma mark - button actions / gesture recognizers
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
    
    //validate if editing
    if (self.inEditMode && ![self validate]) {
        return;
    }
    
    self.inEditMode = !self.inEditMode;
    self.isNewRecipe = NO;

    [editModeButton setTitle:self.inEditMode ? @"End Editing" : @"Start Editing" forState:UIControlStateNormal];

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
    
    if (self.inEditMode == NO) {
        //done editing
        [self save];
        self.recipeMaskView.hidden = YES;
    }
}

-(void) newRecipeMaskTapped:(UITapGestureRecognizer*)tapGesture
{
    [self toggleViewsForNewRecipe:NO];
}
#pragma mark - Private Methods
-(void)config
{
    self.isNewRecipe = !self.recipe;
    
    self.recipeMaskBackgroundImageView.image = [[UIImage imageNamed:@"cook_editrecipe_textbox"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f,4.0f,4.0f,4.0f)];

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
        categoryEditingVC.backgroundAlpha = 0.0f;
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

#pragma mark - Private Methods

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

#pragma mark - editable view value setting
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

-(void) configAndStyle
{
    self.typeItUpLabel.font = [Theme typeItUpFont];
    self.orJustAddLabel.font = [Theme orJustAddFont];
}

-(void) toggleViewsForNewRecipe:(BOOL)isNewRecipe
{
        self.recipeMaskView.hidden = !isNewRecipe;
        self.servesCookPrepEditableView.hidden = isNewRecipe;
        self.ingredientsViewEditableView.hidden = isNewRecipe;
        self.methodViewEditableView.hidden = isNewRecipe;
}
@end
