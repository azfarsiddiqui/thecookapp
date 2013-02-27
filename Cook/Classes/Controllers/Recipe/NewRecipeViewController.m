//
//  NewRecipeViewController.m
//  recipe
//
//  Created by Jonny Sagorin on 10/2/12.
//  Copyright (c) 2012 Cook Pty Ltd. All rights reserved.
//

#import "NewRecipeViewController.h"
#import "CategoryListViewController.h"
#import "ViewHelper.h"
#import "AFPhotoEditorController.h"
#import "CKRecipe.h"
#import "Category.h"
#import "Ingredient.h"
#import "TempIngredientTableViewCell.h"
#import "AppHelper.h"
#import "NSArray+Enumerable.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kEditHeight 180.0f 
#define kTextViewEditHeight 240.0f
#define kIngredientsTableViewRestoreHeight 518.0f
#define kDirectionsTextRestoreHeight 586.0f

@interface NewRecipeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AFPhotoEditorControllerDelegate, CategoryListViewDelegate, UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIPopoverControllerDelegate, UIPickerViewDataSource,UIPickerViewDelegate>

//UI
@property (nonatomic,strong) AFPhotoEditorController *photoEditorController;
@property (nonatomic,strong) IBOutlet UILabel *uploadLabel;
@property (nonatomic,strong) IBOutlet UIProgressView *uploadProgressView;
@property (nonatomic,strong) IBOutlet UITextField *recipeNameTextField;
@property (nonatomic,strong) IBOutlet UITextView *recipeDescriptionTextView;
@property (nonatomic,strong) IBOutlet UIImageView *backgroundRecipeDescriptionImageView;
@property (nonatomic,strong) IBOutlet UIImageView *backgroundServesTimeImageView;
@property (nonatomic,strong) IBOutlet UIImageView *backgroundIngredientImageView;
@property (nonatomic,strong) IBOutlet UIView *cameraButtonsView;
@property (nonatomic,strong) IBOutlet UIButton *editImageButton;
@property (nonatomic,strong) IBOutlet UIButton *addImageButtonFromCamera;
@property (nonatomic,strong) IBOutlet UIButton *addImageButtonFromLibrary;

@property (nonatomic,strong) IBOutlet UILabel *numServesLabel;
@property (nonatomic,strong) IBOutlet UILabel *cookingTimeLabel;

@property (nonatomic,strong) UIImageView *recipeImageView;
@property (nonatomic,strong) IBOutlet UIScrollView *recipeImageScrollView;

@property (nonatomic,strong) IBOutlet UITableView *ingredientsTableView;
@property (nonatomic,strong) CategoryListViewController *categoryListViewController;

@property (nonatomic,strong) UIPopoverController *inputPopoverCookingTimeServesController;
@property (nonatomic,strong) UIPopoverController *inputPopoverPhotoLibraryController;

//Data
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) NSMutableArray *ingredients;
@property (nonatomic,strong) UIImage *recipeImage;
@property (nonatomic,assign) float cookingTimeInMinutes;
@property (nonatomic,assign) NSInteger numServes;
@property (nonatomic,strong) Category *selectedCategory;

@end

@implementation NewRecipeViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self data];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self config];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - Action delegates

- (IBAction)closeTapped:(UIButton*)button {
    [self.recipeViewDelegate closeRequested];
}

- (IBAction)saveTapped:(UIButton*)button {
    
    if ([self validate]) {
        button.enabled = NO;
        self.uploadLabel.hidden = NO;
        CKRecipe *recipe = [CKRecipe recipeForUser:[CKUser currentUser] book:self.book category:self.selectedCategory];
        recipe.name = self.recipeNameTextField.text;
        recipe.description = self.recipeDescriptionTextView.text;
        recipe.numServes = self.numServes;
        recipe.cookingTimeInMinutes = self.cookingTimeInMinutes;
        recipe.recipeViewImageContentOffset = self.recipeImageScrollView.contentOffset;
        
        if ([self.ingredients count] > 0) {
            recipe.ingredients = [NSArray arrayWithArray:self.ingredients];
        }
        
        if (self.recipeImage) {
            recipe.image = self.recipeImage;
            [recipe saveAndUploadImageWithSuccess:^{
                [self.recipeViewDelegate recipeCreated];
                button.enabled = YES;

            } failure:^(NSError *error) {
                DLog(@"An error occurred: %@", [error description]);
                [self displayMessage:[error description]];
                button.enabled = YES;

            } imageUploadProgress:^(int percentDone) {
                float percentage = percentDone/100.0f;
                [self.uploadProgressView setProgress:percentage animated:YES];
                self.uploadLabel.text = [NSString stringWithFormat:@"Uploading (%i%%)",percentDone];
            }];
        } else {
            [recipe saveWithSuccess:^{
                [self.recipeViewDelegate recipeCreated];
                button.enabled = YES;
            } failure:^(NSError *error) {
                DLog(@"An error occurred: %@", [error description]);
                [self displayMessage:[error description]];
                button.enabled = YES;

            }];
        }
    }
}

-(IBAction)uploadButtonTapped:(UIButton *)button
{
    if (([button isEqual:self.addImageButtonFromCamera] || [button isEqual:self.editImageButton]) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else if ([button isEqual:self.addImageButtonFromLibrary] && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = @[(NSString *) kUTTypeImage];
        picker.delegate = self;
        
        self.inputPopoverPhotoLibraryController = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.inputPopoverPhotoLibraryController.delegate=self;
        UIView *rootView = [[AppHelper sharedInstance] rootView];
        [self.inputPopoverPhotoLibraryController presentPopoverFromRect:[button.superview convertRect:button.frame toView:rootView] inView:rootView
                                  permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];

    } else {
        DLog("** no camera available - stubbed image **");
        //so we simulate an image
        self.photoEditorController = [[AFPhotoEditorController alloc] initWithImage:[UIImage imageNamed:@"test_image"]];
        [self.photoEditorController setDelegate:self];
        self.photoEditorController.view.frame = self.view.bounds;
        [self.view addSubview:self.photoEditorController.view];
    }
}

-(IBAction)addIngredientTapped:(UIButton*)button
{
    [self.ingredients addObject:[Ingredient ingredientwithName:@"" measurement:nil]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.ingredients count]> 0 ?[self.ingredients count]-1:0 inSection:0];
    [self.ingredientsTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.ingredientsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];

}

-(void) servesTapped:(UITapGestureRecognizer*)gestureRecognizer;
{
    DLog();
    self.numServesLabel.textColor = [UIColor blackColor];
    
    UIViewController* popoverContent = [[UIViewController alloc] init];

	UIPickerView *servesPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	servesPickerView.frame = CGRectMake(0,44,320, 216);
	servesPickerView.showsSelectionIndicator = YES;
	servesPickerView.delegate = self;
	servesPickerView.dataSource = self;
    [popoverContent.view addSubview:servesPickerView];
    [servesPickerView selectRow:self.numServes inComponent:0 animated:NO];
    self.inputPopoverCookingTimeServesController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.inputPopoverCookingTimeServesController.delegate=self;
    [self.inputPopoverCookingTimeServesController setPopoverContentSize:CGSizeMake(320.0f, 264) animated:NO];
    [self.inputPopoverCookingTimeServesController presentPopoverFromRect:self.numServesLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];

}

-(void) cookingTimeTapped:(UITapGestureRecognizer*)gestureRecognizer;
{
    DLog();
    self.cookingTimeLabel.textColor = [UIColor blackColor];
    
    UIViewController* popoverContent = [[UIViewController alloc] init];
    
    UIDatePicker *datePicker=[[UIDatePicker alloc]init];
    datePicker.frame=CGRectMake(0,44,320, 216);
    datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    [datePicker setMinuteInterval:15];
    if (self.cookingTimeInMinutes > 0.0f) {
        datePicker.countDownDuration = self.cookingTimeInMinutes;
    } else {
        self.cookingTimeInMinutes = 15;
        self.cookingTimeLabel.text = [ViewHelper formatAsHoursSeconds:self.cookingTimeInMinutes];
    }
    
    [datePicker addTarget:self action:@selector(cookingTimeChanged:) forControlEvents:UIControlEventValueChanged];
    
    [popoverContent.view addSubview:datePicker];
    
    self.inputPopoverCookingTimeServesController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.inputPopoverCookingTimeServesController.delegate=self;
    [self.inputPopoverCookingTimeServesController setPopoverContentSize:CGSizeMake(320, 264) animated:NO];
    [self.inputPopoverCookingTimeServesController presentPopoverFromRect:self.cookingTimeLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];

}

-(void)cookingTimeChanged:(UIDatePicker*)datePicker
{
    self.cookingTimeLabel.text = [ViewHelper formatAsHoursSeconds:datePicker.countDownDuration];
    self.cookingTimeInMinutes = datePicker.countDownDuration;
}

#pragma mark - CategoryListViewDelegate

-(void)didSelectCategoryWithName:(NSString *)categoryName
{
    [self.categories each:^(Category *category) {
        if ([categoryName isEqualToString:category.name]) {
            self.selectedCategory = category;
        }
    }];
}

#pragma mark - UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ingredients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TempIngredientTableViewCell *cell = (TempIngredientTableViewCell*) [tableView dequeueReusableCellWithIdentifier:kIngredientTableViewCellReuseIdentifier];
    cell.delegate = self;
    Ingredient *ingredient = [self.ingredients objectAtIndex:indexPath.row];
    [cell setIngredient:ingredient forRow:indexPath.row];
    return cell;
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSParameterAssert(image);
    DLog(@"image size after picker: %f, %f", image.size.width,image.size.height);
    if (self.inputPopoverPhotoLibraryController) {
        //origin via popover for library picker
        [self.inputPopoverPhotoLibraryController dismissPopoverAnimated:NO];
        self.photoEditorController = [[AFPhotoEditorController alloc] initWithImage:image];
        [self.photoEditorController setDelegate:self];
        self.photoEditorController.view.frame = self.view.bounds;
        [self.view addSubview:self.photoEditorController.view];
    } else {
        [self dismissViewControllerAnimated:NO completion:^{
            self.photoEditorController = [[AFPhotoEditorController alloc] initWithImage:image];
            [self.photoEditorController setDelegate:self];
            self.photoEditorController.view.frame = self.view.bounds;
            [self.view addSubview:self.photoEditorController.view];
        }];
    }
}

#pragma mark - AFPhotoEditorControllerDelegate
-(void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    DLog();
    NSParameterAssert(editor == self.photoEditorController);
    [self.photoEditorController.view removeFromSuperview];
    self.photoEditorController = nil;
    NSParameterAssert(image);
    self.recipeImage = image;
    
    if (self.recipeImageView) {
        [self.recipeImageView removeFromSuperview];
        self.recipeImageView.image = image;
    } else {
        self.recipeImageView = [[UIImageView alloc] initWithImage:image];
    }
    
    self.recipeImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
    [self.recipeImageScrollView addSubview:self.recipeImageView];
    self.recipeImageScrollView.contentSize = image.size;
    self.recipeImageScrollView.scrollEnabled = YES;
    [self centerScrollViewContents];

    DLog(@"photo size %@", NSStringFromCGSize(image.size));
    
    self.recipeImageScrollView.contentOffset = CGPointMake(340.0f, 0.0f);
    self.cameraButtonsView.hidden = YES;
    self.editImageButton.hidden = NO;
}



-(void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self.photoEditorController.view removeFromSuperview];
    self.photoEditorController = nil;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField!= self.recipeNameTextField) {
        CGRect smallFrame = CGRectMake(self.ingredientsTableView.frame.origin.x, self.ingredientsTableView.frame.origin.y, self.ingredientsTableView.frame.size.width, kEditHeight);
        self.ingredientsTableView.frame = smallFrame;
        self.backgroundIngredientImageView.frame = smallFrame;
        
        UITableViewCell *tableViewCell = (UITableViewCell*)[[textField superview] superview];
        NSIndexPath *indexPath = [self.ingredientsTableView indexPathForCell:tableViewCell];
        [self.ingredientsTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField!= self.recipeNameTextField) {
        UIView *parentView = [textField superview];
        TempIngredientTableViewCell *cell = (TempIngredientTableViewCell*)[parentView superview];
        Ingredient *ingredient = [self.ingredients objectAtIndex:cell.ingredientIndex];
        ingredient.name = textField.text;
        
        CGRect nonEditingFrame = CGRectMake(self.ingredientsTableView.frame.origin.x, self.ingredientsTableView.frame.origin.y, self.ingredientsTableView.frame.size.width, kIngredientsTableViewRestoreHeight);
        self.ingredientsTableView.frame = nonEditingFrame;
        self.backgroundIngredientImageView.frame = nonEditingFrame;
    }
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    DLog();
    CGRect smallFrame = CGRectMake(self.recipeDescriptionTextView.frame.origin.x, self.recipeDescriptionTextView.frame.origin.y, self.recipeDescriptionTextView.frame.size.width, kEditHeight);
    self.recipeDescriptionTextView.frame = smallFrame;
    self.backgroundRecipeDescriptionImageView.frame = CGRectMake(self.backgroundRecipeDescriptionImageView.frame.origin.x, self.backgroundRecipeDescriptionImageView.frame.origin.y, self.backgroundRecipeDescriptionImageView.frame.size.width, kTextViewEditHeight);
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    DLog();
    self.recipeDescriptionTextView.frame = CGRectMake(self.backgroundRecipeDescriptionImageView.frame.origin.x, self.backgroundRecipeDescriptionImageView.frame.origin.y, self.backgroundRecipeDescriptionImageView.frame.size.width, kDirectionsTextRestoreHeight);
    self.backgroundRecipeDescriptionImageView.frame = CGRectMake(self.backgroundRecipeDescriptionImageView.frame.origin.x, self.backgroundRecipeDescriptionImageView.frame.origin.y, self.backgroundRecipeDescriptionImageView.frame.size.width, kDirectionsTextRestoreHeight);
    
    
}
#pragma mark - UIPopoverDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    DLog();
    if ([popoverController isEqual:self.inputPopoverCookingTimeServesController]) {
        self.inputPopoverCookingTimeServesController = nil;
        self.cookingTimeLabel.textColor = [UIColor darkGrayColor];
        self.numServesLabel.textColor = [UIColor darkGrayColor];
    } else {
        self.inputPopoverPhotoLibraryController = nil;
    }
}

#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 12;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%2d",row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 40.0f;
}


#pragma mark- UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.numServes = row;
    self.numServesLabel.text = [NSString stringWithFormat:@"%i", row];
}

#pragma mark - Private methods

- (void)centerScrollViewContents {
    CGSize boundsSize = self.recipeImageScrollView.bounds.size;
    CGRect contentsFrame = self.recipeImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.recipeImageView.frame = contentsFrame;
}

-(void) data
{
    //data needed by categories selection
    [Category listCategories:^(NSArray *results) {
        self.categories = results;
        [self configCategoriesList];
    } failure:^(NSError *error) {
        DLog(@"Could not retrieve categories: %@", [error description]);
    }];
    
    self.ingredients = [NSMutableArray array];
}

-(void) config
{
    UIImage *backgroundImage = [[UIImage imageNamed:@"cook_editrecipe_textbox"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f,4.0f,4.0f,4.0f)];
    self.backgroundRecipeDescriptionImageView.image = backgroundImage;
    self.backgroundServesTimeImageView.image = backgroundImage;
    self.backgroundIngredientImageView.image = backgroundImage;
    self.recipeNameTextField.background = backgroundImage;
    
    self.recipeImageScrollView.bounces = NO;
    self.recipeImageScrollView.showsHorizontalScrollIndicator = NO;
    self.recipeImageScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.recipeImageScrollView.showsVerticalScrollIndicator = NO;
    
    UITapGestureRecognizer *servesTappedRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(servesTapped:)];
    [self.numServesLabel addGestureRecognizer:servesTappedRecognizer];

    UITapGestureRecognizer *cookingTimeRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cookingTimeTapped:)];
    [self.cookingTimeLabel addGestureRecognizer:cookingTimeRecognizer];

    [self.ingredientsTableView registerClass:[TempIngredientTableViewCell class] forCellReuseIdentifier:kIngredientTableViewCellReuseIdentifier];

}

-(void)zoomForScrollView
{
    CGRect scrollViewFrame = self.recipeImageScrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.recipeImageScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.recipeImageScrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.recipeImageScrollView.minimumZoomScale = minScale;
    self.recipeImageScrollView.maximumZoomScale = 1.0f;
    self.recipeImageScrollView.zoomScale = minScale;
}

-(void) configCategoriesList
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    self.categoryListViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CategoryListViewController"];
    self.categoryListViewController.view.frame = CGRectMake(100.0f, 6.0f, 830.f, 66.0f);
    self.categoryListViewController.delegate = self;
    self.categoryListViewController.categories = self.categories;
    
    [self.view addSubview:self.categoryListViewController.view];
    
}
-(BOOL)nullOrEmpty:(NSString*)input
{
    NSString *trimmedString = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (!input || [@"" isEqualToString:trimmedString]);
}

-(BOOL)validate
{
    if ([self nullOrEmpty:self.recipeNameTextField.text]) {
        [self displayMessage:@"Recipe Name is blank"];
        return false;
    }
    
    if ([self nullOrEmpty:self.recipeDescriptionTextView.text]) {
        [self displayMessage:@"Recipe Method is blank"];
        return false;
    }
    
    if (!self.selectedCategory) {
        [self displayMessage:@"Please select a food category"];
        return false;
    }
    return true;
}


-(void)displayMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message
                                                        delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

@end
