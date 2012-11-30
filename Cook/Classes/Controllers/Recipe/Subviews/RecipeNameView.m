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
@property(nonatomic,strong) CKTextField *nameTextField;
@end
@implementation RecipeNameView

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
    [self.nameTextField enableEditMode:editable];
}

#pragma mark - Private Methods

//overridden
-(void) configViews
{
    self.nameTextField.text = [self.recipeName uppercaseString];
    self.nameTextField.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
}

//overridden
-(void)styleViews
{
    self.nameTextField.font = kFont;
}

-(CKTextField *)nameTextField
{
    if (!_nameTextField) {
        _nameTextField = [[CKTextField alloc] initWithFrame:CGRectZero];
        [_nameTextField enableEditMode:NO];
        [self addSubview:_nameTextField];
    }
    return _nameTextField;
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
