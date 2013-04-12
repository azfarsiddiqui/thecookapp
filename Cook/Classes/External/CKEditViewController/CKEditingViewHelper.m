//
//  CKEditingViewHelper.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingViewHelper.h"
#import "CKEditingTextBoxView.h"

@interface CKEditingViewHelper ()

@property (nonatomic, strong) NSMutableDictionary *editingViewTextBoxViews;

@end

@implementation CKEditingViewHelper

#define kContentInsets  UIEdgeInsetsMake(20.0, 34.0, 20.0, 34.0)
#define kTextBoxScale   0.98

- (id)init {
    if (self = [super init]) {
        self.editingViewTextBoxViews = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap {
    [self wrapEditingView:editingView wrap:wrap animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap animated:(BOOL)animated {
    [self wrapEditingView:editingView wrap:wrap target:nil selector:nil animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets {
    [self wrapEditingView:editingView wrap:wrap contentInsets:contentInsets animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
               animated:(BOOL)animated {
    [self wrapEditingView:editingView wrap:wrap contentInsets:contentInsets target:nil selector:nil animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap target:(id)target selector:(SEL)selector {
    [self wrapEditingView:editingView wrap:wrap target:target selector:selector animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap target:(id)target selector:(SEL)selector
               animated:(BOOL)animated {
    [self wrapEditingView:editingView wrap:wrap contentInsets:kContentInsets target:target selector:selector animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                 target:(id)target selector:(SEL)selector {
    [self wrapEditingView:editingView wrap:wrap contentInsets:contentInsets target:target selector:selector animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                 target:(id)target selector:(SEL)selector animated:(BOOL)animated {
    
    UIView *parentView = editingView.superview;
    
    if (wrap) {
        
        // Add a textbox.
        CKEditingTextBoxView *textBoxView = [[CKEditingTextBoxView alloc] initWithEditingFrame:editingView.frame
                                                                                 contentInsets:contentInsets
                                                                                         white:YES];
        [parentView insertSubview:textBoxView belowSubview:editingView];
        
        // Keep a reference to the textbox.
        [self.editingViewTextBoxViews setObject:textBoxView
                                         forKey:[NSValue valueWithNonretainedObject:editingView]];
        
        // Register tap on editing view.
        if (target != nil && [target respondsToSelector:selector]) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
            [textBoxView addGestureRecognizer:tapGesture];
        }
        
        if (animated) {
            
            // Prepare for transition.
            textBoxView.alpha = 0.0;
            textBoxView.transform = CGAffineTransformMakeScale(kTextBoxScale, kTextBoxScale);
            
            // Animate in the editing box.
            [UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 textBoxView.alpha = 1.0;
                                 textBoxView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
        
    } else {
        
        // Get the textbox belonging to the editinView.
        CKEditingTextBoxView *textEditImageView = [self textBoxViewForEditingView:editingView];
        
        if (animated) {
            
            // Animate in the editing box.
            [UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 textEditImageView.alpha = 0.0;
                                 textEditImageView.transform = CGAffineTransformMakeScale(kTextBoxScale, kTextBoxScale);
                             }
                             completion:^(BOOL finished) {
                                 
                                 // Remove the textbox.
                                 [textEditImageView removeFromSuperview];
                                 [self.editingViewTextBoxViews removeObjectForKey:[NSValue valueWithNonretainedObject:editingView]];
                                 
                             }];
        } else {
            
            // Remove the textbox.
            [textEditImageView removeFromSuperview];
            [self.editingViewTextBoxViews removeObjectForKey:[NSValue valueWithNonretainedObject:editingView]];
            
        }
    }
}

- (CKEditingTextBoxView *)textBoxViewForEditingView:(UIView *)editingView {
    return [self.editingViewTextBoxViews objectForKey:[NSValue valueWithNonretainedObject:editingView]];
}

#pragma mark - Private methods

@end
