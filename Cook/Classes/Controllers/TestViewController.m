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

@property(nonatomic,strong) CKEditableView *labelEditableView;
@property(nonatomic,strong) CKEditableView *textViewEditableView;
@property(nonatomic,strong) CKEditableView *listViewEditableView;
@property(nonatomic,strong) CKEditingViewController *editingViewController;
@end

@implementation TestViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.ingredientListData = @[@"list entry one",@"list entry two",@"list entry three",@"list entry four",@"list entry five",@"list entry six",@"list entry seven"];
    self.testTextViewData = @"Bacon ipsum dolor sit amet prosciutto sed non beef bresaola venison irure. Ball tip duis meatball, tri-tip anim esse bresaola culpa cillum dolor tenderloin capicola labore est. Brisket kielbasa minim ut cow, aliqua enim jowl capicola beef";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	DLog();
    [self config];

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
    [self.labelEditableView enableEditMode:self.inEditMode];
    [self.textViewEditableView enableEditMode:self.inEditMode];
    [self.listViewEditableView enableEditMode:self.inEditMode];
    
    [editModeButton setTitle:self.inEditMode ? @"End Editing" : @"Start Editing" forState:UIControlStateNormal];
}

#pragma mark - Private Methods
-(void)config
{
    DLog();
    [self setLabelValue:@"initial value"];
    [self setTextViewValue:self.testTextViewData];
    [self setListViewValue:[self.ingredientListData componentsJoinedByString:@"\n"]];
}

- (UIView *)rootView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

#pragma mark - CKEditableViewDelegate

-(void)editableViewEditRequestedForView:(UIView *)view
{

    if (view == self.labelEditableView) {
        CKTextFieldEditingViewController *textFieldEditingVC = [[CKTextFieldEditingViewController alloc] initWithDelegate:self sourceEditingView:self.labelEditableView];
        textFieldEditingVC.textAlignment = NSTextAlignmentCenter;
        textFieldEditingVC.view.frame = [self rootView].bounds;
        [self.view addSubview:textFieldEditingVC.view];
        self.editingViewController = textFieldEditingVC;
        UILabel *textFieldLabel = (UILabel *)self.labelEditableView.contentView;
        
        textFieldEditingVC.editableTextFont = [Theme bookCoverEditableAuthorTextFont];
        textFieldEditingVC.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        textFieldEditingVC.characterLimit = 20;
        textFieldEditingVC.text = textFieldLabel.text;
        textFieldEditingVC.editingTitle = @"LABEL NAME";
        [textFieldEditingVC enableEditing:YES completion:nil];
    } else if (view == self.textViewEditableView){
        
        TextViewEditingViewController *textViewEditingVC = [[TextViewEditingViewController alloc] initWithDelegate:self sourceEditingView:self.textViewEditableView];
        textViewEditingVC.view.frame = [self rootView].bounds;
        [self.view addSubview:textViewEditingVC.view];
        self.editingViewController = textViewEditingVC;
        
        textViewEditingVC.characterLimit = 300;
        UILabel *textViewLabel = (UILabel *)self.textViewEditableView.contentView;
        textViewEditingVC.text = textViewLabel.text;
        textViewEditingVC.editingTitle = @"TEXT VIEW";
        [textViewEditingVC enableEditing:YES completion:nil];
    } else {
        IngredientsEditingViewController *ingredientsEditingVC = [[IngredientsEditingViewController alloc] initWithDelegate:self sourceEditingView:self.listViewEditableView];
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
    if (editingView == self.labelEditableView) {
        [self setLabelValue:value];
        [self.labelEditableView enableEditMode:YES];
    } else if (editingView == self.textViewEditableView) {
        [self setTextViewValue:value];
        [self.textViewEditableView enableEditMode:YES];
    } {
        [self setListViewValue:value];
        [self.listViewEditableView enableEditMode:YES];
    }
}

#pragma mark - Private Methods

- (void)setLabelValue:(NSString *)labelValue {
    UIEdgeInsets editableInsets = UIEdgeInsetsMake(2.0, 2.0, 2.0f, 25.0f);
    if (!self.labelEditableView) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.autoresizingMask = UIViewAutoresizingNone;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [Theme defaultFontWithSize:32.0f];
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 0;

        CKEditableView *testEditableView = [[CKEditableView alloc] initWithDelegate:self];
        testEditableView.contentInsets = editableInsets;
        testEditableView.backgroundColor = [UIColor clearColor];
        testEditableView.contentView = label;
        [self.view addSubview:testEditableView];
        self.labelEditableView = testEditableView;
    }
    
    UILabel *testLabel = (UILabel *)self.labelEditableView.contentView;
    testLabel.text = labelValue;
    [testLabel sizeToFit];
    self.labelEditableView.contentView = testLabel;
    self.labelEditableView.frame = CGRectMake(517.0f, 208.f, self.labelEditableView.frame.size.width, self.labelEditableView.frame.size.height);
}

- (void)setListViewValue:(NSString *)listViewValue {
    UIEdgeInsets editableInsets = UIEdgeInsetsMake(2.0, 10.0, 2.0f, 25.0f);
    UIFont *listViewFont = [Theme defaultFontWithSize:20.0f];
    if (!self.listViewEditableView) {
        UILabel *listViewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        listViewLabel.autoresizingMask = UIViewAutoresizingNone;
        listViewLabel.backgroundColor = [UIColor clearColor];
        listViewLabel.textAlignment = NSTextAlignmentLeft;
        listViewLabel.font = listViewFont;
        listViewLabel.textColor = [UIColor blackColor];
        listViewLabel.numberOfLines = 0;

        CKEditableView *listViewEditableView = [[CKEditableView alloc] initWithDelegate:self];
        listViewEditableView.contentInsets = editableInsets;
        listViewEditableView.backgroundColor = [UIColor clearColor];
        listViewEditableView.contentView = listViewLabel;
        [self.view addSubview:listViewEditableView];
        self.listViewEditableView = listViewEditableView;
        
    }
    
    UILabel *listViewLabel = (UILabel *)self.listViewEditableView.contentView;
    listViewLabel.text = listViewValue;
    self.ingredientListData = [listViewValue componentsSeparatedByString:@"\n"];
    CGSize listViewSizeConstraint = CGSizeMake(260.0f, 268.0f);
    CGSize listViewLabelSize = [listViewValue sizeWithFont:listViewFont constrainedToSize:listViewSizeConstraint];
    listViewLabel.frame = CGRectMake(0.0f, 0.0f, listViewLabelSize.width, listViewLabelSize.height);
    
    self.listViewEditableView.contentView = listViewLabel;
    self.listViewEditableView.frame = CGRectMake(10.0f, 208.f, listViewSizeConstraint.width, listViewSizeConstraint.height);
}


- (void)setTextViewValue:(NSString *)textViewValue {
    UIEdgeInsets editableInsets = UIEdgeInsetsMake(2.0, 2.0, 2.0f, 25.0f);
    CGSize textViewSize = CGSizeMake(329.0f,252.0f);

    if (!self.textViewEditableView) {
        UILabel *textviewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textviewLabel.autoresizingMask = UIViewAutoresizingNone;
        textviewLabel.backgroundColor = [UIColor clearColor];
        textviewLabel.numberOfLines = 0;
        textviewLabel.textAlignment = NSTextAlignmentLeft;
        textviewLabel.font = [Theme defaultFontWithSize:20.0f];
        textviewLabel.textColor = [UIColor blackColor];
        
        CKEditableView *textEditableView = [[CKEditableView alloc] initWithDelegate:self];
        textEditableView.contentInsets = editableInsets;
        textEditableView.backgroundColor = [UIColor clearColor];
        textEditableView.contentView = textviewLabel;
        [self.view addSubview:textEditableView];
        self.textViewEditableView = textEditableView;
    }
    
    UILabel *textViewLabel = (UILabel *)self.textViewEditableView.contentView;
    textViewLabel.text = textViewValue;
    CGSize labelSize = [textViewValue sizeWithFont:textViewLabel.font constrainedToSize:textViewSize lineBreakMode:NSLineBreakByTruncatingTail];
    textViewLabel.frame = CGRectMake(0.0f, 0.0f, labelSize.width, labelSize.height);
    self.textViewEditableView.contentView = textViewLabel;
    //absolute positioning
    self.textViewEditableView.frame = CGRectMake(517.0f, 276.0f,self.textViewEditableView.frame.size.width, self.textViewEditableView.frame.size.height);
}
@end
