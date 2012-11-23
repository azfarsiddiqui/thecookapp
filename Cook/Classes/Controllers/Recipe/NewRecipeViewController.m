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
#import "IngredientTableViewCell.h"

#define kIngredientCellTag 112233

@interface NewRecipeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AFPhotoEditorControllerDelegate, CategoryListViewDelegate, UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>

//UI
@property (nonatomic,strong) AFPhotoEditorController *photoEditorController;
@property (nonatomic,strong) IBOutlet UILabel *uploadLabel;
@property (nonatomic,strong) IBOutlet UIProgressView *uploadProgressView;
@property (nonatomic,strong) IBOutlet UITextField *recipeNameTextField;
@property (nonatomic,strong) IBOutlet UITextView *recipeDescriptionTextView;
@property (nonatomic,strong) IBOutlet UIImageView *recipeImageView;
@property (nonatomic,strong) IBOutlet UITableView *ingredientsTableView;
@property (nonatomic,strong) CategoryListViewController *categoryListViewController;

//Data
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) NSMutableArray *ingredients;
@property (nonatomic,strong) UIImage *recipeImage;
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
	// Do any additional setup after loading the view.
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
        recipe.image = self.recipeImage;
        
        if ([self.ingredients count] > 0) {
            recipe.ingredients = [NSArray arrayWithArray:self.ingredients];
        }
        
        [recipe saveWithSuccess:^{
            [self.recipeViewDelegate recipeCreated];
            button.enabled = YES;
        } failure:^(NSError *error) {
            DLog(@"An error occurred: %@", [error description]);
            [self displayMessage:[error description]];
            button.enabled = YES;
        } progress:^(int percentDone) {
            float percentage = percentDone/100.0f;
            [self.uploadProgressView setProgress:percentage animated:YES];
            self.uploadLabel.text = [NSString stringWithFormat:@"Uploading (%i%%)",percentDone];
        }];
    }
}

-(IBAction)uploadButtonTapped:(UIButton *)button
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
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
    [self.ingredients addObject:[Ingredient ingredientwithName:@"ingredient"]];
    [self.ingredientsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.ingredients count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark - CategoryListViewDelegate

-(void)didSelectCategory:(Category *)category
{
    self.selectedCategory = category;
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
    static NSString *reuseCellID = @"IngredientTableViewCell";
    IngredientTableViewCell *cell = (IngredientTableViewCell*) [tableView dequeueReusableCellWithIdentifier:reuseCellID];
    UITextField *ingredientTextField = (UITextField*) [cell viewWithTag:kIngredientCellTag];
    if (ingredientTextField) {
        Ingredient *ingredient = [self.ingredients objectAtIndex:indexPath.row];
        cell.ingredientIndex = indexPath.row;
        ingredientTextField.placeholder = [NSString stringWithFormat:@"%@ %i",ingredient.name, indexPath.row];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog();
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
    [self dismissViewControllerAnimated:NO completion:^{
        self.photoEditorController = [[AFPhotoEditorController alloc] initWithImage:image];
        [self.photoEditorController setDelegate:self];
        self.photoEditorController.view.frame = self.view.bounds;
        [self.view addSubview:self.photoEditorController.view];
    }];
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
    self.recipeImageView.image = self.recipeImage;
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

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField!= self.recipeNameTextField) {
        UIView *parentView = [textField superview];
        IngredientTableViewCell *cell = (IngredientTableViewCell*)[parentView superview];
        Ingredient *ingredient = [self.ingredients objectAtIndex:cell.ingredientIndex];
        ingredient.name = textField.text;
    }
}

#pragma mark - Private methods

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

-(void) configCategoriesList
{

    UIImage *cappedImage = [[UIImage imageNamed:@"cook_editrecipe_categorybg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 32.0f, 0.0f, 32.0f)];
    UIImageView *backgroundImageview = [[UIImageView alloc]initWithImage:cappedImage];
    backgroundImageview.frame = CGRectMake(100.0f, 6.0f, 820.0f, 66.0f);
    [self.view addSubview:backgroundImageview];

    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    self.categoryListViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"CategoryListViewController"];
    self.categoryListViewController.view.frame = CGRectMake(130.0f, 18.0f, 760.0f, 40.0f);
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
