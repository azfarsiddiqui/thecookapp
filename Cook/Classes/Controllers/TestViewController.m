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
#import "Theme.h"
@interface TestViewController ()<CKEditableViewDelegate, CKEditingViewControllerDelegate>
@property(nonatomic,assign) BOOL inEditMode;
@property(nonatomic,strong) NSArray *testListData;
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
    self.testListData = @[@"list entry one",@"list entry two",@"list entry three",@"list entry four",@"list entry five",@"list entry six",@"list entry seven"];
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

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.testListData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableViewCellIdentifier = @"tableviewcellidentifier";
    NSString *data = [self.testListData objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.textLabel.text = data;
    return cell;
}

#pragma mark - Private Methods
-(void)config
{
    DLog();
    [self setLabelValue:@"initial value"];
    [self setTextViewValue:self.testTextViewData];
    [self setListViewValue:[self.testListData componentsJoinedByString:@"\n"]];
}

- (UIView *)rootView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

#pragma mark - CKEditableViewDelegate

-(void)editableViewEditRequestedForView:(UIView *)view
{

    if (view == self.labelEditableView) {
        CKTextFieldEditingViewController *textFieldEditingViewController = [[CKTextFieldEditingViewController alloc] initWithDelegate:self];
        textFieldEditingViewController.textAlignment = NSTextAlignmentCenter;
        textFieldEditingViewController.view.frame = [self rootView].bounds;
        [self.view addSubview:textFieldEditingViewController.view];
        self.editingViewController = textFieldEditingViewController;
        
        UILabel *testLabel = (UILabel *)self.labelEditableView.contentView;
        
        textFieldEditingViewController.editableTextFont = [Theme bookCoverEditableAuthorTextFont];
        textFieldEditingViewController.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        textFieldEditingViewController.characterLimit = 20;
        textFieldEditingViewController.text = testLabel.text;
        textFieldEditingViewController.sourceEditingView = self.labelEditableView;
        textFieldEditingViewController.editingTitle = @"LABEL NAME";
        [textFieldEditingViewController enableEditing:YES completion:nil];
    } else if (view == self.textViewEditableView){
        
        TextViewEditingViewController *textViewEditingController = [[TextViewEditingViewController alloc] initWithDelegate:self];
        textViewEditingController.view.frame = [self rootView].bounds;
        [self.view addSubview:textViewEditingController.view];
        self.editingViewController = textViewEditingController;
        
        UILabel *testLabel = (UILabel *)self.textViewEditableView.contentView;
        textViewEditingController.characterLimit = 300;
        textViewEditingController.text = testLabel.text;
        
        textViewEditingController.sourceEditingView = self.textViewEditableView;
        textViewEditingController.editingTitle = @"TEXT VIEW";
        [textViewEditingController enableEditing:YES completion:nil];
    } else {
        DLog(@"edit requested for list");
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
    if (editingView == self.labelEditableView) {
        NSString *value = (NSString *)result;
        [self setLabelValue:value];
        [self.labelEditableView enableEditMode:YES];
    } else if (editingView == self.textViewEditableView) {
        NSString *value = (NSString *)result;
        [self setTextViewValue:value];
        [self.textViewEditableView enableEditMode:YES];
        
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
