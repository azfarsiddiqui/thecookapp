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
#define kPickerHeight       100.0f
#define kPickerRowHeight    30.0f
#define kLabelTag 1122334455

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

-(id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate sourceEditingView:(UIView *)sourceEditingView
{
    if (self = [super initWithDelegate:delegate sourceEditingView:sourceEditingView]) {
        self.cookingTimeArray = @[@5,@10,@15,@20,@25,@30,@35,@40,@45,@50,@55,@60,@65,@70,@75,@80,@85,@90,@95,@100,@105,@110,@115,@120];
        self.prepTimeArray = @[@5,@10,@15,@20,@25,@30,@35,@40,@45,@50,@55,@60,@65,@70,@75,@80,@85,@90];
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
    [self addSubviews:mainView];
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

- (void)performSave {
    
    NSDictionary *values = @{@"serves": self.numServes,@"cookTime": self.cookingTimeInMinutes,@"prepTime": self.prepTimeInMinutes};
    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:values];
    [super performSave];
}


#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == self.cookingTimePickerView)	// don't show selection for the custom picker
	{
        self.cookingTimeInMinutes = [self.cookingTimeArray objectAtIndex:row];
	} else {
        self.prepTimeInMinutes = [self.prepTimeArray objectAtIndex:row];
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
    DLog(@"Num serves %f",slider.value);
    self.numServes = [NSNumber numberWithFloat:roundf(slider.value)];
    self.servesNumberLabel.text = [NSString stringWithFormat:@"%0.0f", roundf(slider.value)];
}

#pragma mark - Private Methods

-(void)addSubviews:(UIView*)mainView
{
    
    self.servesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 50.0f, mainView.frame.size.width, 50.0f)];
    self.servesLabel.backgroundColor = [UIColor clearColor];
    self.servesLabel.textAlignment = NSTextAlignmentCenter;
    self.servesLabel.font = [Theme cookServesPrepEditTitleFont];
    self.servesLabel.textColor = [Theme cookServesPrepEditTitleColor];
    self.servesLabel.text = @"SERVES";

    [mainView addSubview:self.servesLabel];

    self.servesNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(460.0f, 50.0f, 100.0f, 50.0f)];
    self.servesNumberLabel.backgroundColor = [UIColor clearColor];
    self.servesNumberLabel.textAlignment = NSTextAlignmentCenter;
    self.servesNumberLabel.font = [Theme cookServesPrepEditTitleFont];
    self.servesNumberLabel.textColor = [Theme cookServesNumberColor];
    self.servesNumberLabel.text = @"10";
    [mainView addSubview:self.servesNumberLabel];

    
    self.prepLabel = [[UILabel alloc]initWithFrame:CGRectMake(150.0f, 250.0f, floorf(0.5*mainView.frame.size.width), 30.0f)];
    self.prepLabel.backgroundColor = [UIColor clearColor];
    self.prepLabel.textAlignment = NSTextAlignmentCenter;

    self.prepLabel.textColor = [Theme cookServesPrepEditTitleColor];
    self.prepLabel.font = [Theme cookServesPrepEditTitleFont];
    self.prepLabel.text = @"PREP";
    [self.prepLabel sizeToFit];
    self.prepLabel.frame = CGRectMake(self.prepLabel.frame.origin.x, self.prepLabel.frame.origin.y, kPickerWidth, self.prepLabel.frame.size.height);

    [mainView addSubview:self.prepLabel];

    self.cookLabel = [[UILabel alloc]initWithFrame:CGRectMake(450.0f, self.prepLabel.frame.origin.y, floorf(0.5*mainView.frame.size.width), 30.0f)];
    self.cookLabel.backgroundColor = [UIColor clearColor];
    self.cookLabel.textAlignment = NSTextAlignmentCenter;
    self.cookLabel.textColor = [Theme cookServesPrepEditTitleColor];
    self.cookLabel.font = [Theme cookServesPrepEditTitleFont];
    self.cookLabel.text = @"COOK";
    [self.cookLabel sizeToFit];
    self.cookLabel.frame = CGRectMake(self.cookLabel.frame.origin.x, self.cookLabel.frame.origin.y, kPickerWidth, self.cookLabel.frame.size.height);
    [mainView addSubview:self.cookLabel];
    
    [self addServesSlider:mainView];
    
    self.cookingTimePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(self.cookLabel.frame.origin.x,
                                                                               self.cookLabel.frame.origin.y + self.cookLabel.frame.size.height,
                                                                               kPickerWidth,
                                                                               kPickerHeight)];
    [mainView addSubview:self.cookingTimePickerView];
	self.cookingTimePickerView.showsSelectionIndicator = YES;
	self.cookingTimePickerView.delegate = self;
	self.cookingTimePickerView.dataSource = self;
	
    self.prepTimePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(self.prepLabel.frame.origin.x,
                                                                            self.prepLabel.frame.origin.y + self.prepLabel.frame.size.height,
                                                                            kPickerWidth,
                                                                            kPickerHeight)];
    self.prepTimePickerView.showsSelectionIndicator = YES;
	self.prepTimePickerView.delegate = self;
	self.prepTimePickerView.dataSource = self;
    [mainView addSubview:self.prepTimePickerView];
}


- (void) addServesSlider:(UIView*)mainView
{
        self.servesSlider = [[UISlider alloc] initWithFrame:CGRectMake(100.0f, self.servesLabel.frame.origin.y + self.servesLabel.frame.size.height, 600.0f, 57.0f)];
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

- (void)addDoneButton {
    UIView *mainView = (UIView *)self.targetEditingView;
    self.doneButton.frame = CGRectMake(mainView.frame.origin.x + mainView.frame.size.width - floorf(self.doneButton.frame.size.width / 2.0),
                                       mainView.frame.origin.y - floorf(self.doneButton.frame.size.height / 3.0),
                                       self.doneButton.frame.size.width,
                                       self.doneButton.frame.size.height);
    [self.view addSubview:self.doneButton];
}

- (void)setValues {
    //set numServes
    if (self.numServes) {
        [self.servesSlider setValue:[self.numServes floatValue] animated:YES];
        self.servesNumberLabel.text = [self.numServes stringValue];
    }
    
    if (self.cookingTimeInMinutes) {
        [self.cookingTimeArray enumerateObjectsUsingBlock:^(NSNumber *arrayValue, NSUInteger idx, BOOL *stop) {
            if ([self.cookingTimeInMinutes isEqualToNumber:arrayValue]) {
                stop = YES;
                [self.cookingTimePickerView selectRow:idx inComponent:0 animated:NO];
            }
        }];
    }
    
    if (self.prepTimeInMinutes) {
        [self.prepTimeArray enumerateObjectsUsingBlock:^(NSNumber *arrayValue, NSUInteger idx, BOOL *stop) {
            if ([self.prepTimeInMinutes isEqualToNumber:arrayValue]) {
                stop = YES;
                [self.prepTimePickerView selectRow:idx inComponent:0 animated:NO];
            }
        }];
    }
    
}
@end

