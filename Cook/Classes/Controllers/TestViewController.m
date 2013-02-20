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
#import "IngredientsEditingViewController.h"
#import "BookModalViewControllerDelegate.h"

#import "Theme.h"
#define  kEditableInsets    UIEdgeInsetsMake(2.0, 5.0, 2.0f, 25.0f) //tlbr

@interface TestViewController ()<CKEditableViewDelegate, CKEditingViewControllerDelegate>

//ui
@property(nonatomic,strong) IBOutlet CKEditableView *nameEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *methodViewEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *ingredientsViewEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *storyEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *servesEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *cookingTimeEditableView;
@property(nonatomic,strong) CKEditingViewController *editingViewController;

//data
@property(nonatomic,assign) BOOL inEditMode;
@property(nonatomic,strong) NSArray *ingredientListData;
@property(nonatomic,strong) NSString *methodViewData;
@property(nonatomic,strong) NSString *recipeTitle;
@property(nonatomic,strong) NSString *servesData;
@property(nonatomic,strong) NSString *cookingTimeData;
@property(nonatomic,strong) NSString *storyData;

// delegates
@property(nonatomic, assign) id<BookModalViewControllerDelegate> modalDelegate;

@end

@implementation TestViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.ingredientListData = @[@"10 g:salt",@"10 g:sugar",@"200ml:water",@"2 cups:brandy",@"3 spoons:pepper",@"1 kg: flank steak",@"3 cups: lettuce"];
    self.methodViewData = @"Bacon ipsum dolor sit amet prosciutto sed non beef bresaola venison irure. Ball tip duis meatball, tri-tip anim esse bresaola culpa cillum dolor tenderloin capicola labore est. Brisket kielbasa minim ut cow, aliqua enim jowl capicola beef";
    self.recipeTitle = @"My Recipe title";
    self.storyData = @"This recipe reflects my innermost love for monkeys. and hamsters too. I love bacon";
    self.cookingTimeData = @"20 minutes";
    self.servesData = @"4-6";
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog();
    [super viewWillAppear:animated];
    [self config];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DLog();
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.servesEditableView enableEditMode:self.inEditMode];
    [self.cookingTimeEditableView enableEditMode:self.inEditMode];

    [editModeButton setTitle:self.inEditMode ? @"End Editing" : @"Start Editing" forState:UIControlStateNormal];
}

#pragma mark - Private Methods
-(void)config
{
    DLog();
    [self setRecipeNameValue:self.recipeTitle];
    [self setMethodValue:self.methodViewData];
    [self setIngredientsValue:[self.ingredientListData componentsJoinedByString:@"\n"]];
    [self setServesValue:self.servesData];
    [self setCookingTimeValue:self.cookingTimeData];
    [self setStoryValue:self.storyData];
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
        
        ingredientsEditingVC.ingredientList = [NSMutableArray arrayWithArray:self.ingredientListData];
        ingredientsEditingVC.editingTitle = @"INGREDIENTS";
        [ingredientsEditingVC enableEditing:YES completion:nil];
        
    } else if (view == self.servesEditableView) {
        CKTextFieldEditingViewController *textFieldEditingVC = [[CKTextFieldEditingViewController alloc] initWithDelegate:self sourceEditingView:self.servesEditableView];
        textFieldEditingVC.textAlignment = NSTextAlignmentCenter;
        textFieldEditingVC.view.frame = [self rootView].bounds;
        [self.view addSubview:textFieldEditingVC.view];
        self.editingViewController = textFieldEditingVC;
        UILabel *textFieldLabel = (UILabel *)self.servesEditableView.contentView;
        
        textFieldEditingVC.editableTextFont = [Theme bookCoverEditableAuthorTextFont];
        textFieldEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        textFieldEditingVC.characterLimit = 20;
        textFieldEditingVC.text = textFieldLabel.text;
        textFieldEditingVC.editingTitle = @"SERVES";
        [textFieldEditingVC enableEditing:YES completion:nil];
        
    } else if (view == self.cookingTimeEditableView) {
        CKTextFieldEditingViewController *textFieldEditingVC = [[CKTextFieldEditingViewController alloc] initWithDelegate:self sourceEditingView:self.cookingTimeEditableView];
        textFieldEditingVC.textAlignment = NSTextAlignmentCenter;
        textFieldEditingVC.view.frame = [self rootView].bounds;
        [self.view addSubview:textFieldEditingVC.view];
        self.editingViewController = textFieldEditingVC;
        
        UILabel *textFieldLabel = (UILabel *)self.cookingTimeEditableView.contentView;
        
        textFieldEditingVC.editableTextFont = [Theme bookCoverEditableAuthorTextFont];
        textFieldEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        textFieldEditingVC.characterLimit = 20;
        textFieldEditingVC.text = textFieldLabel.text;
        textFieldEditingVC.editingTitle = @"COOKING TIME";
        [textFieldEditingVC enableEditing:YES completion:nil];
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
    NSString *value = (NSString *)result;
    if (editingView == self.nameEditableView) {
        [self setRecipeNameValue:value];
        [self.nameEditableView enableEditMode:YES];
    } else if (editingView == self.methodViewEditableView) {
        [self setMethodValue:value];
        [self.methodViewEditableView enableEditMode:YES];
    } else if (editingView == self.ingredientsViewEditableView){
        [self setIngredientsValue:value];
        [self.ingredientsViewEditableView enableEditMode:YES];
    } else if (editingView == self.storyEditableView) {
        [self setStoryValue:value];
        [self.storyEditableView enableEditMode:YES];
    } else if (editingView == self.cookingTimeEditableView){
        [self setCookingTimeValue:value];
        [self.cookingTimeEditableView enableEditMode:YES];
    } else if (editingView == self.servesEditableView) {
        [self setServesValue:value];
        [self.servesEditableView enableEditMode:YES];
    } 
}

#pragma mark - BookModalViewController methods

- (void)setModalViewControllerDelegate:(id<BookModalViewControllerDelegate>)modalViewControllerDelegate {
    self.modalDelegate = modalViewControllerDelegate;
}

#pragma mark - Private Methods

-(UILabel*)configLabelForEditableView:(CKEditableView*)editableView withTextAlignment:(NSTextAlignment)textAlignment withFont:(UIFont*)viewFont  withColor:(UIColor*)color
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.autoresizingMask = UIViewAutoresizingNone;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = textAlignment;
    label.font = viewFont;
    label.textColor = color;
    label.numberOfLines = 0;
    editableView.delegate = self;
    editableView.contentInsets = kEditableInsets;

    return label;
}

-(void) configEditableView:(CKEditableView*)editableView withValue:(NSString*)value withFont:(UIFont*)viewFont  withColor:(UIColor*)color withTextAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = (UILabel *)editableView.contentView;
    
    if (!label) {
        label = [self configLabelForEditableView:editableView withTextAlignment:textAlignment withFont:viewFont withColor:color];
    }
    
    label.text = value;
    label.frame = editableView.frame;
    
    editableView.contentView = label;
}

- (void)setRecipeNameValue:(NSString *)recipeValue {
    [self configEditableView:self.nameEditableView withValue:recipeValue withFont:[Theme recipeNameFont]
                 withColor:[Theme recipeNameColor] withTextAlignment:NSTextAlignmentCenter];
}

- (void)setStoryValue:(NSString *)storyValue {
    
    [self configEditableView:self.storyEditableView withValue:storyValue withFont:[Theme storyFont] withColor:[Theme storyColor] withTextAlignment:NSTextAlignmentLeft];
}

- (void)setIngredientsValue:(NSString *)ingredientsValue {
    UILabel *label = (UILabel *)self.ingredientsViewEditableView.contentView;
    if (!label) {
        label = [self configLabelForEditableView:self.ingredientsViewEditableView withTextAlignment:NSTextAlignmentLeft withFont:[Theme ingredientsListFont]
                                       withColor:[Theme ingredientsListColor]];
    }

    label.text = ingredientsValue;
    CGSize constrainedSize = [ingredientsValue sizeWithFont:[Theme ingredientsListFont] constrainedToSize:
                        CGSizeMake(self.ingredientsViewEditableView.frame.size.width,
                                   self.ingredientsViewEditableView.frame.size.height)];
    
    label.frame = CGRectMake(self.ingredientsViewEditableView.frame.origin.x,
                             self.ingredientsViewEditableView.frame.origin.y,
                             self.ingredientsViewEditableView.frame.size.width,
                             constrainedSize.height);
    
    self.ingredientsViewEditableView.contentView = label;
    self.ingredientListData = [ingredientsValue componentsSeparatedByString:@"\n"];
}

- (void)setMethodValue:(NSString *)methodValue {
    UILabel *label = (UILabel *)self.methodViewEditableView.contentView;
    if (!label) {
        label = [self configLabelForEditableView:self.methodViewEditableView withTextAlignment:NSTextAlignmentLeft withFont:[Theme methodFont]
                                       withColor:[Theme methodColor]];
    }
    
    label.text = methodValue;
    CGSize constrainedSize = [methodValue sizeWithFont:[Theme methodFont] constrainedToSize:
                              CGSizeMake(self.methodViewEditableView.frame.size.width,
                                         self.methodViewEditableView.frame.size.height)];
    
    label.frame = CGRectMake(self.methodViewEditableView.frame.origin.x,
                             self.methodViewEditableView.frame.origin.y,
                             self.methodViewEditableView.frame.size.width,
                             constrainedSize.height);
    
    self.methodViewEditableView.contentView = label;
}

- (void)setCookingTimeValue:(NSString *)cookingTimeValue {
    
    [self configEditableView:self.cookingTimeEditableView withValue:cookingTimeValue withFont:[Theme cookingTimeFont] withColor:[Theme cookingTimeColor]
           withTextAlignment:NSTextAlignmentLeft];
}

- (void)setServesValue:(NSString *)servesValue {
    
    [self configEditableView:self.servesEditableView withValue:servesValue withFont:[Theme servesFont] withColor:[Theme servesColor] withTextAlignment:NSTextAlignmentLeft];
}

@end
