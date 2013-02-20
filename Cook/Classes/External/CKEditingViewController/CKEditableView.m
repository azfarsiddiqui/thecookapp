//
//  CKEditableView.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 12/12/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKEditableView.h"
#import "ViewHelper.h"

@interface CKEditableView ()

@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) UIImageView *editBackgroundView;
@property (nonatomic, strong) UIImage *editBackgroundImage;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation CKEditableView

#define kEditButtonOffset   CGSizeMake(3.0, 3.0)

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self config];
}

- (id)initWithDelegate:(id<CKEditableViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        [self config];
    }
    return self;
}

-(void)config
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingNone;
    self.clipsToBounds = YES;
    
    self.editBackgroundImage = [[UIImage imageNamed:@"cook_customise_textbox.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    UIImageView *editBackgroundView = [[UIImageView alloc] initWithImage:self.editBackgroundImage];
    self.editBackgroundView = editBackgroundView;
}

- (void)enableEditMode:(BOOL)enable {
    self.editable = enable;
    self.editBackgroundView.image = enable ? self.editBackgroundImage : nil;
    self.editBackgroundView.userInteractionEnabled = enable;
    self.editButton.hidden = !enable;
    
    if (enable) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editTapped:)];
        [self addGestureRecognizer:self.tapGestureRecognizer];
    } else if (self.tapGestureRecognizer) {
       [self removeGestureRecognizer:self.tapGestureRecognizer];
       self.tapGestureRecognizer = nil;
   }
}

- (void)setContentView:(UIView *)contentView {
    
    // Remove previous and reset with new.
    [_contentView removeFromSuperview];
    _contentView = contentView;
    
    // Background view to contain the contentView.
    self.editBackgroundView.frame = CGRectMake(0.0f,
                                               kEditButtonOffset.height,
                                               self.frame.size.width - kEditButtonOffset.width,
                                               self.frame.size.height - kEditButtonOffset.height);
    contentView.frame = CGRectMake(self.contentInsets.left,
                                   self.contentInsets.top,
                                   contentView.frame.size.width - self.contentInsets.left - self.contentInsets.right,
                                   contentView.frame.size.height - self.contentInsets.top - self.contentInsets.bottom);
    [self.editBackgroundView addSubview:contentView];
    [self addSubview:self.editBackgroundView];

    // Position the edit button.
    self.editButton.frame = CGRectMake(self.bounds.size.width - self.editButton.frame.size.width,
                                       0.0,
                                       self.editButton.frame.size.width,
                                       self.editButton.frame.size.height);
    [self addSubview:self.editButton];
    
    // Non-edit mode to start off with.
    [self enableEditMode:NO];
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        UIImageView *editBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cook_customise_textbox.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4]];
        editBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_containerView addSubview:editBackgroundView];
        self.editBackgroundView = editBackgroundView;
    }
    return _containerView;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_textedit.png"]
                                     target:self selector:@selector(editTapped:)];
    }
    return _editButton;
}

#pragma mark - Private methods

- (void)editTapped:(id)sender {
    [self.delegate editableViewEditRequestedForView:self];
}

@end
