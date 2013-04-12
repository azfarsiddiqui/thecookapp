//
//  CKEditingTextBoxView.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingTextBoxView.h"

@interface CKEditingTextBoxView ()

@property (nonatomic, strong) UIView *textEditingPencilView;
@property (nonatomic, strong) UIView *textEditImageView;

@end

@implementation CKEditingTextBoxView

- (id)initWithEditingFrame:(CGRect)editingFrame contentInsets:(UIEdgeInsets)contentInsets {
    return [self initWithEditingFrame:editingFrame contentInsets:contentInsets white:YES];
}

- (id)initWithEditingFrame:(CGRect)editingFrame contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.userInteractionEnabled = YES;
        CGPoint pencilOffsets = CGPointMake(-32.0, -11.0);
        
        UIImageView *textEditImageView = [[UIImageView alloc] initWithImage:[self textEditingBoxWhite:white]];
        textEditImageView.userInteractionEnabled = YES;
        textEditImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
        
        UIImageView *textEditingPencilView = [[UIImageView alloc] initWithImage:[self textEditingPencilWhite:white]];
        textEditingPencilView.userInteractionEnabled = YES;
        textEditingPencilView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
        textEditingPencilView.frame = CGRectMake(contentInsets.left + editingFrame.size.width + contentInsets.right + pencilOffsets.x,
                                                 0.0,
                                                 textEditingPencilView.frame.size.width,
                                                 textEditingPencilView.frame.size.height);
        textEditImageView.frame = CGRectMake(0.0,
                                             textEditingPencilView.frame.origin.y - pencilOffsets.y,
                                             contentInsets.left + editingFrame.size.width + contentInsets.right,
                                             contentInsets.top + editingFrame.size.height + contentInsets.bottom);
        
        CGRect frame = CGRectUnion(textEditingPencilView.frame, textEditImageView.frame);
        frame.origin.x = editingFrame.origin.x - contentInsets.left;
        frame.origin.y = editingFrame.origin.y - contentInsets.top + pencilOffsets.y;
        self.frame = frame;
        
        [self addSubview:textEditImageView];
        [self addSubview:textEditingPencilView];
        self.textEditImageView = textEditImageView;
        self.textEditingPencilView = textEditingPencilView;
    }
    return self;
}

- (void)showEditingIcon:(BOOL)show animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.textEditingPencilView.alpha = show ? 1.0 : 0.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.textEditingPencilView.alpha = show ? 1.0 : 0.0;
    }
}

#pragma mark - Private methods


- (UIImage *)textEditingBoxWhite:(BOOL)white {
    UIImage *textEditingImage = nil;
    if (white) {
        textEditingImage = [[UIImage imageNamed:@"cook_customise_textbox_white.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)];
    } else {
        textEditingImage = [[UIImage imageNamed:@"cook_customise_textbox_white.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)];
    }
    return textEditingImage;
}

- (UIImage *)textEditingPencilWhite:(BOOL)white {
    UIImage *textEditingPencilImage = nil;
    if (white) {
        textEditingPencilImage = [UIImage imageNamed:@"cook_customise_btns_textedit_white.png"];
    } else {
        textEditingPencilImage = [UIImage imageNamed:@"cook_customise_btns_textedit_white.png"];
    }
    return textEditingPencilImage;
}


@end
