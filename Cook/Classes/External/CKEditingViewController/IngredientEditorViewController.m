//
//  IngredientEditorViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientEditorViewController.h"
#import "IngredientTableViewCell.h"
#import "EditableIngredientTableViewCell.h"
#import "ViewHelper.h"

#define kEditIngredientTableViewCell   @"EditIngredientTableViewCell"
#define kCellHeight 90.0f

@interface IngredientEditorViewController ()<UITableViewDataSource,UITableViewDelegate, IngredientEditTableViewCellDelegate>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,assign) UIEdgeInsets viewInsets;
@property(nonatomic,assign) CGRect startingFrame;
@property(nonatomic,strong) UITextField *currentEditableTextField;
@end

@implementation IngredientEditorViewController

-(id)initWithFrame:(CGRect)frame withViewInsets:(UIEdgeInsets)viewInsets startingAtFrame:(CGRect)startingFrame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.5f];
        self.startingFrame = startingFrame;
        self.viewInsets = viewInsets;
        [self config];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    EditableIngredientTableViewCell *firstCell = [[self.tableView visibleCells]objectAtIndex:0];
    [firstCell requestMeasurementTextFieldEdit];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateFrameSize:(CGRect)frame forExpansion:(BOOL)expansion
{
    self.view.frame = frame;
    CGRect tableViewframe = CGRectZero;
    if (expansion) {
        tableViewframe = CGRectMake(self.viewInsets.left,
                                    self.viewInsets.top,
                                    frame.size.width - self.viewInsets.left - self.viewInsets.right,
                                    frame.size.height - self.viewInsets.top - self.viewInsets.bottom);
    } else {
        tableViewframe = CGRectMake(0,
                                    0,
                                    frame.size.width,
                                    frame.size.height);
    }
    self.tableView.frame = tableViewframe;
    
}

#pragma mark - IngredientEditDelegate

-(void)didUpdateIngredientAtRowIndex:(NSNumber *)rowIndex withMeasurement:(NSString *)measurementString description:(NSString *)ingredientDescription
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[rowIndex intValue] inSection:0];
    [self.ingredientEditorDelegate didUpdateIngredient:ingredientDescription atRowIndex:indexPath.row + self.selectedIndex];
}

-(void)didSelectTextFieldForEditing:(UITextField *)textField
{
    self.currentEditableTextField = textField;
}

#pragma mark - System Notification events
- (void)keyboardWillShow:(NSNotification *)notification {
    UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat verticalOffset = -self.startingFrame.origin.y;
    
    CGAffineTransform shiftTransform = CGAffineTransformMakeTranslation(0.0, verticalOffset);
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:curve
                     animations:^{
                         self.tableView.transform = shiftTransform;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    DLog();
    UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGAffineTransform shiftTransform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:curve
                     animations:^{
                         self.tableView.transform = shiftTransform;
                     }
                     completion:^(BOOL finished) {
                         [self.ingredientEditorDelegate didRequestIngredientEditorViewDismissal];
                     }];
    
}
#pragma mark - Private Methods

-(void)config
{
    [self addTableView];
    
    self.tableView.frame = CGRectMake(self.viewInsets.left,
                                        self.startingFrame.origin.y + self.viewInsets.top,
                                        self.view.bounds.size.width - self.viewInsets.left - self.viewInsets.right,
                                        self.view.bounds.size.height - self.viewInsets.top - self.viewInsets.bottom);
}

#pragma mark - UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ingredientList count] - self.selectedIndex;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger adjustedIndex = self.selectedIndex + indexPath.row;
    NSString *data = [self.ingredientList objectAtIndex:adjustedIndex];
    EditableIngredientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEditIngredientTableViewCell];
    [cell configureCellWithText:data forRowAtIndex:[NSNumber numberWithInt:indexPath.row] editDelegate:self];
    return cell;
}

-(void) addTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)
                                                          style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor =[UIColor blackColor];
    [tableView registerClass:[EditableIngredientTableViewCell class] forCellReuseIdentifier:kEditIngredientTableViewCell];
    self.tableView = tableView;
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //dismiss for any rows other than the first one
    if (indexPath.row!=0&&self.currentEditableTextField) {
        [self.currentEditableTextField resignFirstResponder];
    }
}
@end
