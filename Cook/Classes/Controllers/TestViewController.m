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
#import "Theme.h"
@interface TestViewController ()<UITableViewDataSource, UITableViewDelegate, CKEditableViewDelegate, CKEditingViewControllerDelegate>
@property(nonatomic,assign) BOOL inEditMode;
@property(nonatomic,strong) NSArray *testListData;

@property(nonatomic,strong) CKEditableView *testEditableView;
@property(nonatomic,strong) CKTextFieldEditingViewController *textEditingViewController;
@end

@implementation TestViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.testListData = @[@"list entry one",@"list entry two",@"list entry three",@"list entry four",@"list entry five",@"list entry six",@"list entry seven"];
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
 
    [self.testEditableView enableEditMode:self.inEditMode];
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
}

- (UIView *)rootView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

#pragma mark - CKEditableViewDelegate

-(void)editableViewEditRequestedForView:(UIView *)view
{
    CKTextFieldEditingViewController *editingViewController = [[CKTextFieldEditingViewController alloc] initWithDelegate:self];
    editingViewController.textAlignment = NSTextAlignmentCenter;
    editingViewController.view.frame = [self rootView].bounds;
    [self.view addSubview:editingViewController.view];
    self.textEditingViewController = editingViewController;
    
    if (view == self.testEditableView) {
        UILabel *testLabel = (UILabel *)self.testEditableView.contentView;
        editingViewController.editableTextFont = [Theme bookCoverEditableAuthorTextFont];
        editingViewController.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        editingViewController.characterLimit = 20;
        editingViewController.text = testLabel.text;
        editingViewController.sourceEditingView = self.testEditableView;
        editingViewController.editingTitle = @"TEST LABEL";
        [editingViewController enableEditing:YES completion:nil];
    }

}

#pragma mark CKEditableViewControllerDelegate
- (void)editingViewWillAppear:(BOOL)appear {
    
}

- (void)editingViewDidAppear:(BOOL)appear {
    if (!appear) {
        [self.textEditingViewController.view removeFromSuperview];
        self.textEditingViewController = nil;
    }
}

-(void)editingView:(UIView *)editingView saveRequestedWithResult:(id)result {
    if (editingView == self.testEditableView) {
        NSString *value = (NSString *)result;
        [self setLabelValue:value];
        [self.testEditableView enableEditMode:YES];
    }


}

#pragma mark - Private Methods

- (void)setLabelValue:(NSString *)labelValue {
//    self.authorValue = author;
    
//    UIFont *font = [Theme bookCoverViewModeAuthorFont];
    UIEdgeInsets editableInsets = UIEdgeInsetsMake(2.0, 2.0, 2.0f, 25.0f);
    CGSize availableSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);    
    if (!self.testEditableView) {
        UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        testLabel.autoresizingMask = UIViewAutoresizingNone;
        testLabel.backgroundColor = [UIColor clearColor];
        testLabel.font = [Theme defaultFontWithSize:32.0f];
        testLabel.textColor = [UIColor blackColor];

        CKEditableView *testEditableView = [[CKEditableView alloc] initWithDelegate:self];
        testEditableView.contentInsets = editableInsets;
        testEditableView.backgroundColor = [UIColor clearColor];
        testEditableView.contentView = testLabel;
        [self.view addSubview:testEditableView];
        self.testEditableView = testEditableView;
    }
    
    
    UILabel *testLabel = (UILabel *)self.testEditableView.contentView;
    testLabel.textAlignment = NSTextAlignmentCenter;
    testLabel.text = labelValue;
    [testLabel sizeToFit];
//    testLabel.frame = CGRectMake(0.0, 0.0, availableSize.width, testLabel.frame.size.height);

    self.testEditableView.contentView = testLabel;
//    self.testEditableView.frame = [self authorEditableAdjustedFrameWithSize:self.testEditableView.frame.size];
//    self.testEditableView.frame = CGRectMake(517.0f, 208.f, 322.0f, 45.0f);
    
    self.testEditableView.frame = CGRectMake(517.0f, 208.f, self.testEditableView.frame.size.width, self.testEditableView.frame.size.height);
}
@end
