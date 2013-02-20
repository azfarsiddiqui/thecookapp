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
    [self dismissViewControllerAnimated:YES completion:^{
    }];
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
        
        textViewEditingVC.characterLimit = 300;
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
        CKTextFieldEditingViewController *textFieldEditingVC = [[CKTextFieldEditingViewController alloc] initWithDelegate:self sourceEditingView:self.storyEditableView];
        textFieldEditingVC.textAlignment = NSTextAlignmentCenter;
        textFieldEditingVC.view.frame = [self rootView].bounds;
        [self.view addSubview:textFieldEditingVC.view];
        self.editingViewController = textFieldEditingVC;
        UILabel *textFieldLabel = (UILabel *)self.storyEditableView.contentView;
        
        textFieldEditingVC.editableTextFont = [Theme bookCoverEditableAuthorTextFont];
        textFieldEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        textFieldEditingVC.characterLimit = 20;
        textFieldEditingVC.text = textFieldLabel.text;
        textFieldEditingVC.editingTitle = @"RECIPE STORY";
        [textFieldEditingVC enableEditing:YES completion:nil];
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

#pragma mark - Private Methods

- (void)setRecipeNameValue:(NSString *)recipeValue {

    UIFont *recipeNameViewFont = [Theme recipeNameFont];
    UILabel *recipeNameLabel = (UILabel *)self.nameEditableView.contentView;
    
    if (!recipeNameLabel) {
        recipeNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        recipeNameLabel.autoresizingMask = UIViewAutoresizingNone;
        recipeNameLabel.backgroundColor = [UIColor clearColor];
        recipeNameLabel.textAlignment = NSTextAlignmentCenter;
        recipeNameLabel.font = recipeNameViewFont;
        //TODO style as defined for name
        recipeNameLabel.textColor = [Theme recipeNameColor];
        recipeNameLabel.numberOfLines = 0;

        self.nameEditableView.delegate = self;
        self.nameEditableView.contentInsets = kEditableInsets;
    }
    
    recipeNameLabel.text = recipeValue;
    recipeNameLabel.frame = CGRectMake(self.nameEditableView.frame.origin.x, self.nameEditableView.frame.origin.y,
                                       self.nameEditableView.frame.size.width - kEditableInsets.left-kEditableInsets.right,
                                       self.nameEditableView.frame.size.height - kEditableInsets.top-kEditableInsets.bottom);

    self.nameEditableView.contentView = recipeNameLabel;
}

- (void)setStoryValue:(NSString *)storyValue {
    
    UIFont *storyViewFont = [Theme storyFont];
    UILabel *storyLabel = (UILabel *)self.storyEditableView.contentView;
    
    if (!storyLabel) {
        storyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        storyLabel.autoresizingMask = UIViewAutoresizingNone;
        storyLabel.backgroundColor = [UIColor clearColor];
        storyLabel.textAlignment = NSTextAlignmentCenter;
        storyLabel.font = storyViewFont;
        storyLabel.textColor = [Theme storyColor];
        storyLabel.numberOfLines = 0;
        
        self.storyEditableView.delegate = self;
        self.storyEditableView.contentInsets = kEditableInsets;
    }
    storyLabel.text = storyValue;
    storyLabel.frame = CGRectMake(self.storyEditableView.frame.origin.x, self.storyEditableView.frame.origin.y,
                                       self.storyEditableView.frame.size.width - kEditableInsets.left-kEditableInsets.right,
                                       self.storyEditableView.frame.size.height - kEditableInsets.top-kEditableInsets.bottom);
    
    self.storyEditableView.contentView = storyLabel;
}

- (void)setIngredientsValue:(NSString *)ingredientsValue {
    UIFont *ingredientsViewFont = [Theme ingredientsListFont];
    UILabel *ingredientsViewLabel = (UILabel *)self.ingredientsViewEditableView.contentView;

    if (!ingredientsViewLabel) {
        ingredientsViewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        ingredientsViewLabel.autoresizingMask = UIViewAutoresizingNone;
        ingredientsViewLabel.backgroundColor = [UIColor clearColor];
        ingredientsViewLabel.textAlignment = NSTextAlignmentLeft;
        ingredientsViewLabel.font = ingredientsViewFont;
        ingredientsViewLabel.textColor = [Theme ingredientsListColor];
        ingredientsViewLabel.numberOfLines = 0;
        
        self.ingredientsViewEditableView.delegate = self;
        self.ingredientsViewEditableView.contentInsets = kEditableInsets;
    }
    
    ingredientsViewLabel.text = ingredientsValue;
    self.ingredientListData = [ingredientsValue componentsSeparatedByString:@"\n"];
    ingredientsViewLabel.frame = CGRectMake(self.ingredientsViewEditableView.frame.origin.x, self.ingredientsViewEditableView.frame.origin.y,
                                  self.ingredientsViewEditableView.frame.size.width - kEditableInsets.left-kEditableInsets.right,
                                  self.ingredientsViewEditableView.frame.size.height - kEditableInsets.top-kEditableInsets.bottom);
    self.ingredientsViewEditableView.contentView = ingredientsViewLabel;
}

- (void)setMethodValue:(NSString *)methodValue {
    UIFont *methodViewFont = [Theme methodFont];
    UILabel *methodViewLabel = (UILabel *)self.methodViewEditableView.contentView;
    if (!methodViewLabel) {
        methodViewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        methodViewLabel.autoresizingMask = UIViewAutoresizingNone;
        methodViewLabel.backgroundColor = [UIColor clearColor];
        methodViewLabel.numberOfLines = 0;
        methodViewLabel.textAlignment = NSTextAlignmentLeft;
        methodViewLabel.font = methodViewFont;
        methodViewLabel.textColor = [Theme methodColor];
        
        self.methodViewEditableView.delegate = self;
        self.methodViewEditableView.contentInsets = kEditableInsets;
    }
    
    methodViewLabel.text = methodValue;
    methodViewLabel.frame = CGRectMake(self.methodViewEditableView.frame.origin.x, self.methodViewEditableView.frame.origin.y,
                                            self.methodViewEditableView.frame.size.width - kEditableInsets.left-kEditableInsets.right,
                                            self.methodViewEditableView.frame.size.height - kEditableInsets.top-kEditableInsets.bottom);
    self.methodViewEditableView.contentView = methodViewLabel;

}

- (void)setCookingTimeValue:(NSString *)cookingTimeValue {
    
    UIFont *cookingTimeFont = [Theme cookingTimeFont];
    UILabel *cookingTimeLabel = (UILabel *)self.cookingTimeEditableView.contentView;
    
    if (!cookingTimeLabel) {
        cookingTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        cookingTimeLabel.autoresizingMask = UIViewAutoresizingNone;
        cookingTimeLabel.backgroundColor = [UIColor clearColor];
        cookingTimeLabel.font = cookingTimeFont;
        cookingTimeLabel.textColor = [Theme cookingTimeColor];
        cookingTimeLabel.numberOfLines = 0;
        
        self.cookingTimeEditableView.delegate = self;
        self.cookingTimeEditableView.contentInsets = kEditableInsets;
    }
    
    cookingTimeLabel.text = cookingTimeValue;
    cookingTimeLabel.frame = CGRectMake(self.cookingTimeEditableView.frame.origin.x, self.cookingTimeEditableView.frame.origin.y,
                                       self.cookingTimeEditableView.frame.size.width - kEditableInsets.left-kEditableInsets.right,
                                       self.cookingTimeEditableView.frame.size.height - kEditableInsets.top-kEditableInsets.bottom);
    self.cookingTimeEditableView.contentView = cookingTimeLabel;
}

- (void)setServesValue:(NSString *)servesValue {
    
    UIFont *servesFont = [Theme servesFont];
    UILabel *servesLabel = (UILabel *)self.servesEditableView.contentView;
    
    if (!servesLabel) {
        servesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        servesLabel.autoresizingMask = UIViewAutoresizingNone;
        servesLabel.backgroundColor = [UIColor clearColor];
        servesLabel.font = servesFont;
        servesLabel.textColor = [Theme servesColor];
        servesLabel.numberOfLines = 0;
        
        self.servesEditableView.delegate = self;
        self.servesEditableView.contentInsets = kEditableInsets;
    }
    
    servesLabel.text = servesValue;
    servesLabel.frame = CGRectMake(self.servesEditableView.frame.origin.x, self.servesEditableView.frame.origin.y,
                                        self.servesEditableView.frame.size.width - kEditableInsets.left-kEditableInsets.right,
                                        self.servesEditableView.frame.size.height - kEditableInsets.top-kEditableInsets.bottom);
    
    self.servesEditableView.contentView = servesLabel;
}

@end
