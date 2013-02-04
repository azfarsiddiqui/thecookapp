//
//  IngredientsEditingViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/4/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientsEditingViewController.h"
#import "CKEditingTextField.h"
#import "CKTextFieldEditingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface IngredientsEditingViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation IngredientsEditingViewController

#pragma mark - CKEditingViewController methods

- (UIView *)createTargetEditingView {
    UIEdgeInsets tableViewInsets = UIEdgeInsetsMake(0.0, 50.0, 0.0, 50.0);
    CGSize tableSize = CGSizeMake(100.0f, 100.0f);
    CGRect frame = CGRectMake(tableViewInsets.left,
                              floorf(0.5f*(self.view.bounds.size.height - tableSize.width)),
                              self.view.bounds.size.width - tableViewInsets.left - tableViewInsets.right,
                              tableSize.height -tableViewInsets.top -tableViewInsets.bottom);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor greenColor];
    return view;
}

- (void)editingViewWillAppear:(BOOL)appear {
    if (!appear) {
        [self.doneButton removeFromSuperview];
        [self.titleLabel removeFromSuperview];
    }
    [super editingViewWillAppear:appear];
}

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    
    if (appear) {
        [self addSubviews];
        //appearing set data HERE
    }
}

- (void)editingViewKeyboardWillAppear:(BOOL)appear keyboardFrame:(CGRect)keyboardFrame {
    [super editingViewKeyboardWillAppear:appear keyboardFrame:keyboardFrame];
    DLog(@"keyboard will appear: %i", appear);
}

- (void)performSave {
    
    UIView *tableView = (UIView *)self.targetEditingView;
    //result of a save - from incumbent view
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:@"performSave"];
    
    [super performSave];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self performSave];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL isBackspace = [newString length] < [textField.text length];
    
    if ([textField.text length] >= self.characterLimit && !isBackspace) {
        return NO;
    }
    
    // No save if no characters
    self.doneButton.enabled = [newString length] > 0;
    
    return YES;
}

#pragma mark - Private methods

- (void)addSubviews {
    [self addDoneButton];
    [self addTitleLabel];
}

- (void)addTitleLabel {
    UIView *tableView = (UIView *)self.targetEditingView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = self.editingTitle;
    titleLabel.font = self.titleFont;
    titleLabel.textColor = [UIColor blueColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(tableView.frame.origin.x + floorf((tableView.frame.size.width - titleLabel.frame.size.width) / 2.0),
                                  tableView.frame.origin.y - titleLabel.frame.size.height + 5.0,
                                  titleLabel.frame.size.width,
                                  titleLabel.frame.size.height);
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)addDoneButton {
    UITextField *textField = (UITextField *)self.targetEditingView;
    
    self.doneButton.frame = CGRectMake(textField.frame.origin.x + textField.frame.size.width - floorf(self.doneButton.frame.size.width / 2.0),
                                       textField.frame.origin.y - floorf(self.doneButton.frame.size.height / 3.0),
                                       self.doneButton.frame.size.width,
                                       self.doneButton.frame.size.height);
    [self.view addSubview:self.doneButton];
}

@end
