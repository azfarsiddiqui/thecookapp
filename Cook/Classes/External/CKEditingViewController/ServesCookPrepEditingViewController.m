//
//  ServesEditingViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/20/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesCookPrepEditingViewController.h"
#import "CKEditingTextField.h"
#import "Theme.h"


//@interface ServesCookPrepEditingViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
//@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic,assign)  NSInteger serves;
//
//@end

@interface ServesCookPrepEditingViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *limitLabel;

@end

@implementation ServesCookPrepEditingViewController

-(id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate sourceEditingView:(UIView *)sourceEditingView
{
    if (self = [super initWithDelegate:delegate sourceEditingView:sourceEditingView]) {
        [self style];
    }
    return self;
}
- (UIView *)createTargetEditingView {
    UIEdgeInsets mainViewInsets = UIEdgeInsetsMake(75.0, 50.0, 400.0, 50.0);
    
    CGRect frame = CGRectMake(mainViewInsets.left,
                              mainViewInsets.top,
                              self.view.bounds.size.width - mainViewInsets.left - mainViewInsets.right,
                              self.view.bounds.size.height - mainViewInsets.top - mainViewInsets.bottom);
    UIView *mainView = [[UITextView alloc] initWithFrame:frame];
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
        [self addSubviews];
    }
}

- (void)performSave {
    
    UIView *mainView = (UIView *)self.targetEditingView;
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:nil];
    [super performSave];
}


#pragma mark - Private Methods

-(void)style
{
//    self.editableTextFont = [Theme textEditableTextFont];
//    self.titleFont = [Theme textViewTitleFont];
    
}
-(void)addSubviews
{
    [self addDoneButton];
}

- (void)addDoneButton {
    UIView *mainView = (UIView *)self.targetEditingView;
    self.doneButton.frame = CGRectMake(mainView.frame.origin.x + mainView.frame.size.width - floorf(self.doneButton.frame.size.width / 2.0),
                                       mainView.frame.origin.y - floorf(self.doneButton.frame.size.height / 3.0),
                                       self.doneButton.frame.size.width,
                                       self.doneButton.frame.size.height);
    [self.view addSubview:self.doneButton];
}
@end

