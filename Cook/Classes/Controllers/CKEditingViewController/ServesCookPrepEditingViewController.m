//
//  ServesEditingViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 2/20/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesCookPrepEditingViewController.h"
#import "Theme.h"
#import "UIColor+Expanded.h"

#define kPickerWidth        200.0f
#define kPaddingPickers     50.0f
#define kSliderWidth        600.0f
#define kPickerHeight       100.0f
#define kPickerRowHeight    30.0f
#define kLabelTag 1122334455
#define kContentViewInsets  UIEdgeInsetsMake(20.0f,20.0f,20.0f,20.0f)

@interface ServesCookPrepEditingViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
//ui
@property (nonatomic, strong) UILabel *servesLabel;
@property (nonatomic, strong) UILabel *servesNumberLabel;
@property (nonatomic, strong) UILabel *prepLabel;
@property (nonatomic, strong) UILabel *cookLabel;
@property (nonatomic, strong) UISlider *servesSlider;
@property (nonatomic, strong) UIPickerView *cookingTimePickerView;
@property (nonatomic, strong) UIPickerView *prepTimePickerView;

//data
@property (nonatomic, strong) NSArray *cookingTimeArray;
@property (nonatomic, strong) NSArray *prepTimeArray;
@end

@implementation ServesCookPrepEditingViewController

-(id)initWithDelegate:(id<EditingViewControllerDelegate>)delegate
{
    if (self = [super initWithDelegate:delegate]) {
        self.contentViewInsets = kContentViewInsets;
        [self dataForArrays];
    }
    return self;
}
-(id)initWithDelegate:(id<EditingViewControllerDelegate>)delegate sourceEditingView:(CKEditableView *)sourceEditingView
{
    if (self = [super initWithDelegate:delegate sourceEditingView:sourceEditingView]) {
        self.contentViewInsets = kContentViewInsets;
        [self dataForArrays];
    }
    return self;
}

- (UIView *)createTargetEditingView {
    UIView *mainView = [super createTargetEditingView];
    mainView.backgroundColor = [UIColor blackColor];
    [self addSubviews:mainView];
    return mainView;
}

//overridden methods

- (void)editingViewDidAppear:(BOOL)appear {
    [super editingViewDidAppear:appear];
    if (appear) {
        [self setValues];
    }
}

- (void)performSave {
    
    NSDictionary *values = @{@"serves": [NSNumber numberWithInt:self.numServes],
                             @"cookTime":  [NSNumber numberWithInt:self.cookingTimeInMinutes],
                             @"prepTime":  [NSNumber numberWithInt:self.prepTimeInMinutes]};
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:values];
    [super performSave];
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == self.cookingTimePickerView)	// don't show selection for the custom picker
	{
        self.cookingTimeInMinutes = [[self.cookingTimeArray objectAtIndex:row] integerValue];
	} else {
        self.prepTimeInMinutes = [[self.prepTimeArray objectAtIndex:row] integerValue];
    }
}

#pragma mark -
#pragma mark UIPickerViewDataSource

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel*)view;
    if (!label) {
        label = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kPickerWidth, kPickerRowHeight)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [Theme cookPrepPickerFont];
    }
    
	if (pickerView == self.cookingTimePickerView)
	{
        label.text = [NSString stringWithFormat:@"%@ mins", [[self.cookingTimeArray objectAtIndex:row] stringValue]];
	} else {
        label.text = [NSString stringWithFormat:@"%@ mins", [[self.prepTimeArray objectAtIndex:row] stringValue]];
    }
    
    return label;
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return kPickerWidth - 10.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return kPickerRowHeight;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.cookingTimePickerView) {
        return [self.cookingTimeArray count];
    } else {
        return [self.prepTimeArray count];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

#pragma mark - Slider action
-(void)servesSlid:(UISlider*)slider
{
    self.numServes = roundf(slider.value);
    self.servesNumberLabel.text = [NSString stringWithFormat:@"%0.0f", roundf(slider.value)];
}

#pragma mark - Private Methods

-(void)addSubviews:(UIView*)mainView
{
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(floorf(0.5*(mainView.frame.size.width - kSliderWidth)),
                                                                   200.0f,
                                                                   kSliderWidth, 400)];

    containerView.backgroundColor = [UIColor clearColor];
    
    
    self.servesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 50.0f, mainView.frame.size.width, 50.0f)];
    self.servesLabel.backgroundColor = [UIColor clearColor];
    self.servesLabel.textAlignment = NSTextAlignmentCenter;
    self.servesLabel.font = [Theme cookServesPrepEditTitleFont];
    self.servesLabel.textColor = [Theme cookServesPrepEditTitleColor];
    self.servesLabel.text = @"SERVES";

    [mainView addSubview:self.servesLabel];

    self.servesNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(560.0f, 50.0f, 100.0f, 50.0f)];
    self.servesNumberLabel.backgroundColor = [UIColor clearColor];
    self.servesNumberLabel.textAlignment = NSTextAlignmentCenter;
    self.servesNumberLabel.font = [Theme cookServesPrepEditTitleFont];
    self.servesNumberLabel.textColor = [Theme cookServesNumberColor];
    self.servesNumberLabel.text = @"10";
    [mainView addSubview:self.servesNumberLabel];

    self.prepTimePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(floorf(0.5*(containerView.frame.size.width-2*kPickerWidth - kPaddingPickers)),
                                                                            floorf(0.5*(containerView.frame.size.height - kPickerHeight)),
                                                                            kPickerWidth,
                                                                            kPickerHeight)];
    self.prepTimePickerView.showsSelectionIndicator = YES;
	self.prepTimePickerView.delegate = self;
	self.prepTimePickerView.dataSource = self;
    [containerView addSubview:self.prepTimePickerView];
    
    self.prepLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.prepLabel.backgroundColor = [UIColor clearColor];
    self.prepLabel.textAlignment = NSTextAlignmentCenter;

    self.prepLabel.textColor = [Theme cookServesPrepEditTitleColor];
    self.prepLabel.font = [Theme cookServesPrepEditTitleFont];
    self.prepLabel.text = @"PREP";
    [self.prepLabel sizeToFit];
    self.prepLabel.frame = CGRectMake(self.prepTimePickerView.frame.origin.x,
                                      self.prepTimePickerView.frame.origin.y-self.prepLabel.frame.size.height,
                                      kPickerWidth,
                                      self.prepLabel.frame.size.height);

    [containerView addSubview:self.prepLabel];

    self.cookingTimePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(self.prepTimePickerView.frame.origin.x+kPickerWidth + kPaddingPickers,
                                                                               self.prepTimePickerView.frame.origin.y,
                                                                               kPickerWidth,
                                                                               kPickerHeight)];
    self.cookingTimePickerView.showsSelectionIndicator = YES;
	self.cookingTimePickerView.delegate = self;
	self.cookingTimePickerView.dataSource = self;
    [containerView addSubview:self.cookingTimePickerView];
    
    self.cookLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.cookingTimePickerView.frame.origin.x,
                                                              self.prepLabel.frame.origin.y,
                                                              kPickerWidth,
                                                              30.0f)];
    self.cookLabel.backgroundColor = [UIColor clearColor];
    self.cookLabel.textAlignment = NSTextAlignmentCenter;
    self.cookLabel.textColor = [Theme cookServesPrepEditTitleColor];
    self.cookLabel.font = [Theme cookServesPrepEditTitleFont];
    self.cookLabel.text = @"COOK";
    [self.cookLabel sizeToFit];
    
    self.cookLabel.center = self.cookLabel.center;
    self.cookLabel.frame = CGRectMake(self.cookLabel.frame.origin.x,
                                      self.cookLabel.frame.origin.y,
                                      kPickerWidth,
                                      self.cookLabel.frame.size.height);
    [containerView addSubview:self.cookLabel];
    
    [self addServesSlider:mainView];
    
    [mainView addSubview:containerView];
}


- (void) addServesSlider:(UIView*)mainView
{
        self.servesSlider = [[UISlider alloc] initWithFrame:CGRectMake(floorf(0.5*(mainView.frame.size.width - kSliderWidth)),
                                                                       100.0f,
                                                                       kSliderWidth, 57.0f)];
        self.servesSlider.minimumValueImage = [UIImage imageNamed:@"cook_edit_serveslider_icon_one"];
        self.servesSlider.maximumValueImage = [UIImage imageNamed:@"cook_edit_serveslider_icon_many"];
        [self.servesSlider addTarget:self action:@selector(servesSlid:) forControlEvents:UIControlEventValueChanged];
        self.servesSlider.backgroundColor = [UIColor clearColor];

        UIImage *strechTrack = [[UIImage imageNamed:@"cook_edit_serveslider_bg"]
									resizableImageWithCapInsets:UIEdgeInsetsMake(28.0f, 25.0f, 28.0f, 25.0f)];
        [self.servesSlider setThumbImage: [UIImage imageNamed:@"cook_edit_serveslider_button"] forState:UIControlStateNormal];
        [self.servesSlider setMinimumTrackImage:strechTrack forState:UIControlStateNormal];
        [self.servesSlider setMaximumTrackImage:strechTrack forState:UIControlStateNormal];
        self.servesSlider.minimumValue = 0.0;
        self.servesSlider.maximumValue = 10.0;
        self.servesSlider.continuous = YES;
    
        [mainView addSubview:self.servesSlider];

}

- (void)setValues {
    //set numServes
    [self.servesSlider setValue:self.numServes animated:YES];
    self.servesNumberLabel.text = [NSString stringWithFormat:@"%d",self.numServes];
    
    if (self.cookingTimeInMinutes > 0) {
        [self.cookingTimeArray enumerateObjectsUsingBlock:^(NSNumber *arrayValue, NSUInteger idx, BOOL *stop) {
            if (self.cookingTimeInMinutes == [arrayValue integerValue]) {
                stop = YES;
                [self.cookingTimePickerView selectRow:idx inComponent:0 animated:NO];
            }
        }];
    } else {
        //select the first row
        [self.cookingTimePickerView selectRow:0 inComponent:0 animated:NO];
        self.cookingTimeInMinutes = [self.cookingTimeArray objectAtIndex:0];
    }
    
    if (self.prepTimeInMinutes > 0) {
        [self.prepTimeArray enumerateObjectsUsingBlock:^(NSNumber *arrayValue, NSUInteger idx, BOOL *stop) {
            if (self.prepTimeInMinutes == [arrayValue integerValue]) {
                stop = YES;
                [self.prepTimePickerView selectRow:idx inComponent:0 animated:NO];
            }
        }];
    } else {
        //select the first row
        [self.prepTimePickerView selectRow:0 inComponent:0 animated:NO];
        self.prepTimeInMinutes = [self.prepTimeArray objectAtIndex:0];
    }
    
}

-(void)dataForArrays
{
    self.cookingTimeArray = @[@5,@10,@15,@20,@25,@30,@35,@40,@45,@50,@55,@60,@65,@70,@75,@80,@85,@90,@95,@100,@105,@110,@115,@120];
    self.prepTimeArray = @[@5,@10,@15,@20,@25,@30,@35,@40,@45,@50,@55,@60,@65,@70,@75,@80,@85,@90];
}

@end

