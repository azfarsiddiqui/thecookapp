//
//  CKEditableView.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 12/12/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKEditableView.h"

@interface CKEditableView ()

@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) id<CKEditableViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *editBackgroundView;
@property (nonatomic, strong) UIImage *editBackgroundImage;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation CKEditableView

#define kEditButtonOffset   CGSizeMake(-24.0, -3.0)

- (id)initWithDelegate:(id<CKEditableViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingNone;
        self.clipsToBounds = YES;
        
        self.editBackgroundImage = [[UIImage imageNamed:@"cook_customise_textbox.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        UIImageView *editBackgroundView = [[UIImageView alloc] initWithImage:self.editBackgroundImage];
        self.editBackgroundView = editBackgroundView;
        
    }
    return self;
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
    self.editBackgroundView.frame = CGRectMake(0.0,
                                               0.0,
                                               self.contentInsets.left + contentView.frame.size.width + self.contentInsets.right,
                                               self.contentInsets.top + contentView.frame.size.height + self.contentInsets.bottom);
    contentView.frame = CGRectMake(self.contentInsets.left,
                                   self.contentInsets.top,
                                   contentView.frame.size.width,
                                   contentView.frame.size.height);
    [self.editBackgroundView addSubview:contentView];
    
    // Calculate the overall frame which takes into account the editButton.
    self.frame = CGRectMake(0.0,
                            0.0,
                            self.editBackgroundView.frame.size.width + self.editButton.frame.size.width + kEditButtonOffset.width,
                            self.editBackgroundView.frame.size.height - kEditButtonOffset.height);
    
    // Position the edit background view.
    self.editBackgroundView.frame = CGRectMake(0.0,
                                               -kEditButtonOffset.height,
                                               self.editBackgroundView.frame.size.width,
                                               self.editBackgroundView.frame.size.height);
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
        _editButton = [self buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_textedit.png"]
                                     target:self selector:@selector(editTapped:)];
    }
    return _editButton;
}

#pragma mark - Private methods

- (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    button.userInteractionEnabled = (target != nil && selector != nil);
    button.autoresizingMask = UIViewAutoresizingNone;
    return button;
}

- (void)editTapped:(id)sender {
    [self.delegate editableViewEditRequestedForView:self];
}

@end
