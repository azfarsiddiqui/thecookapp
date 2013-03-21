//
//  BlankEditViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/28/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BlankEditViewController.h"

@interface BlankEditViewController ()
@property(nonatomic,strong) UIView *mostlyBlackView;
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
    
    UIView *mainView = [[UIView alloc] initWithFrame:frame];
    mainView.backgroundColor = [UIColor clearColor];

    //two views

    //UIView
    CGRect adjustForTopPaddingRect = CGRectMake(0.0f, 20.0f, mainView.frame.size.width, mainView.frame.size.height-20.0f);
    UIView *mostlyBlackView = [[UIView alloc]initWithFrame:adjustForTopPaddingRect];
    mostlyBlackView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    mostlyBlackView.backgroundColor = [UIColor blackColor];
    self.mostlyBlackView = mostlyBlackView;
    [mainView addSubview:mostlyBlackView];
    
    return mainView;
}

-(void)updateViewAlphas:(float)alpha
{
    self.targetEditingView.backgroundColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:alpha];
    self.mostlyBlackView.alpha = alpha;

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

