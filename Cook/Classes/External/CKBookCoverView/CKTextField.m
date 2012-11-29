//
//  CKTextField.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 26/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKTextField.h"

@interface CKTextField ()

@property (nonatomic, strong) UIImage *editTextIcon;

@end

@implementation CKTextField

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self config];
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self config];
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 0.0, 4.0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 0.0, 2.0);
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.size.width - 20.0,
                      bounds.origin.y - 3.0,
                      self.editTextIcon.size.width,
                      self.editTextIcon.size.height);
}

- (void)enableEditMode:(BOOL)editMode {
    DLog(@"Edit Mode: %@", editMode ? @"YES": @"NO");
    self.background = editMode ? [self textboxImage] : [self clearImage];
    self.enabled = editMode;
    
    if (editMode) {
        self.rightView = [self editButton];
        self.rightView.alpha = 0;
    }
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.rightView.alpha = editMode ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!editMode) {
                             self.rightView = nil;
                         }
                     }];
}

#pragma mark - Private methods

-(void)config
{
    self.editTextIcon = [UIImage imageNamed:@"cook_customise_btns_textedit.png"];
    // Toggled via the setEnabled method.
    self.rightViewMode = UITextFieldViewModeAlways;
    self.clipsToBounds = NO;

}
- (UIImage *)clearImage {
    return [self clearImageOfSize:CGSizeMake(1.0, 1.0)];
}

- (UIImage *)clearImageOfSize:(CGSize)imageSize {
    CGRect rect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)textboxImage {
//    return [[UIImage imageNamed:@"cook_editrecipe_textbox.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0)];
    return [[UIImage imageNamed:@"cook_customise_textbox"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0)];
}

- (UIButton *)editButton {
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setBackgroundImage:self.editTextIcon forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editTapped:) forControlEvents:UIControlEventTouchUpInside];
    return editButton;
}

- (void)editTapped:(id)sender {
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    } else {
        [self becomeFirstResponder];
    }
}

@end
