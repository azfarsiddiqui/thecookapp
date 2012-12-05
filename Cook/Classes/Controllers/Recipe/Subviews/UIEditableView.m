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
@property (nonatomic,strong) UIImageView *backgroundEditImageView;
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
    self.backgroundEditImageView.hidden = !editable;
}

-(BOOL)inEditMode
{
    return self.editMode;
}

-(UIImageView *)backgroundEditImageView
{
    if (!_backgroundEditImageView) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"cook_editrecipe_textbox"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f,4.0f,4.0f,4.0f)];
        _backgroundEditImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
        _backgroundEditImageView.hidden = YES;
        _backgroundEditImageView.image = backgroundImage;
        [self insertSubview:_backgroundEditImageView atIndex:0];
    }
    return _backgroundEditImageView;
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
