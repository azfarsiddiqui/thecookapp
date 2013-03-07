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
#import "IngredientEditKeyboardAccessoryView.h"
#import "Theme.h"
#import "ViewHelper.h"

#define kEditIngredientTableViewCell   @"EditIngredientTableViewCell"
#define kCellHeight 90.0f
#define kMaxLengthMeasurement 8
#define kMaxLengthDescription 25
@interface IngredientEditorViewController ()<UITableViewDataSource,UITableViewDelegate, EditableIngredientTableViewCellDelegate, IngredientEditKeyboardAccessoryViewDelegate>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,assign) UIEdgeInsets viewInsets;
@property(nonatomic,strong) IngredientEditKeyboardAccessoryView *ingredientEditKeyboardAccessoryView;
@property(nonatomic,assign) CGRect startingFrame;
@property(nonatomic,strong) UITextField *currentEditableTextField;
@property(nonatomic,strong) UILabel *limitLabel;
@property(nonatomic,assign) NSInteger descriptionCharacterLimit;
@property(nonatomic,assign) NSInteger measurementCharacterLimit;
@property(nonatomic,assign) BOOL isCurrentEditableTextFieldMeasurementField;
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
        self.ingredientEditKeyboardAccessoryView = [[IngredientEditKeyboardAccessoryView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 56.0f) delegate:self];
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

#pragma mark - EditableIngredientTableViewCellDelegate

-(void)didUpdateIngredientAtRowIndex:(NSNumber *)rowIndex withMeasurement:(NSString *)measurementString description:(NSString *)ingredientDescription
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[rowIndex intValue] inSection:0];
    [self.ingredientEditorDelegate didUpdateMeasurement:measurementString ingredient:ingredientDescription atRowIndex:indexPath.row + self.selectedIndex];
}

-(void)didSelectTextFieldForEditing:(UITextField *)textField isMeasurementField:(BOOL)isMeasurementField
{
    self.currentEditableTextField = textField;
    self.isCurrentEditableTextFieldMeasurementField = isMeasurementField;
    self.currentEditableTextField.inputAccessoryView = (self.isCurrentEditableTextFieldMeasurementField) ? self.ingredientEditKeyboardAccessoryView: nil;
    
    [self updateCharacterLimit:self.currentEditableTextField.text.length];
}

-(NSInteger)characterLimitForCurrentEditableTextField
{
    return self.isCurrentEditableTextFieldMeasurementField ? kMaxLengthMeasurement : kMaxLengthDescription;
}

-(BOOL) requestedUpdateForCurrentEditableTextField:(NSString*)newTextFieldValue
{
    NSInteger characterLimit = [self characterLimitForCurrentEditableTextField];
    if ([self.currentEditableTextField.text length] >= characterLimit) {
        return NO;
    }
    
    [self updateCharacterLimit:[newTextFieldValue length]];

    return YES;
}

- (void)updateCharacterLimit:(NSInteger)textFieldLength {
    
    if (!self.limitLabel) {
        UILabel *limitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        limitLabel.backgroundColor = [UIColor clearColor];
        limitLabel.font = [Theme bookCoverEditableFieldDescriptionFont];
        limitLabel.textColor = [UIColor whiteColor];
        limitLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        limitLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [self.view addSubview:limitLabel];
        self.limitLabel = limitLabel;
        self.limitLabel.frame = CGRectMake(590.0f,
                                           17.0f,
                                           self.limitLabel.frame.size.width,
                                           self.limitLabel.frame.size.height);

    }
    int availableLimit = [self characterLimitForCurrentEditableTextField] - textFieldLength;
    self.limitLabel.text = [NSString stringWithFormat:@"%d",  availableLimit];

    [self.limitLabel sizeToFit];
}
#pragma mark - System Notification events
- (void)keyboardWillShow:(NSNotification *)notification {
    UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat verticalOffset = -self.startingFrame.origin.y;
    
    CGAffineTransform shiftTransform = CGAffineTransformMakeTranslation(0.0, verticalOffset);
    
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system.
    // The bottom of the text view's frame should align with the top of the keyboard's final position.
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect accessoryViewFrame = self.ingredientEditKeyboardAccessoryView.frame;
    accessoryViewFrame.origin.y = keyboardTop - accessoryViewFrame.size.height;
    self.ingredientEditKeyboardAccessoryView.frame = accessoryViewFrame;
    
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
    Ingredient *ingredient = [self.ingredientList objectAtIndex:adjustedIndex];
    EditableIngredientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEditIngredientTableViewCell];
    [cell configureCellWithIngredient:ingredient forRowAtIndex:[NSNumber numberWithInt:indexPath.row] editDelegate:self];
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

#pragma mark - IngredientEditKeyboardAccessoryViewDelegate

-(void)didEnterMeasurementShortCut:(NSString *)name isAmount:(BOOL)isAmount
{
    DLog(@"short cut %@", name);
    NSString *newValue = [NSString stringWithFormat:@"%@%@",self.currentEditableTextField.text,[name lowercaseString]];
    NSInteger characterLimit = [self characterLimitForCurrentEditableTextField];
    if (newValue.length < characterLimit) {
        self.currentEditableTextField.text = newValue;
        [self updateCharacterLimit:[newValue length]];
    }
    
    if (isAmount) {
        EditableIngredientTableViewCell *firstCell = [[self.tableView visibleCells]objectAtIndex:0];
        [firstCell requestDescriptionTextFieldEdit];
    }
}
@end
