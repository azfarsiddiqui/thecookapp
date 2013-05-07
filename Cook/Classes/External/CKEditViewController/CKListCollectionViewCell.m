//
//  CKListCollectionViewCell.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 1/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListCollectionViewCell.h"
#import "CKEditingViewHelper.h"

@interface CKListCollectionViewCell () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *boxImageView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL allowSelection;
@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, assign) BOOL focused;

@end

@implementation CKListCollectionViewCell

#define kDefaultFont        [UIFont systemFontOfSize:50]
#define kPlaceholderAlpha   0.7

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // Background box image view.
        UIImageView *boxImageView = [[UIImageView alloc] initWithImage:[self imageForSelected:NO]];
        boxImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        boxImageView.userInteractionEnabled = YES;
        boxImageView.frame = self.bounds;
        self.boxImageView = boxImageView;
        self.backgroundView = boxImageView;

        // Internal text view.
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        textField.backgroundColor = [UIColor clearColor];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:textField];
        self.textField = textField;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    BOOL customSelection = (self.allowSelection && selected);
    self.textField.textColor = customSelection ? [UIColor whiteColor] : [UIColor blackColor];
    self.boxImageView.image = [self imageForSelected:customSelection];
}

#pragma mark - CKListCollectionViewCell methods

- (void)configureText:(NSString *)text {
    [self configureText:text editable:YES];
}

- (void)configureText:(NSString *)text editable:(BOOL)editable {
    [self configureText:text font:kDefaultFont editable:editable];
}

- (void)configureText:(NSString *)text font:(UIFont *)font {
    [self configureText:text font:font editable:YES];
}

- (void)configureText:(NSString *)text font:(UIFont *)font editable:(BOOL)editable {
    [self configureText:text placeholder:nil font:font editable:editable selected:NO];
}

- (void)configureText:(NSString *)text editable:(BOOL)editable selected:(BOOL)selected {
    [self configureText:text placeholder:nil font:kDefaultFont editable:editable selected:selected];
}

- (void)configureText:(NSString *)text placeholder:(NSString *)placeholder font:(UIFont *)font editable:(BOOL)editable {
    [self configureText:text placeholder:placeholder font:font editable:editable selected:NO];
}

- (void)configureText:(NSString *)text placeholder:(NSString *)placeholder font:(UIFont *)font editable:(BOOL)editable
             selected:(BOOL)selected {
    
    self.textField.font = font;
    self.editable = editable;
    
    // Placeholder handling.
    self.placeholder = placeholder;
    if ([placeholder length] > 0) {
        self.textField.text = placeholder;
        [self applyPlaceholderStyle:YES];
    } else {
        self.textField.text = text;
        [self applyPlaceholderStyle:NO];
    }
    
    CGFloat singleLineHeight = [CKEditingViewHelper singleLineHeightForFont:self.textField.font size:self.contentView.bounds.size];
    UIEdgeInsets listItemInsets = [self listItemInsets];
    
    // Position the textField based on the insets.
    self.textField.frame = CGRectMake(listItemInsets.left,
                                      listItemInsets.top,
                                      self.contentView.bounds.size.width - listItemInsets.left - listItemInsets.right,
                                      singleLineHeight);
    
    // Enable
    // self.textField.userInteractionEnabled = editable;
    self.textField.userInteractionEnabled = NO;
    
}

- (void)configurePlaceholder:(NSString *)placeholder {
    [self configureText:nil placeholder:placeholder font:kDefaultFont editable:YES];
}

- (void)configurePlaceholder:(NSString *)placeholder font:(UIFont *)font {
    [self configureText:nil placeholder:placeholder font:font editable:YES];
}

- (void)configurePlaceholder:(NSString *)placeholder editable:(BOOL)editable {
    [self configureText:nil placeholder:placeholder font:kDefaultFont editable:editable];
}

- (UIEdgeInsets)listItemInsets {
    CGFloat singleLineHeight = [CKEditingViewHelper singleLineHeightForFont:self.textField.font size:self.contentView.bounds.size];
    return UIEdgeInsetsMake(floorf((self.contentView.bounds.size.height - singleLineHeight) / 2.0), 20.0, 0.0, 20.0);
}

- (void)focus:(BOOL)focus {
    NSLog(@"Focus: %@", focus ? @"YES" : @"NO");
    if (focus) {
        self.focused = YES;
        self.textField.userInteractionEnabled = YES;
        [self.textField becomeFirstResponder];
    
    } else {
        [self.textField resignFirstResponder];
        self.textField.userInteractionEnabled = NO;
        self.focused = NO;
    }
}

- (void)allowSelection:(BOOL)selection {
    self.allowSelection = selection;
}

- (id)currentValue {
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    // Clear if placeholder.
    if (self.placeholder) {
        textField.text = @"";
        [self applyPlaceholderStyle:NO];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSLog(@"textFieldShouldEndEditing:");
    
    if ([self hasValidValue]) {
        
        // If this was a placeholder cell, then trigger adding of the cell.
        if ([self isPlaceholderCell]) {
            [self.delegate listItemAddedForCell:self];
        } else {
            [self.delegate listItemChangedForCell:self];
        }
        
    } else {
        
        // No valid text but is placeholder, so restore placeholder.
        if ([self isPlaceholderCell]) {
            self.textField.text = self.placeholder;
            [self applyPlaceholderStyle:YES];
            
            // Lose focus myself.
            [self.delegate listItemCancelledForCell:self];
        }
    }
        
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn:");
    BOOL shouldReturn = YES;
    
    // Lose focus and let end editing handle it.
    [self focus:NO];
    
    return shouldReturn;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - Private methods

- (void)processAddedItem {
    if ([self.placeholder length] > 0) {
        
        if (![self hasValidValue]) {
            self.textField.text = self.placeholder;
        }
    }
}

- (BOOL)isPlaceholderCell {
    return ([self.placeholder length] > 0);
}

- (BOOL)hasValidValue {
    return [self.delegate listItemValidatedForCell:self];
}

- (UIImage *)imageForSelected:(BOOL)selected {
    return selected ? [CKEditingTextBoxView textEditingSelectionBoxWhite:YES] : [CKEditingTextBoxView textEditingBoxWhite:YES];
}

- (UIColor *)textColourForSelected:(BOOL)selected {
    return selected ? [UIColor whiteColor] : [UIColor blackColor];
}

- (void)applyPlaceholderStyle:(BOOL)placeholder {
    self.textField.alpha = placeholder ? kPlaceholderAlpha : 1.0;
    self.boxImageView.alpha = placeholder ? kPlaceholderAlpha : 1.0;
    self.textField.textColor = [UIColor blackColor];
}

@end
