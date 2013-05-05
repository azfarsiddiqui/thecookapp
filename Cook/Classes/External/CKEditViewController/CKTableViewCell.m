//
//  CKListTableViewCell.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 29/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTableViewCell.h"
#import "CKEditingTextBoxView.h"
#import "CKEditingViewHelper.h"

@interface CKTableViewCell () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *listContentView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) CGFloat borderHeight;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@end

@implementation CKTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier borderHeight:(CGFloat)borderHeight font:(UIFont *)font
                contentInsets:(UIEdgeInsets)contentInsets {
    
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.borderHeight = borderHeight;
        
        // No selection style.
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Editable by default.
        self.editable = YES;
        
        // List item content view.
        UIImageView *contentImageView = [[UIImageView alloc] initWithImage:[CKEditingTextBoxView textEditingBoxWhite:YES]];
        contentImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        contentImageView.userInteractionEnabled = YES;
        contentImageView.frame = CGRectMake(self.contentView.bounds.origin.x,
                                            self.contentView.bounds.origin.y,
                                            self.contentView.bounds.size.width,
                                            self.contentView.bounds.size.height - borderHeight);
        [self.contentView addSubview:contentImageView];
        self.listContentView = contentImageView;
        
        // Add a textfield and set it editable accordingly.
        CGSize contentSize = [self listItemContentSize];
        CGFloat singleLineHeight = [CKEditingViewHelper singleLineHeightForFont:self.textField.font size:contentSize];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(self.contentInsets.left,
                                                                               floorf((self.listContentView.bounds.size.height - singleLineHeight) / 2.0),
                                                                               contentSize.width,
                                                                               singleLineHeight)];
        textField.font = font;
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        textField.backgroundColor = [UIColor clearColor];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        [contentImageView addSubview:textField];
        self.textField = textField;
        
    }
    return self;
}

- (void)setItemText:(NSString *)itemText {
    [self setItemText:itemText editable:YES];
}

- (void)setItemText:(NSString *)itemText editable:(BOOL)editable {
    self.textField.text = itemText;
    //self.textField.userInteractionEnabled = editable;
    self.textField.userInteractionEnabled = NO;
    self.editable = editable;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    return self.editable;
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - Private methods

- (CGSize)listItemContentSize {
    return CGSizeMake(self.listContentView.bounds.size.width - self.contentInsets.left - self.contentInsets.right,
                      self.listContentView.bounds.size.height - self.contentInsets.top - self.contentInsets.bottom);
}

@end
