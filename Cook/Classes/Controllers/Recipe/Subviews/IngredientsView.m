//
//  IngredientsView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientsView.h"
#import "Theme.h"
#import "ViewHelper.h"
#import "Ingredient.h"
#import "TempIngredientTableViewCell.h"
#import "NSArray+Enumerable.h"

#define kIngredientCellTag 112233
#define kIngredientTableViewCellIdentifier @"IngredientTableViewCell"
#define kEditHeight 150.0f

@interface IngredientsView()<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>
@property(nonatomic,strong) UILabel *ingredientsLabel;
@property(nonatomic,strong) UIScrollView *ingredientsScrollView;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIButton *addIngredientsButton;
@end

@implementation IngredientsView

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
    self.ingredientsLabel.hidden = editable;
    [self.tableView reloadData];
    self.tableView.hidden = !editable;
    self.addIngredientsButton.hidden = !editable;
}

#pragma mark - Private methods
//overridden
-(void)configViews
{
    self.ingredientsScrollView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    [self updateIngredientsLabelText];
}

//overridden
-(void) styleViews
{
    self.ingredientsLabel.font = [Theme defaultLabelFont];
    self.ingredientsLabel.backgroundColor = [UIColor clearColor];
    self.ingredientsLabel.textColor = [UIColor blackColor];
}

-(UILabel *)ingredientsLabel
{
    if (!_ingredientsLabel) {
        _ingredientsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _ingredientsLabel.numberOfLines = 0;
        [self.ingredientsScrollView addSubview:_ingredientsLabel];
    }
    
    return _ingredientsLabel;
}

-(UIScrollView *)ingredientsScrollView
{
    if (!_ingredientsScrollView) {
        _ingredientsScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _ingredientsScrollView.scrollEnabled = YES;
        [self addSubview:_ingredientsScrollView];
    }
    return _ingredientsScrollView;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.hidden = YES;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[TempIngredientTableViewCell class] forCellReuseIdentifier:kIngredientTableViewCellIdentifier];
        [self addSubview:_tableView];
    }
    return _tableView;
}

-(UIButton *)addIngredientsButton
{
    if (!_addIngredientsButton) {
        _addIngredientsButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_textedit.png"] target:self selector:@selector(addIngredientTapped:)];
        _addIngredientsButton.hidden =YES;
        _addIngredientsButton.frame = CGRectMake(self.bounds.size.width - floorf(0.75*(_addIngredientsButton.frame.size.width)),-5.0f,
                                                 _addIngredientsButton.frame.size.width, _addIngredientsButton.frame.size.height);
        [self addSubview:_addIngredientsButton];
    }
    return _addIngredientsButton;
}
-(void) adjustScrollContentSizeToHeight:(float)height
{
    self.ingredientsScrollView.contentSize = height > self.ingredientsScrollView.frame.size.height ?
        CGSizeMake(self.ingredientsScrollView.frame.size.width, height) :
    CGSizeMake(self.ingredientsScrollView.frame.size.width, self.ingredientsScrollView.frame.size.height);
}

-(NSString*)stringFromIngredients
{
    NSMutableString *mutableIngredientString = [[NSMutableString alloc]init];
    [self.ingredients each:^(Ingredient *ingredient) {
        [mutableIngredientString appendFormat:@"%@\n",ingredient.name];
    }];
    
    return [NSString stringWithString:mutableIngredientString];
}

-(void)updateIngredientsLabelText
{
    self.ingredientsLabel.text = [self stringFromIngredients];
    CGSize maxSize = CGSizeMake(190.0f, CGFLOAT_MAX);
    CGSize requiredSize = [self.ingredientsLabel.text sizeWithFont:self.ingredientsLabel.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    self.ingredientsLabel.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
    [ViewHelper adjustScrollContentSize:self.ingredientsScrollView forHeight:requiredSize.height];
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
    static NSString *reuseCellID = kIngredientTableViewCellIdentifier;
    TempIngredientTableViewCell *cell = (TempIngredientTableViewCell*) [tableView dequeueReusableCellWithIdentifier:reuseCellID];
    Ingredient *ingredient = [self.ingredients objectAtIndex:indexPath.row];
    [cell setIngredient:ingredient forRow:indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog();
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect smallFrame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, kEditHeight);
    self.tableView.frame = smallFrame;
    self.backgroundEditImageView.frame = smallFrame;

    UITableViewCell *tableViewCell = (UITableViewCell*)[[textField superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tableViewCell];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    UIView *parentView = [textField superview];
    TempIngredientTableViewCell *cell = (TempIngredientTableViewCell*)[parentView superview];
    Ingredient *ingredient = [self.ingredients objectAtIndex:cell.ingredientIndex];
    ingredient.name = textField.text;
    [self updateIngredientsLabelText];
    CGRect nonEditingFrame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.bounds.size.height);
    self.tableView.frame = nonEditingFrame;
    self.backgroundEditImageView.frame = nonEditingFrame;

}

#pragma mark - Action buttons
-(void)addIngredientTapped:(UIButton*)button
{
    [self.ingredients addObject:[Ingredient ingredientwithName:@""]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.ingredients count]> 0 ?[self.ingredients count]-1:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
