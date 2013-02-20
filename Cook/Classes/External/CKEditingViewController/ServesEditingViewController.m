//
//  ServesEditingViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/20/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesEditingViewController.h"

@interface ServesEditingViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic,assign)  NSInteger serves;

@end

@implementation ServesEditingViewController

#pragma mark - CKEditingViewController methods

- (UIView *)createTargetEditingView {
    //picker
    
    UIPickerView *servesPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    servesPickerView.frame = CGRectMake(0.0f,0.0f,320, 216);
    servesPickerView.showsSelectionIndicator = YES;
    servesPickerView.delegate = self;
    servesPickerView.dataSource = self;
    
    [servesPickerView selectRow:self.serves inComponent:0 animated:NO];
    return servesPickerView;
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
//        UIPickerView *pickerView = (UIPickerView *)self.targetEditingView;
//        initialization code here - or reset
    }
}

- (void)performSave {
    
    UIPickerView *pickerView = (UIPickerView *)self.targetEditingView;
//    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:pickerView.];
    
    [super performSave];
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.serves = row;
}
#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 12;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%2d",row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 40.0f;
}


#pragma mark - Private methods

- (void)addSubviews {
    [self addDoneButton];
    [self addTitleLabel];
}

- (void)addTitleLabel {
    UIPickerView *pickerView = (UIPickerView *)self.targetEditingView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.text = self.editingTitle;
//    titleLabel.font = self.titleFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(pickerView.frame.origin.x + floorf((pickerView.frame.size.width - titleLabel.frame.size.width) / 2.0),
                                  pickerView.frame.origin.y - titleLabel.frame.size.height + 5.0,
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

