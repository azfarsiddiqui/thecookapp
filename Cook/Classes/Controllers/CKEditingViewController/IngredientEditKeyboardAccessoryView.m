//
//  IngredientEditKeyboardAccessoryView.m
//  Cook
//
//  Created by Jonny Sagorin on 2/15/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientEditKeyboardAccessoryView.h"
#import "ViewHelper.h"
#import "Theme.h"

#define kButtonWidth    80.0f
#define kButtonSpacer   9.0f

@interface IngredientEditKeyboardAccessoryView ()

@property(nonatomic,strong) NSArray *shortNames;
@property(nonatomic,strong) NSArray *measureNames;
@property(nonatomic,assign) id<IngredientEditKeyboardAccessoryViewDelegate> delegate;

@end

@implementation IngredientEditKeyboardAccessoryView

- (id)initWithDelegate:(id<IngredientEditKeyboardAccessoryViewDelegate>)delegate {
    return [self initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 56.0) delegate:delegate];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<IngredientEditKeyboardAccessoryViewDelegate>)delegate; {
    self = [super initWithFrame:frame];
    if (self) {
        self.shortNames = @[@"1/4",@"1/3",@"1/2",@"",@"ML",@"L",@"",@"MG",@"G",@"KG",@"",@"TSP",@"TBSP",@"CUP"];
        self.measureNames = @[@"1/4",@"1/3",@"1/2"];
        self.delegate = delegate;
        [self style];
    }
    return self;
}

#pragma mark - Private methods
-(void)style
{
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cook_keyboard_autosuggest_bg"]];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"cook_keyboard_autosuggest_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 11.0f, 0.0f, 11.0f)];
    __block float xPosIndex = 0;
    [self.shortNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        if ([@"" isEqualToString:name]) {
            //divider
            UIImageView *dividerImageView = [self dividerAtXOrigin:xPosIndex+kButtonSpacer];
            [self addSubview:dividerImageView];
            xPosIndex+=(dividerImageView.frame.size.width+kButtonSpacer);
        } else {
            UIButton *button  = [ViewHelper buttonWithTitle:name backgroundImage:buttonImage
                                                     target:self selector:@selector(buttonTapped:)];
            [button.titleLabel setFont:[Theme ingredientAccessoryViewButtonTextFont]];
            button.frame = CGRectMake(xPosIndex + kButtonSpacer,
                                      floorf(0.5*(self.frame.size.height - buttonImage.size.height)),
                                      kButtonWidth,
                                      buttonImage.size.height);
            [self addSubview:button];
            xPosIndex = xPosIndex+=(kButtonWidth+kButtonSpacer);
        }
    }];
    
}

-(UIImageView*)dividerAtXOrigin:(float)xOrigin
{
    UIImageView *divider = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cook_keyboard_autosuggest_divider"]];
    divider.frame = CGRectMake(xOrigin, 0.0f, divider.frame.size.width, divider.frame.size.height);
    return divider;
  
}

-(void)buttonTapped:(UIButton*)button
{
    BOOL isAmount = [self.measureNames containsObject:button.titleLabel.text];
    [self.delegate didEnterMeasurementShortCut:button.titleLabel.text isAmount:isAmount];
}
@end
