//
//  CKEditingViewHelper.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKEditingViewHelper.h"

@interface CKEditingViewHelper ()

@property (nonatomic, strong) NSMutableDictionary *editingViewTextBoxViews;

@end

@implementation CKEditingViewHelper

#define kContentInsets  UIEdgeInsetsMake(30.0, 34.0, 10.0, 34.0)
#define kTextBoxScale   0.98

- (id)init {
    if (self = [super init]) {
        self.editingViewTextBoxViews = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)unwrapEditingView:(UIView *)editingView {
    [self unwrapEditingView:editingView animated:YES];
}

- (void)unwrapEditingView:(UIView *)editingView animated:(BOOL)animated {
    // Get the textbox belonging to the editingView.
    CKEditingTextBoxView *textEditImageView = [self textBoxViewForEditingView:editingView];
    
    // Return immediately if none was found.
    if (textEditImageView == nil) {
        return;
    }
    
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

- (void)wrapEditingView:(UIView *)editingView white:(BOOL)white {
    
    [self wrapEditingView:editingView delegate:nil white:white animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView white:(BOOL)white animated:(BOOL)animated {
    
    [self wrapEditingView:editingView delegate:nil white:white animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
                  white:(BOOL)white {
    
    [self wrapEditingView:editingView contentInsets:contentInsets white:white animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white
               animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:nil white:white animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white {
    
    [self wrapEditingView:editingView delegate:delegate white:white animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white
               animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:kContentInsets delegate:delegate white:white
                 animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:delegate white:white animated:YES];
}

- (void)updateEditingView:(UIView *)editingView {
    [self updateEditingView:editingView animated:YES];
}

- (void)updateEditingView:(UIView *)editingView animated:(BOOL)animated {
    CKEditingTextBoxView *textBoxView = [self textBoxViewForEditingView:editingView];
    [textBoxView updateEditingView:editingView];
}

- (CKEditingTextBoxView *)textBoxViewForEditingView:(UIView *)editingView {
    return [self.editingViewTextBoxViews objectForKey:[NSValue valueWithNonretainedObject:editingView]];
}

#pragma mark - Private methods

- (void)decorateEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                   delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white animated:(BOOL)animated {
    
    UIView *parentView = editingView.superview;
    
    if (wrap) {
        
        // Return immediately if editing view has already been created.
        if ([self textBoxViewForEditingView:editingView] != nil) {
            return;
        }
        
        // Add a textbox.
        CKEditingTextBoxView *textBoxView = [[CKEditingTextBoxView alloc] initWithEditingView:editingView
                                                                                contentInsets:contentInsets
                                                                                        white:white
                                                                                     delegate:delegate];
        [parentView insertSubview:textBoxView belowSubview:editingView];
        
        // Keep a reference to the textbox.
        [self.editingViewTextBoxViews setObject:textBoxView
                                         forKey:[NSValue valueWithNonretainedObject:editingView]];
        
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
        [self unwrapEditingView:editingView animated:animated];
    }
}

@end
