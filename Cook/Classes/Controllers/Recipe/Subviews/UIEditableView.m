//
//  UIEditableView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/30/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "UIEditableView.h"

@interface UIEditableView()
@property(nonatomic,assign,readonly) BOOL editMode;
@end

@implementation UIEditableView

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self styleViews];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self styleViews];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self configViews];
}

-(void) makeEditable:(BOOL)editable
{
    _editMode = editable;
}

-(BOOL)inEditMode
{
    return self.editMode;
}

#pragma mark - Private methods
-(void) styleViews
{
    //override in sub-classes
}

-(void) configViews
{
    //override in sub-classes
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
