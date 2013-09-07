//
//  CKTextEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 28/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextEditViewController.h"
#import "CKEditingTextBoxView.h"

@interface CKTextEditViewController ()

@end

@implementation CKTextEditViewController

#define kTitleLimitGap          12.0

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title {
    
    return [self initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title characterLimit:NSUIntegerMax];
}

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title
        characterLimit:(NSUInteger)characterLimit {
    
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title]) {
        self.characterLimit = characterLimit;
        self.textLimited = (characterLimit < NSUIntegerMax);
        self.font = [UIFont boldSystemFontOfSize:70.0];
    }
    return self;
}

- (void)updateInfoLabels {
    [super updateInfoLabels];
    
    if (self.textLimited) {
        [self.limitLabel sizeToFit];
        self.limitLabel.frame = CGRectMake(self.limitLabel.frame.origin.x,
                                           self.titleLabel.frame.origin.y,
                                           self.limitLabel.frame.size.width,
                                           self.limitLabel.frame.size.height);
    }
}

#pragma mark - Lazy getters

- (UILabel *)limitLabel {
    if (!_limitLabel && self.textLimited && self.showLimit && self.showTitle) {
        
        _limitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _limitLabel.backgroundColor = [UIColor clearColor];
        _limitLabel.alpha = 0.5;
        _limitLabel.text = [NSString stringWithFormat:@"%d", self.characterLimit - [[self updatedValue] length]];
        _limitLabel.font = self.titleLabel.font;
        _limitLabel.textColor = self.titleLabel.textColor;
        [_limitLabel sizeToFit];
        
        // Reposition both title and limit labels.
        CGFloat requiredWidth = self.titleLabel.frame.size.width + kTitleLimitGap + _limitLabel.frame.size.width;
        self.titleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - requiredWidth) / 2.0),
                                           self.titleLabel.frame.origin.y,
                                           self.titleLabel.frame.size.width,
                                           self.titleLabel.frame.size.height);
        _limitLabel.frame = CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + kTitleLimitGap,
                                       self.titleLabel.frame.origin.y,
                                       _limitLabel.frame.size.width,
                                       _limitLabel.frame.size.height);
    }
    return _limitLabel;
}

@end
