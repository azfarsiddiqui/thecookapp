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

#define kContentEditInsets  (UIEdgeInsets){ 16.0, 32.0, 11.0, 42.0 }
#define kContentInsets      (UIEdgeInsets){ 16.0, 28.0, 11.0, 38.0 }
#define kTextBoxInsets      (UIEdgeInsets){ 15.0, 12.0, 12.0, 22.0 }
#define kTextBoxScale       0.98

+ (CGFloat)singleLineHeightForFont:(UIFont *)font size:(CGSize)size {
    return [@"A" sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByClipping].height;
}

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
    
    [self decorateEditingView:editingView wrap:YES contentInsets:[CKEditingViewHelper contentInsetsForEditMode:YES]
                     delegate:nil white:white animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView white:(BOOL)white animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:[CKEditingViewHelper contentInsetsForEditMode:YES]
                     delegate:nil white:white animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
                  white:(BOOL)white {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:nil white:white animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white
               animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:nil white:white animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:[CKEditingViewHelper contentInsetsForEditMode:YES]
                     delegate:delegate white:white animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white
               editMode:(BOOL)editMode {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:[CKEditingViewHelper contentInsetsForEditMode:editMode]
                     delegate:delegate white:white editMode:editMode animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white
               animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:[CKEditingViewHelper contentInsetsForEditMode:YES]
                     delegate:delegate white:white animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white
               editMode:(BOOL)editMode animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:[CKEditingViewHelper contentInsetsForEditMode:editMode]
                     delegate:delegate white:white editMode:editMode animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:delegate white:white
                     animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:delegate white:white
                     animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white editMode:(BOOL)editMode {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:delegate white:white
                     editMode:editMode animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white iconImage:(UIImage *)iconImage
{
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:delegate white:white
                     editMode:NO iconImage:iconImage onpress:YES animated:YES];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white editMode:(BOOL)editMode
               animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:delegate white:white
                     editMode:editMode iconImage:nil onpress:YES animated:animated];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white editMode:(BOOL)editMode
                onpress:(BOOL)onpress animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:YES contentInsets:contentInsets delegate:delegate white:white
                     editMode:editMode iconImage:nil onpress:onpress animated:animated];
}

- (BOOL)alreadyWrappedForEditingView:(UIView *)editingView {
    return ([self textBoxViewForEditingView:editingView] != nil);
}

- (void)updateEditingView:(UIView *)editingView {
    [self updateEditingView:editingView animated:YES];
}

- (void)updateEditingView:(UIView *)editingView animated:(BOOL)animated {
    [self updateEditingView:editingView updated:NO animated:animated];
}

- (void)updateEditingView:(UIView *)editingView updated:(BOOL)updated animated:(BOOL)animated {
    CKEditingTextBoxView *textBoxView = [self textBoxViewForEditingView:editingView];
    [textBoxView updateEditingView:editingView updated:updated];
}

- (CKEditingTextBoxView *)textBoxViewForEditingView:(UIView *)editingView {
    return [self.editingViewTextBoxViews objectForKey:[NSValue valueWithNonretainedObject:editingView]];
}

+ (UIEdgeInsets)contentInsetsForEditMode:(BOOL)editMode {
    if (editMode) {
        return kContentEditInsets;
    } else {
        return kContentInsets;
    }
}

+ (UIEdgeInsets)textBoxInsets {
    return kTextBoxInsets;
}

#pragma mark - Buttons

+ (UIButton *)okayButtonWithTarget:(id)target selector:(SEL)selector {
    return [self buttonWithImage:[UIImage imageNamed:@"cook_btns_okay.png"]
                   selectedImage:[UIImage imageNamed:@"cook_btns_okay_onpress.png"] target:target selector:selector];
}

+ (UIButton *)cancelButtonWithTarget:(id)target selector:(SEL)selector {
    return [self buttonWithImage:[UIImage imageNamed:@"cook_btns_cancel.png"]
                   selectedImage:[UIImage imageNamed:@"cook_btns_cancel_onpress.png"] target:target selector:selector];
}

+ (UIButton *)deleteButtonWithTarget:(id)target selector:(SEL)selector {
    return [self buttonWithImage:[UIImage imageNamed:@"cook_btns_delete.png"]
                   selectedImage:[UIImage imageNamed:@"cook_btns_delete_onpress.png"] target:target selector:selector];
}

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    return [self buttonWithImage:image selectedImage:nil target:target selector:selector];
}

+ (UIButton *)buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(id)target
                     selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    if (selectedImage) {
        [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
        [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    }
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    button.userInteractionEnabled = (target != nil && selector != nil);
    button.autoresizingMask = UIViewAutoresizingNone;
    return button;
}

#pragma mark - Tint colour

+ (UIColor *)existingAppTextInputColour {
    
    // Just pick the textfield's tint colour.
    return [[UITextField appearance] tintColor];
}

+ (void)setTextInputTintColour:(UIColor *)colour {
    [[UITextView appearance] setTintColor:colour];
    [[UITextField appearance] setTintColor:colour];
}

+ (void)resetTextInputTintColour {
    [[UITextView appearance] setTintColor:nil];
    [[UITextField appearance] setTintColor:nil];
}

#pragma mark - Private methods

- (void)decorateEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                   delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:wrap contentInsets:contentInsets delegate:delegate white:white
                     editMode:YES animated:animated];
}

- (void)decorateEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                   delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white editMode:(BOOL)editMode
                   animated:(BOOL)animated {
    
    [self decorateEditingView:editingView wrap:wrap contentInsets:contentInsets delegate:delegate white:white
                     editMode:editMode iconImage:nil onpress:YES animated:animated];
    
}

- (void)decorateEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                   delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white editMode:(BOOL)editMode
                  iconImage:(UIImage *)iconImage onpress:(BOOL)onpress animated:(BOOL)animated {
    
    UIView *parentView = editingView.superview;
    
    if (wrap) {
        
        // Return immediately if editing view has already been created.
        if ([self textBoxViewForEditingView:editingView] != nil) {
            return;
        }
        
        UIEdgeInsets resolvedInsets = contentInsets;
        //If icon image, add space to insets to account for image
        if (iconImage)
        {
            resolvedInsets = UIEdgeInsetsMake(contentInsets.top, contentInsets.left + iconImage.size.width, contentInsets.bottom, contentInsets.right);
        }
        
        // Add a textbox.
        CKEditingTextBoxView *textBoxView = [[CKEditingTextBoxView alloc] initWithEditingView:editingView
                                                                                contentInsets:resolvedInsets
                                                                                        white:white
                                                                                     editMode:editMode
                                                                                      onpress:onpress
                                                                                     delegate:delegate];
        //Add icon image if exists to left of text
        if (iconImage)
        {
            UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
            iconImageView.frame = CGRectMake(contentInsets.left - 5, contentInsets.top + 2, iconImageView.frame.size.width, iconImageView.frame.size.height);
            [textBoxView addSubview:iconImageView];
            textBoxView.iconImageView = iconImageView;
        }
        
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
