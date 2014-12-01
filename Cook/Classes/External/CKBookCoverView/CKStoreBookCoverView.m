//
//  CKStoreBookCoverView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKStoreBookCoverView.h"
#import "CKActivityIndicatorView.h"
#import "ViewHelper.h"
#import "CKBook.h"

@interface CKStoreBookCoverView ()

@property (nonatomic, strong) UIButton *bookActionButton;
@property (nonatomic, strong) CKActivityIndicatorView *bookActionActivityView;
@property (nonatomic, assign) BOOL followed;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL wasActioned;

@end

@implementation CKStoreBookCoverView

- (id)init {
    if (self = [super init]) {
        self.wasActioned = NO;
    }
    return self;
}

- (void)showActionButton:(BOOL)show animated:(BOOL)animated {
    if (show) {
        
        if (!self.bookActionButton.superview) {
            [self addSubview:self.bookActionButton];
        }
        
        if (animated) {
            if (self.animating) {
                return;
            }
            self.animating = YES;
            self.bookActionButton.alpha = 0.0;
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.bookActionButton.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 self.animating = NO;
                             }];
        } else {
            self.bookActionButton.alpha = 1.0;
        }
        
    } else {
        
        if (animated) {
            if (self.animating) {
                return;
            }
            self.animating = YES;
            
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.bookActionButton.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 self.animating = NO;
                             }];
        } else {
            self.bookActionButton.alpha = 0.0;
        }
    }
}

- (void)showLoading:(BOOL)loading {
    //Figure out why action button is still disabled when adding extra clause to this if statement
    if (loading && !self.wasActioned) {
        if (!self.bookActionActivityView.superview) {
            CGRect actionActivityFrame = self.bookActionActivityView.frame;
            actionActivityFrame.origin = (CGPoint) {
                floorf((self.bookActionButton.bounds.size.width - actionActivityFrame.size.width) / 2.0),
                floorf((self.bookActionButton.bounds.size.height - actionActivityFrame.size.height) / 2.0) - 8.0
            };
            self.bookActionActivityView.frame = actionActivityFrame;
            [self.bookActionButton addSubview:self.bookActionActivityView];
        }
        
        [self.bookActionButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_blank.png"]
                                         forState:UIControlStateNormal];
        [self.bookActionActivityView startAnimating];
        [self enable:!loading interactable:!loading];
    } else {
        [self.bookActionActivityView stopAnimating];
    }
}

- (void)showAdd {
    self.followed = NO;
    self.locked = NO;
    [self.bookActionActivityView stopAnimating];
    [self updateActionButtonImage];
    [self enable:YES interactable:YES];
}

- (void)showFollowed {
    self.followed = YES;
    self.locked = NO;
    [self.bookActionActivityView stopAnimating];
    [self updateActionButtonImage];
    [self enable:YES interactable:NO];
}

- (void)showLocked {
    self.followed = NO;
    self.locked = YES;
    [self.bookActionActivityView stopAnimating];
    [self updateActionButtonImage];
    [self enable:YES interactable:NO];
}

- (void)showDownloadable {
    self.followed = NO;
    self.locked = NO;
    [self.bookActionActivityView stopAnimating];
    [self updateActionButtonImage];
    [self enable:YES interactable:YES];
}

- (void)enable:(BOOL)enable interactable:(BOOL)interactable {
    self.bookActionButton.enabled = enable;
    self.bookActionButton.userInteractionEnabled = interactable;
}

#pragma mark - Properties

- (UIButton *)bookActionButton {
    if (!_bookActionButton && ![self.book isOwner]) {
        _bookActionButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_blank.png"]
                                                 target:self selector:@selector(actionButtonTapped:)];
        CGRect actionButtonFrame = _bookActionButton.frame;
        actionButtonFrame.origin = (CGPoint) {
            floorf((self.bounds.size.width - actionButtonFrame.size.width) / 2.0),
            floorf((self.bounds.size.height - actionButtonFrame.size.height) / 2.0)
        };
        _bookActionButton.frame = actionButtonFrame;
    }
    return _bookActionButton;
}

- (CKActivityIndicatorView *)bookActionActivityView {
    if (!_bookActionActivityView) {
        _bookActionActivityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
    }
    return _bookActionActivityView;
}

- (void)updateActionButtonImage {
    if (self.followed) {
        [self.bookActionButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_added.png"]
                                         forState:UIControlStateNormal];
        [self.bookActionButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    } else if (self.locked) {
        [self.bookActionButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_private.png"]
                                         forState:UIControlStateNormal];
        [self.bookActionButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    } else {
        [self.bookActionButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_addtodash.png"]
                                         forState:UIControlStateNormal];
        [self.bookActionButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_addtodash_onpress.png"]
                                         forState:UIControlStateHighlighted];
    }
    self.wasActioned = YES;
}

- (void)actionButtonTapped:(id)sender {
    if ([self.storeDelegate respondsToSelector:@selector(storeBookCoverViewAddRequested)]) {
        [self.storeDelegate storeBookCoverViewAddRequested];
    }
}

@end
