//
//  CKListCell.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 23/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListCell.h"
#import "CKEditingTextBoxView.h"
#import "CKEditingViewHelper.h"

@interface CKListCell () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *boxImageView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) BOOL cancelled;

@end

@implementation CKListCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // Default font.
        self.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:36.0];
        
        // Not opaque.
        self.opaque = NO;
        
        // Background box image view.
        UIImageView *boxImageView = [[UIImageView alloc] initWithImage:[self imageForSelected:NO]];
        boxImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        boxImageView.frame = self.bounds;
        self.boxImageView = boxImageView;
        self.backgroundView = boxImageView;
        
        // Internal text view.
        UIEdgeInsets listItemInsets = [CKListCell listItemInsets];
        UITextField *textField = [[UITextField alloc] initWithFrame:(CGRect){
            listItemInsets.left,
            listItemInsets.top,
            self.contentView.bounds.size.width - listItemInsets.left - listItemInsets.right,
            self.contentView.bounds.size.height - listItemInsets.top - listItemInsets.bottom
        }];
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        textField.backgroundColor = [UIColor clearColor];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
        textField.font = self.font;
        textField.userInteractionEnabled = NO;
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
//    DLog(@"[%@] selected[%@] customSelection[%@]", [self currentValue], selected ? @"YES" : @"NO", customSelection ? @"YES" : @"NO");
}

- (BOOL)resignFirstResponder {
    [self setEditing:NO];
    return YES;
}

#pragma mark - CKListCell methods

+ (UIEdgeInsets)listItemInsets {
    return UIEdgeInsetsMake(23.0, 20.0, 18.0, 30.0);
}

- (void)configureValue:(id)value {
    [self configureValue:value selected:NO];
}

- (void)configureValue:(id)value selected:(BOOL)selected {
    self.editing = NO;
    self.textField.text = [self textValueForValue:value];
    [self setSelected:selected];
}

- (NSString *)textValueForValue:(id)value {
    return (NSString *)value;
}

- (id)currentValue {
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)setEditing:(BOOL)editMode {
    self.editMode = editMode;
    self.textField.userInteractionEnabled = editMode;
    
    if (editMode) {
        [self.textField becomeFirstResponder];
    } else {
        [self.textField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return self.editMode;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    // Return immediately if cancelled (prevents a mysterious double call in here).
    if (self.cancelled) {
        return YES;
    }
    
    BOOL shouldEndEditing = NO;
    if ([self hasValidValue]) {
        shouldEndEditing = YES;
        [self.delegate listItemChangedForCell:self];
    } else if ([self.delegate listItemCanCancelForCell:self]) {
        
        // Mark as cancelled.
        self.cancelled = YES;
        [self.delegate listItemProcessCancelForCell:self];
    }

    return shouldEndEditing;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    
    if (shouldReturn) {
        [self setEditing:NO];
    }
    
    return shouldReturn;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - Private methods

- (UIImage *)imageForSelected:(BOOL)selected {
    return selected ? [CKEditingTextBoxView textEditingSelectionBoxWhite:YES] : [CKEditingTextBoxView textEditingBoxWhite:YES];
}

- (BOOL)hasValidValue {
    return [self.delegate listItemValidatedForCell:self];
}

@end
