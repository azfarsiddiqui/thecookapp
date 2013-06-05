//
//  CKItemCollectionViewCell.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 14/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKItemCollectionViewCell.h"
#import "CKEditingViewHelper.h"

@interface CKItemCollectionViewCell ()

@end

@implementation CKItemCollectionViewCell

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
    }
    return self;
}

- (void)focusForEditing:(BOOL)focus {
    // Subclass to implement.
}

- (BOOL)shouldBeSelectedForState:(BOOL)selected {
    return (!self.placeholder && self.allowSelectionState && selected);
}

- (void)configureValue:(id)value {
    self.placeholder = NO;
    // Subclass to implement.
}

- (id)currentValue {
    // Subclass to implement.
    return nil;
}

#pragma mark - UICollectionViewCell methods

- (void)setSelected:(BOOL)selected {
    self.boxImageView.image = [self imageForSelected:[self shouldBeSelectedForState:selected]];
    [super setSelected:selected];
}

#pragma mark - Setters

- (void)setPlaceholder:(BOOL)placeholder {
    _placeholder = placeholder;
    self.boxImageView.alpha = placeholder ? kPlaceholderAlpha : 1.0;
}

#pragma mark - Private methods

- (UIImage *)imageForSelected:(BOOL)selected {
    return selected ? [CKEditingTextBoxView textEditingSelectionBoxWhite:YES] : [CKEditingTextBoxView textEditingBoxWhite:YES];
}

@end
