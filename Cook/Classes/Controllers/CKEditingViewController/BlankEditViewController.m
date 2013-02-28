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

-(id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate sourceEditingView:(UIView *)sourceEditingView
{
    if (self = [super initWithDelegate:delegate sourceEditingView:sourceEditingView]) {
    }
    return self;
}
- (UIView *)createTargetEditingView {
    UIEdgeInsets mainViewInsets = UIEdgeInsetsMake(100.0f,100.0f,100.0f,100.0f);
    
    CGRect frame = CGRectMake(mainViewInsets.left,
                              mainViewInsets.top,
                              self.view.bounds.size.width - mainViewInsets.left - mainViewInsets.right,
                              self.view.bounds.size.height - mainViewInsets.top - mainViewInsets.bottom);
    UIView *mainView = [[UITextView alloc] initWithFrame:frame];
    mainView.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.5f];
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
        [self addDoneButton];
        [self setValues];
    }
}

#pragma mark - Private Methods
- (void)addDoneButton {
    
    UIView *mainView = (UIView *)self.targetEditingView;
    self.doneButton.frame = CGRectMake(mainView.frame.origin.x + mainView.frame.size.width - floorf(self.doneButton.frame.size.width / 2.0),
                                       mainView.frame.origin.y - floorf(self.doneButton.frame.size.height / 3.0),
                                       self.doneButton.frame.size.width,
                                       self.doneButton.frame.size.height);
    [self.view addSubview:self.doneButton];
}

- (void)setValues {
    
}

@end

