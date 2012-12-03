//
//  CookingTimeView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CookingTimeView.h"
#import "ViewHelper.h"
#import "Theme.h"

#define FIFTEEN_MINUTES 900.0f

@interface CookingTimeView()<UIPopoverControllerDelegate>
@property(nonatomic,strong) UILabel *cookingTimeLabel;
@property(nonatomic,strong) UIPopoverController *popoverController;
@property (nonatomic,strong) UIImageView *backgroundEditImageView;
@end
@implementation CookingTimeView

//overridden
-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
    self.backgroundEditImageView.hidden = !editable;
    self.cookingTimeLabel.textColor = editable ? [UIColor blackColor] : [UIColor darkGrayColor];
}

#pragma mark - Private methods

//overridden
-(void)styleViews
{
    self.cookingTimeLabel.font = [Theme defaultLabelFont];
    self.cookingTimeLabel.textColor = [Theme directionsLabelColor];
    self.cookingTimeLabel.backgroundColor = [UIColor clearColor];
    
}

-(void)configViews
{
    if (self.cookingTimeInSeconds > 0.0f) {
        [self refreshTextForCookingTime];
    }
}

-(UILabel *)cookingTimeLabel
{
    if (!_cookingTimeLabel) {
        _cookingTimeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _cookingTimeLabel.text = @"cooking time";
        _cookingTimeLabel.userInteractionEnabled = YES;
        _cookingTimeLabel.frame = CGRectMake(35.0f, 0.0f, 90.0f,21.0f);

        UITapGestureRecognizer *cookingTimeRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cookingTimeTapped:)];
        [_cookingTimeLabel addGestureRecognizer:cookingTimeRecognizer];
        [self addSubview:_cookingTimeLabel];
    }
    return _cookingTimeLabel;
}

-(UIImageView *)backgroundEditImageView
{
    if (!_backgroundEditImageView) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"cook_editrecipe_textbox"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f,4.0f,4.0f,4.0f)];
        _backgroundEditImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
        _backgroundEditImageView.hidden = YES;
        _backgroundEditImageView.image = backgroundImage;
        [self insertSubview:_backgroundEditImageView atIndex:0];
    }
    return _backgroundEditImageView;
}

-(void) cookingTimeTapped:(UILabel*)gestureRecognizer;
{
    if ([self inEditMode]) {
        DLog();
        UIViewController* popoverContent = [[UIViewController alloc] init];
        
        UIDatePicker *datePicker=[[UIDatePicker alloc]init];
        datePicker.frame=CGRectMake(0,44,320, 216);
        datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
        [datePicker setMinuteInterval:15];
        
        if (self.cookingTimeInSeconds > 0.0f) {
            datePicker.countDownDuration = self.cookingTimeInSeconds;
        } else {
            self.cookingTimeInSeconds = FIFTEEN_MINUTES;
        }

        [self refreshTextForCookingTime];
        
        [datePicker addTarget:self action:@selector(cookingTimeChanged:) forControlEvents:UIControlEventValueChanged];
        [popoverContent.view addSubview:datePicker];
        
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popoverController.delegate=self;
        [self.popoverController setPopoverContentSize:CGSizeMake(320, 264) animated:NO];
        [self.popoverController presentPopoverFromRect:self.cookingTimeLabel.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
}


-(void)cookingTimeChanged:(UIDatePicker*)datePicker
{
    self.cookingTimeInSeconds = datePicker.countDownDuration;
    [self refreshTextForCookingTime];
}

-(void)refreshTextForCookingTime
{
    self.cookingTimeLabel.text = [ViewHelper formatAsHoursSeconds:self.cookingTimeInSeconds];
    [self.cookingTimeLabel sizeToFit];
}
@end
