//
//  IngredientsEditingViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/4/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientsEditingViewController.h"
#import "IngredientEditorViewController.h"
#import "CKTextFieldEditingViewController.h"
#import "IngredientTableViewCell.h"
#import "IngredientConstants.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>

#define kIngredientsTableViewCell   @"IngredientsTableViewCell"
#define kTableViewInsets            UIEdgeInsetsMake(50.0, 50.0, 50.0, 50.0)

typedef enum {
    IngredientEditingIngredients,
    IngredientEditingNoIngredients
} IngredientEditing;

@interface IngredientsEditingViewController () <UITableViewDataSource,UITableViewDelegate, IngredientEditorDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) IngredientEditorViewController *ingredientEditingViewController;
@property (nonatomic, assign) CGRect ingredientTapStartingPoint;
@property (nonatomic, assign) IngredientEditing ingredientsEditing;
@end

@implementation IngredientsEditingViewController

#pragma mark - CKEditingViewController methods

- (UIView *)createTargetEditingView {
    return [self newTableView];
}

- (void)editingViewWillAppear:(BOOL)appear {
    if (!appear) {
        [self.titleLabel removeFromSuperview];
        [self.doneButton removeFromSuperview];
    }
    [super editingViewWillAppear:appear];
}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    if (appear) {
        [self addSubviews];
    }
}

-(void)setIngredientList:(NSArray *)ingredientList
{
    _ingredientList = [NSMutableArray arrayWithArray:ingredientList];
    self.ingredientsEditing = [_ingredientList count] == 0 ? IngredientEditingNoIngredients : IngredientEditingIngredients;
}
#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 1 row when there are no ingredients
    return self.ingredientsEditing == IngredientEditingIngredients ? self.ingredientList.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    if (self.ingredientsEditing == IngredientEditingNoIngredients) {
        Ingredient *ingredient = [[Ingredient alloc]init];
        [self.ingredientList addObject:ingredient];
        self.ingredientsEditing = IngredientEditingIngredients;
    }
    
    Ingredient *ingredient = [self.ingredientList objectAtIndex:indexPath.row];

    IngredientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIngredientsTableViewCell];
    [cell configureCellWithIngredient:ingredient forRowAtIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.ingredientTapStartingPoint = [tableView rectForRowAtIndexPath:indexPath];
    
    IngredientEditorViewController *ingredientEditorViewController = [[IngredientEditorViewController alloc]initWithFrame:self.view.bounds
                                                                                                            withViewInsets:kTableViewInsets
                                                                                                           startingAtFrame:self.ingredientTapStartingPoint];
    ingredientEditorViewController.ingredientList = self.ingredientList;
    ingredientEditorViewController.selectedIndex = indexPath.row;
    ingredientEditorViewController.ingredientEditorDelegate = self;
    [self.view addSubview:ingredientEditorViewController.view];
    self.ingredientEditingViewController = ingredientEditorViewController;
}

#pragma mark - IngredientEditorDelegate

-(void)didUpdateMeasurement:(NSString *)measurementText ingredient:(NSString *)ingredientDescription atRowIndex:(NSInteger)rowIndex
{
    Ingredient *ingredient = [self.ingredientList objectAtIndex:rowIndex];
    ingredient.measurement = measurementText;
    ingredient.name = ingredientDescription;

    UITableView *tableView = (UITableView *)self.targetEditingView;
    [tableView reloadData];
    
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:self.ingredientList];
}

-(void)didRequestIngredientEditorViewDismissal
{
    if (self.ingredientEditingViewController) {
        [self.ingredientEditingViewController.view removeFromSuperview];
        self.ingredientEditingViewController = nil;
        self.ingredientTapStartingPoint = CGRectZero;
    }
}

#pragma mark - Private methods

- (void)addSubviews {
    [self addTitleLabel];
    [self addDoneButton];
}

- (void)addDoneButton {
    UIView *tableView = self.targetEditingView;
    
    self.doneButton.frame = CGRectMake(tableView.frame.origin.x + tableView.frame.size.width - self.doneButton.frame.size.width,
                                       tableView.frame.origin.y - floorf(self.doneButton.frame.size.width*0.20),
                                       self.doneButton.frame.size.width,
                                       self.doneButton.frame.size.height);
    [self.view addSubview:self.doneButton];
}

- (UITableView*)newTableView
{
    CGRect frame = CGRectMake(kTableViewInsets.left,
                              kTableViewInsets.top,
                              self.view.bounds.size.width - kTableViewInsets.left - kTableViewInsets.right,
                              self.view.bounds.size.height - kTableViewInsets.top - kTableViewInsets.bottom);
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.tableFooterView = [self newTableFooterView];
    [tableView registerClass:[IngredientTableViewCell class] forCellReuseIdentifier:kIngredientsTableViewCell];
    return tableView;
}

-(UIView*)newTableFooterView
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0.0f,
                                                                kTableViewInsets.top,
                                                                self.view.bounds.size.width - kTableViewInsets.right,
                                                                100.0f)];
    UIEdgeInsets ingredientCellInsets = [IngredientConstants editableIngredientCellInsets];
    float paddingWidthBetweenCells = [IngredientConstants editableIngredientCellPaddingWidthBetweenFields];
    float widthAvailable = footerView.frame.size.width - paddingWidthBetweenCells - ingredientCellInsets.left - ingredientCellInsets.right;

    UILabel *addIngredientLabel = [[UILabel alloc] initWithFrame:CGRectMake(ingredientCellInsets.left,
                                                                           ingredientCellInsets.top,
                                                                           widthAvailable - kTableViewInsets.right,
                                                                           footerView.frame.size.height - ingredientCellInsets.top - ingredientCellInsets.bottom)];

    addIngredientLabel.text = @"  ADD INGREDIENT";
    addIngredientLabel.font = [Theme textEditableTextFont];
    addIngredientLabel.textAlignment = NSTextAlignmentCenter;
    addIngredientLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addIngredientTapped:)];
    [addIngredientLabel addGestureRecognizer:tapGesture];
    addIngredientLabel.backgroundColor = [UIColor grayColor];
    [footerView addSubview:addIngredientLabel];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}
- (void)addTitleLabel {
    UIView *tableView = (UIView *)self.targetEditingView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = self.editingTitle;
    titleLabel.font = self.titleFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(tableView.frame.origin.x + floorf((tableView.frame.size.width - titleLabel.frame.size.width) / 2.0),
                                  tableView.frame.origin.y - titleLabel.frame.size.height + 5.0,
                                  titleLabel.frame.size.width,
                                  titleLabel.frame.size.height);
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

-(void)addIngredientTapped:(UITapGestureRecognizer*)tapGestureRecognizer
{
    DLog();
    UITableView *tableView = (UITableView*)self.targetEditingView;
    //new ingredient
    Ingredient *ingredient = [[Ingredient alloc]init];
    [self.ingredientList addObject:ingredient];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.ingredientList count]-1 inSection:0];
    [tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewScrollPositionNone];
    [self tableView:tableView didSelectRowAtIndexPath:newIndexPath];
}

@end
