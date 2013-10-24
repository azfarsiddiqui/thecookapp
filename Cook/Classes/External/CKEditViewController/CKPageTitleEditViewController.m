//
//  CKPageTitleViewController.m
//  Cook
//
//  Created by Gerald Kim on 24/10/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPageTitleEditViewController.h"
#import "CKEditingViewHelper.h"

@interface CKPageTitleEditViewController ()

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation CKPageTitleEditViewController

#define kEditButtonInsets       UIEdgeInsetsMake(20.0, 5.0, 0.0, 5.0)

- (BOOL)showSaveIcon
{
    return NO;
}

- (void)targetTextEditingViewWillAppear:(BOOL)appear {
    [super targetTextEditingViewWillAppear:appear];
    
    if (appear) {
        [self showButtons:YES animated:YES completion:nil];
    } else {
        
        [self showButtons:NO animated:NO completion:^{
            // Show placeholders.
            CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
            self.targetEditView.hidden = NO;
            targetTextBoxView.hidden = NO;
        }];
        
    }
}

#pragma mark - CKTextFieldEditViewController methods

- (CGFloat)textFieldTopOffset {
    return 185.0;
}

#pragma mark - Getters

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [CKEditingViewHelper cancelButtonWithTarget:self selector:@selector(cancelTapped:)];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _cancelButton.frame = CGRectMake(kEditButtonInsets.left,
                                         kEditButtonInsets.top,
                                         _cancelButton.frame.size.width,
                                         _cancelButton.frame.size.height);
    }
    return _cancelButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [CKEditingViewHelper okayButtonWithTarget:self selector:@selector(saveTapped:)];
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _saveButton.frame = CGRectMake(self.view.bounds.size.width - kEditButtonInsets.left - _saveButton.frame.size.width,
                                       kEditButtonInsets.top,
                                       _saveButton.frame.size.width,
                                       _saveButton.frame.size.height);
    }
    return _saveButton;
}

#pragma mark - Private methods

- (void)showButtons:(BOOL)show animated:(BOOL)animated completion:(void (^)())completion
{
    if (animated) {
        
        if (show) {
            self.saveButton.alpha = 0.0;
            self.cancelButton.alpha = 0.0;
            [self.view addSubview:self.saveButton];
            [self.view addSubview:self.cancelButton];
        }
        
        // Fade them in.
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.saveButton.alpha = show ? 1.0 : 0.0;
                             self.cancelButton.alpha = show ? 1.0 : 0.0;
                         }
                         completion:^(BOOL finished) {
                             if (!show) {
                                 [self.saveButton removeFromSuperview];
                                 [self.cancelButton removeFromSuperview];
                             }
                             if (completion)
                                 completion();
                         }];
    } else {
        if (show) {
            [self.view addSubview:self.saveButton];
            [self.view addSubview:self.cancelButton];
        } else {
            [self.saveButton removeFromSuperview];
            [self.cancelButton removeFromSuperview];
        }
        if (completion)
            completion();
    }
}


- (void)cancelTapped:(id)sender {
    [self dismissEditView];
}

- (void)saveTapped:(id)sender {
    [self doSave];
}

//Set font of title label with something controllable
- (UIFont *)titleFont {
    return [self.font fontWithSize:38.0];
}

- (UIOffset)titleOffsetAdjustments {
    return (UIOffset) { 0.0, 10.0 };
}

@end
