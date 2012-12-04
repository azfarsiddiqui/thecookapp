//
//  RecipeNameView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeNameView.h"
#import "Theme.h"

#define kFont [Theme defaultFontWithSize:42.0f]
#define kMaxSize CGSizeMake(538.0f, CGFLOAT_MAX)

@interface RecipeNameView ()
@property(nonatomic,strong) UITextField *recipeTextField;
@property(nonatomic,strong) UIImageView *editIconImageView;
@end
@implementation RecipeNameView

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
    self.editIconImageView.hidden = !editable;
    self.recipeTextField.enabled = YES;
}

#pragma mark - Private Methods

//overridden
-(void) configViews
{
    self.recipeTextField.text = [self.recipeName uppercaseString];
    self.recipeTextField.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
}

//overridden
-(void)styleViews
{
    self.recipeTextField.font = kFont;
}

-(UITextField *)recipeTextField
{
    if (!_recipeTextField) {
        _recipeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _recipeTextField.enabled = NO;
        [self addSubview:_recipeTextField];
    }
    return _recipeTextField;
}

-(UIImageView *)editIconImageView
{
    if (!_editIconImageView) {
        UIImage *editIconImage = [UIImage imageNamed:@"cook_customise_btns_textedit.png"];
        _editIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - floorf(0.75*(editIconImage.size.width)),-5.0f,
                                                                           editIconImage.size.width, editIconImage.size.height)];
        _editIconImageView.hidden = YES;
        _editIconImageView.image = editIconImage;
        [self addSubview:_editIconImageView];
    }
    return _editIconImageView;
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
