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
@interface TestViewController ()<CKEditableViewDelegate, CKEditingViewControllerDelegate>
@property(nonatomic,assign) BOOL inEditMode;
@property(nonatomic,strong) NSArray *ingredientListData;
@property(nonatomic,strong) NSString *testTextViewData;

@property(nonatomic,strong) IBOutlet CKEditableView *nameEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *methodViewEditableView;
@property(nonatomic,strong) IBOutlet CKEditableView *ingredientsViewEditableView;

@property(nonatomic,strong) CKEditingViewController *editingViewController;
@end

@implementation TestViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.ingredientListData = @[@"10 g:salt",@"10 g:sugar",@"200ml:water",@"2 cups:brandy",@"3 spoons:pepper",@"1 kg: flank steak",@"3 cups: lettuce"];
    self.testTextViewData = @"Bacon ipsum dolor sit amet prosciutto sed non beef bresaola venison irure. Ball tip duis meatball, tri-tip anim esse bresaola culpa cillum dolor tenderloin capicola labore est. Brisket kielbasa minim ut cow, aliqua enim jowl capicola beef";
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
    
    [editModeButton setTitle:self.inEditMode ? @"End Editing" : @"Start Editing" forState:UIControlStateNormal];
}

#pragma mark - Private Methods
-(void)config
{
    DLog();
    [self setLabelValue:@"initial value"];
    [self setMethodValue:self.testTextViewData];
    [self setIngredientsValue:[self.ingredientListData componentsJoinedByString:@"\n"]];
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
        textFieldEditingVC.editingTitle = @"LABEL NAME";
        [textFieldEditingVC enableEditing:YES completion:nil];
    } else if (view == self.methodViewEditableView){
        
        TextViewEditingViewController *textViewEditingVC = [[TextViewEditingViewController alloc] initWithDelegate:self sourceEditingView:self.methodViewEditableView];
        textViewEditingVC.view.frame = [self rootView].bounds;
        [self.view addSubview:textViewEditingVC.view];
        self.editingViewController = textViewEditingVC;
        
        textViewEditingVC.characterLimit = 300;
        UILabel *textViewLabel = (UILabel *)self.methodViewEditableView.contentView;
        textViewEditingVC.text = textViewLabel.text;
        textViewEditingVC.editingTitle = @"TEXT VIEW";
        [textViewEditingVC enableEditing:YES completion:nil];
    } else {
        IngredientsEditingViewController *ingredientsEditingVC = [[IngredientsEditingViewController alloc] initWithDelegate:self sourceEditingView:self.ingredientsViewEditableView];
        ingredientsEditingVC.view.frame = [self rootView].bounds;
        ingredientsEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        ingredientsEditingVC.characterLimit = 300;
        [self.view addSubview:ingredientsEditingVC.view];
        self.editingViewController = ingredientsEditingVC;
        
        ingredientsEditingVC.ingredientList = [NSMutableArray arrayWithArray:self.ingredientListData];
        ingredientsEditingVC.editingTitle = @"ingredients";
        [ingredientsEditingVC enableEditing:YES completion:nil];
        
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
        [self setLabelValue:value];
        [self.nameEditableView enableEditMode:YES];
    } else if (editingView == self.methodViewEditableView) {
        [self setMethodValue:value];
        [self.methodViewEditableView enableEditMode:YES];
    } else if (editingView == self.ingredientsViewEditableView){
        [self setIngredientsValue:value];
        [self.ingredientsViewEditableView enableEditMode:YES];
    }
}

#pragma mark - Private Methods

- (void)setLabelValue:(NSString *)labelValue {

    UILabel *nameLabel = (UILabel *)self.nameEditableView.contentView;
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.autoresizingMask = UIViewAutoresizingNone;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [Theme defaultFontWithSize:32.0f];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.numberOfLines = 0;

        self.nameEditableView.delegate = self;
        UIEdgeInsets editableInsets = UIEdgeInsetsMake(2.0, 2.0, 2.0f, 25.0f);
        self.nameEditableView.contentInsets = editableInsets;
        self.nameEditableView.backgroundColor = [UIColor clearColor];
        self.nameEditableView.contentView = nameLabel;
    }
    
    nameLabel.text = labelValue;
//    [nameLabel sizeToFit];
    
    self.nameEditableView.contentView = nameLabel;
}

- (void)setIngredientsValue:(NSString *)ingredientsValue {
    UIEdgeInsets editableInsets = UIEdgeInsetsMake(2.0, 10.0, 2.0f, 25.0f);
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
        self.ingredientsViewEditableView.contentInsets = editableInsets;
        self.ingredientsViewEditableView.backgroundColor = [UIColor clearColor];
    }
    
    ingredientsViewLabel.text = ingredientsValue;
    self.ingredientListData = [ingredientsValue componentsSeparatedByString:@"\n"];
    CGSize sizeConstraint = CGSizeMake(self.ingredientsViewEditableView.frame.size.width, self.ingredientsViewEditableView.frame.size.height);
    CGSize sizeConstainedToFont = [ingredientsValue sizeWithFont:ingredientsViewFont constrainedToSize:sizeConstraint];

    ingredientsViewLabel.frame = CGRectMake(self.ingredientsViewEditableView.frame.origin.x, self.ingredientsViewEditableView.frame.origin.y,
                                     sizeConstainedToFont.width, sizeConstainedToFont.height);
    self.ingredientsViewEditableView.contentView = ingredientsViewLabel;
}

- (void)setMethodValue:(NSString *)textViewValue {
    UIEdgeInsets editableInsets = UIEdgeInsetsMake(2.0, 2.0, 2.0f, 25.0f);

    UILabel *methodViewLabel = (UILabel *)self.methodViewEditableView.contentView;

    if (!methodViewLabel) {
        methodViewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        methodViewLabel.autoresizingMask = UIViewAutoresizingNone;
        methodViewLabel.backgroundColor = [UIColor clearColor];
        methodViewLabel.numberOfLines = 0;
        methodViewLabel.textAlignment = NSTextAlignmentLeft;
        methodViewLabel.font = [Theme defaultFontWithSize:20.0f];
        methodViewLabel.textColor = [UIColor blackColor];
        
        self.methodViewEditableView.delegate = self;
        self.methodViewEditableView.contentInsets = editableInsets;
        self.methodViewEditableView.backgroundColor = [UIColor clearColor];
        self.methodViewEditableView.contentView = methodViewLabel;
    }
    
    methodViewLabel.text = textViewValue;
//    CGSize textViewSize = CGSizeMake(329.0f,252.0f);
//    CGSize labelSize = [textViewValue sizeWithFont:textViewLabel.font constrainedToSize:textViewSize lineBreakMode:NSLineBreakByTruncatingTail];
//    textViewLabel.frame = CGRectMake(0.0f, 0.0f, labelSize.width, labelSize.height);

}
@end
