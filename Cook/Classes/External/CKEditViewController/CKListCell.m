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

@interface CKListCell ()

@property (nonatomic, strong) UIImageView *boxImageView;
@property (nonatomic, strong) UIView *reorderView;
@property (nonatomic, assign) BOOL cancelled;
@property (nonatomic, assign) BOOL empty;

@end

@implementation CKListCell

#define kTextFieldReorderGap    10.0

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // Default font.
        self.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:36.0];
        
        // Not opaque.
        self.opaque = NO;
        
        // Background box image view.
        UIImageView *boxImageView = [[UIImageView alloc] initWithImage:[self imageForSelected:NO]];
        boxImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        boxImageView.frame = self.bounds;
        self.boxImageView = boxImageView;
        self.backgroundView = boxImageView;
        
        // Internal text field.
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
    self.alpha = 1.0;   // May be faded by subclasses.
    self.editing = NO;
    self.textField.text = [self textValueForValue:value];
    [self setSelected:selected];
}

- (NSString *)textValueForValue:(id)value {
    NSString *textValue = nil;
    if ([value isKindOfClass:[NSString class]]) {
        textValue = (NSString *)value;
    }
    return textValue;
}

- (id)currentValue {
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setEditing:(BOOL)editing {
    [self setEditing:editing empty:[self isEmpty]];
}

- (void)setEditing:(BOOL)editing empty:(BOOL)empty {
    self.editMode = editing;
    self.empty = YES;
    
    if (editing) {
        [self.textField becomeFirstResponder];
    } else {
        [self.textField resignFirstResponder];
    }
}

- (BOOL)isEmpty {
    return [self.delegate listItemEmptyForCell:self];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    // Tells delegate that I am focused.
    [self.delegate listItemFocused:YES cell:self];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    // Tells delegate that I am unfocused.
    [self.delegate listItemFocused:NO cell:self];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Important to tell delegate that I'm done, and not resign here as keyboard will flash up and down.
    [self.delegate listItemReturnedForCell:self];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - Properties

- (void)setAllowSelection:(BOOL)allowSelection {
    _allowSelection = allowSelection;
    
    // Text field interactable only if not in allow selection model.
    self.textField.userInteractionEnabled = !allowSelection;
}

- (void)setAllowReorder:(BOOL)allowReorder {
    _allowReorder = allowReorder;
    
    CGRect textFrame = self.textField.frame;
    UIEdgeInsets listItemInsets = [CKListCell listItemInsets];
    
    if (allowReorder) {
        
        if (!self.reorderView.superview) {
            [self.contentView addSubview:self.reorderView];
        }
        
        // Resize textfield to make way for reorderView.
        textFrame.size.width = self.contentView.bounds.size.width - textFrame.origin.x - listItemInsets.right - self.reorderView.frame.size.width - kTextFieldReorderGap;
        
        
    } else {
        
        // Restore textfield to full-width to the right.
        textFrame.size.width = self.contentView.bounds.size.width - textFrame.origin.x - listItemInsets.right;
        
        // Remove the reorder view.
        [self.reorderView removeFromSuperview];
    }
    
    self.textField.frame = textFrame;
}

#pragma mark - Private methods

- (UIImage *)imageForSelected:(BOOL)selected {
    return selected ? [CKEditingTextBoxView textEditingSelectionBoxWhite:YES] : [CKEditingTextBoxView textEditingBoxWhite:YES];
}

- (UIView *)reorderView {
    if (!_reorderView) {
        UIEdgeInsets listItemInsets = [CKListCell listItemInsets];
        CGFloat unitDimension = self.contentView.bounds.size.height - listItemInsets.top - listItemInsets.bottom;
        _reorderView = [[UIView alloc] initWithFrame:(CGRect){
            self.contentView.bounds.size.width - listItemInsets.right - unitDimension,
            listItemInsets.top,
            unitDimension,
            unitDimension
        }];
        _reorderView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _reorderView.userInteractionEnabled = NO;
        _reorderView.alpha = 0.5;
        _reorderView.backgroundColor = [UIColor lightGrayColor];
    }
    return _reorderView;
}

@end
