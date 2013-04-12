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

#define kContentInsets  UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)

+ (CKEditingViewHelper *)sharedInstance {
    static dispatch_once_t pred;
    static CKEditingViewHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CKEditingViewHelper alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.editingViewTextBoxViews = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)wrapEditingView:(UIView *)editingView {
    [self wrapEditingView:editingView wrap:YES contentInsets:kContentInsets];
}

- (void)unwrapEditingView:(UIView *)editingView {
    [self wrapEditingView:editingView wrap:NO contentInsets:kContentInsets];
}

- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets {
    [self wrapEditingView:editingView wrap:YES contentInsets:contentInsets];
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap {
    [self wrapEditingView:editingView wrap:wrap contentInsets:kContentInsets];
}

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets {
    UIView *parentView = editingView.superview;
    
    if (wrap) {
        UIImageView *textEditImageView = [[UIImageView alloc] initWithImage:[self textEditingBoxWhite:YES]];
        textEditImageView.frame = CGRectMake(editingView.frame.origin.x - contentInsets.left,
                                             editingView.frame.origin.y - contentInsets.top,
                                             contentInsets.left + editingView.frame.size.width + contentInsets.right,
                                             contentInsets.top + editingView.frame.size.height + contentInsets.bottom);
        [parentView insertSubview:textEditImageView belowSubview:editingView];
        
        // Keep a reference to the textbox.
        [self.editingViewTextBoxViews setObject:textEditImageView forKey:[NSValue valueWithNonretainedObject:editingView]];
        
    } else {
        
        // Remove the textbox.
        UIView *textEditImageView = [self.editingViewTextBoxViews objectForKey:[NSValue valueWithNonretainedObject:editingView]];
        [textEditImageView removeFromSuperview];
        [self.editingViewTextBoxViews removeObjectForKey:[NSValue valueWithNonretainedObject:editingView]];
        
    }
}

#pragma mark - Private methods

- (UIImage *)textEditingBoxWhite:(BOOL)white {
    UIImage *textEditingImage = nil;
    if (white) {
        textEditingImage = [[UIImage imageNamed:@"cook_customise_textbox_white.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)];
    } else {
        textEditingImage = [[UIImage imageNamed:@"cook_customise_textbox_white.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)];
    }
    return textEditingImage;
}

@end
