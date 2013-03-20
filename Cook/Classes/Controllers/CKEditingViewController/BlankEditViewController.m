//
//  BlankEditViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/28/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BlankEditViewController.h"

@interface BlankEditViewController ()
@end

@implementation BlankEditViewController

-(id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate sourceEditingView:(CKEditableView *)sourceEditingView
{
    if (self = [super initWithDelegate:delegate sourceEditingView:sourceEditingView]) {
        self.backgroundAlpha = 0.0f;
        self.mainViewInsets = UIEdgeInsetsMake(100.0f,100.0f,100.0f,100.0f);
    }
    return self;
}
- (UIView *)createTargetEditingView {
    
    CGRect frame = CGRectMake(self.mainViewInsets.left,
                              self.mainViewInsets.top,
                              self.view.bounds.size.width - self.mainViewInsets.left - self.mainViewInsets.right,
                              self.view.bounds.size.height - self.mainViewInsets.top - self.mainViewInsets.bottom);
    UIView *mainView = [[UITextView alloc] initWithFrame:frame];
    mainView.backgroundColor = [UIColor blackColor];
    return mainView;
}

//overridden methods

- (void)editingViewWillAppear:(BOOL)appear {
    [super editingViewWillAppear:appear];
    if (!appear) {
        [self.doneButton removeFromSuperview];
    }
    
}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    if (appear) {
        [self setValues];
    }
}

#pragma mark - Private Methods

- (void)setValues {
    
}

@end

