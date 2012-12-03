//
//  ServesView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesView.h"
#import "Theme.h"

@interface ServesView()<UIPopoverControllerDelegate, UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,strong) UILabel *numServesLabel;
@property (nonatomic,strong) UIPopoverController *popoverController;

@end
@implementation ServesView

//overridden
-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
    self.numServesLabel.textColor = editable ? [UIColor blackColor] : [UIColor darkGrayColor];
}

#pragma mark - Private methods

//overridden
-(void)styleViews
{
    self.numServesLabel.font = [Theme defaultLabelFont];
    self.numServesLabel.textColor = [Theme directionsLabelColor];
    self.numServesLabel.backgroundColor = [UIColor clearColor];

}

-(void)configViews
{
    self.numServesLabel.frame = CGRectMake(35.0f, 2.0f, self.bounds.size.width-35.0f, self.bounds.size.height);
    self.numServesLabel.text = [NSString stringWithFormat:@"%i",self.serves];
}

-(UILabel *)numServesLabel
{
    if (!_numServesLabel) {
        _numServesLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _numServesLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *servesTappedRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(servesTapped:)];
        [_numServesLabel addGestureRecognizer:servesTappedRecognizer];

        [self addSubview:_numServesLabel];
    }
    return _numServesLabel;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark - UIPopoverDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    DLog();
    self.popoverController = nil;
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.serves = row;
    self.numServesLabel.text = [NSString stringWithFormat:@"%i", row];
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

#pragma mark - Private Methods
-(void)servesTapped:(UILabel*)label
{
    if (self.editMode == YES ) {
        
        UIViewController* popoverContent = [[UIViewController alloc] init];
        
        UIPickerView *servesPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        servesPickerView.frame = CGRectMake(0,44,320, 216);
        servesPickerView.showsSelectionIndicator = YES;
        servesPickerView.delegate = self;
        servesPickerView.dataSource = self;
        [popoverContent.view addSubview:servesPickerView];
        [servesPickerView selectRow:self.serves inComponent:0 animated:NO];
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.delegate=self;
        [self.popoverController setPopoverContentSize:CGSizeMake(320.0f, 264) animated:NO];
        [self.popoverController presentPopoverFromRect:self.numServesLabel.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];

    }
}
@end
