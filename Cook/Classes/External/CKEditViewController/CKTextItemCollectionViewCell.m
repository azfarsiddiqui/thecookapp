//
//  CKItemCollectionViewCell.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 13/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextItemCollectionViewCell.h"
#import "CKEditingTextBoxView.h"
#import "CKEditingViewHelper.h"

@interface CKTextItemCollectionViewCell () <UITextFieldDelegate>

@end

@implementation CKTextItemCollectionViewCell

#define kDefaultFont        [UIFont systemFontOfSize:50]
#define kPlaceholderAlpha   0.7

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // Internal text view.
        CGFloat singleLineHeight = [CKEditingViewHelper singleLineHeightForFont:kDefaultFont size:self.contentView.bounds.size];
        UIEdgeInsets itemInsets = UIEdgeInsetsMake(floorf((self.contentView.bounds.size.height - singleLineHeight) / 2.0), 20.0, 0.0, 20.0);
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(itemInsets.left,
                                                                               itemInsets.top,
                                                                               self.contentView.bounds.size.width - itemInsets.left - itemInsets.right,
                                                                               singleLineHeight)];
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        textField.backgroundColor = [UIColor clearColor];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        textField.font = kDefaultFont;
        textField.textColor = [UIColor blackColor];
        textField.returnKeyType = UIReturnKeyDone;
        textField.userInteractionEnabled = NO;
        [self.contentView addSubview:textField];
        self.textField = textField;
    }
    return self;
}

- (void)focusForEditing:(BOOL)focus {
    if (focus) {
        self.textField.userInteractionEnabled = YES;
        [self.textField becomeFirstResponder];
    } else {
        [self.textField resignFirstResponder];
        self.textField.userInteractionEnabled = NO;
    }
}

- (void)configureValue:(id)value {
    [super configureValue:value];
    self.textField.text = [self textForValue:value];
}

- (id)currentValue {
    return self.textField.text;
}

- (NSString *)textForValue:(id)value {
    return (NSString *)value;
}

#pragma mark - Setters

- (void)setPlaceholder:(BOOL)placeholder {
    [super setPlaceholder:placeholder];
    self.textField.text = @"";
}

#pragma mark - UICollectionViewCell methods

- (void)setSelected:(BOOL)selected {
    self.textField.textColor = [self shouldBeSelectedForState:selected] ? [UIColor whiteColor] : [UIColor blackColor];
    [super setSelected:selected];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return [self.delegate processedValueForCell:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate returnRequestedForCell:self];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - Private methods

- (UIImage *)imageForSelected:(BOOL)selected {
    return selected ? [CKEditingTextBoxView textEditingSelectionBoxWhite:YES] : [CKEditingTextBoxView textEditingBoxWhite:YES];
}

- (UIEdgeInsets)itemInsetsForFont:(UIFont *)font {
    CGFloat singleLineHeight = [CKEditingViewHelper singleLineHeightForFont:font size:self.contentView.bounds.size];
    return UIEdgeInsetsMake(floorf((self.contentView.bounds.size.height - singleLineHeight) / 2.0), 20.0, 0.0, 20.0);
}

@end
