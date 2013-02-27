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

@interface ServesCookPrepEditingViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
//ui
@property (nonatomic, strong) UILabel *servesLabel;
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
        [self style];
        self.cookingTimeArray = @[@5,@10,@15,@20,@25,@30,@35,@40];
        self.prepTimeArray = @[@5,@10,@15,@20,@25,@30];
        
    }
    return self;
}
- (UIView *)createTargetEditingView {
    UIEdgeInsets mainViewInsets = UIEdgeInsetsMake(75.0, 50.0, 75.0, 50.0);
    
    CGRect frame = CGRectMake(mainViewInsets.left,
                              mainViewInsets.top,
                              self.view.bounds.size.width - mainViewInsets.left - mainViewInsets.right,
                              self.view.bounds.size.height - mainViewInsets.top - mainViewInsets.bottom);
    UIView *mainView = [[UITextView alloc] initWithFrame:frame];
    mainView.backgroundColor = [UIColor blackColor];
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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *title = @"";
	
	// note: custom picker doesn't care about titles, it uses custom views
	if (pickerView == self.cookingTimePickerView)
	{
        title = [[self.cookingTimeArray objectAtIndex:row] stringValue];
	} else {
        title = [[self.prepTimeArray objectAtIndex:row] stringValue];
    }
	
	return title;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 80.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 30.0f;
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
    self.servesLabel.text = [NSString stringWithFormat:@"SERVES %0.0f", roundf(slider.value)];
}

#pragma mark - Private Methods

-(void)addSubviews:(UIView*)mainView
{
    
    self.servesLabel = [[UILabel alloc]initWithFrame:CGRectMake(50.0f, 0.0f, 200.f, 30.0f)];
    self.servesLabel.backgroundColor = [UIColor clearColor];
    self.servesLabel.text = @"SERVES";
    self.servesLabel.textColor = [UIColor whiteColor];


    [mainView addSubview:self.servesLabel];
    
    self.prepLabel = [[UILabel alloc]initWithFrame:CGRectMake(50.0f, 50.0f, 200.f, 30.0f)];
    self.prepLabel.backgroundColor = [UIColor clearColor];
    self.prepLabel.textColor = [UIColor whiteColor];
    self.prepLabel.text = @"PREP";

    [mainView addSubview:self.prepLabel];

    self.cookLabel = [[UILabel alloc]initWithFrame:CGRectMake(50.0f, 100.0f, 200.f, 30.0f)];
    self.cookLabel.backgroundColor = [UIColor clearColor];
    self.cookLabel.text = @"COOK";
    self.cookLabel.textColor = [UIColor whiteColor];
    [mainView addSubview:self.cookLabel];
    
    [self addServesSlider:mainView];
    self.cookingTimePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(50.0f, 300.0f, 400.0f, 50.0f)];
    [mainView addSubview:self.cookingTimePickerView];
	self.cookingTimePickerView.showsSelectionIndicator = YES;
	self.cookingTimePickerView.delegate = self;
	self.cookingTimePickerView.dataSource = self;
	
    self.prepTimePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(500.0f, 300.0f, 400.0f, 50.0f)];
    self.prepTimePickerView.showsSelectionIndicator = YES;
	self.prepTimePickerView.delegate = self;
	self.prepTimePickerView.dataSource = self;
    [mainView addSubview:self.prepTimePickerView];
}


-(void)style
{
//    self.editableTextFont = [Theme textEditableTextFont];
//    self.titleFont = [Theme textViewTitleFont];
    
}

- (void) addServesSlider:(UIView*)mainView
{
        self.servesSlider = [[UISlider alloc] initWithFrame:CGRectMake(100.0f, 200.0f, 600.0f, 100.0f)];
        self.servesSlider.minimumValueImage = [UIImage imageNamed:@"cook_edit_serveslider_icon_one"];
        self.servesSlider.maximumValueImage = [UIImage imageNamed:@"cook_edit_serveslider_icon_many"];

        [self.servesSlider addTarget:self action:@selector(servesSlid:) forControlEvents:UIControlEventValueChanged];

        // in case the parent view draws with a custom color or gradient, use a transparent color
        self.servesSlider.backgroundColor = [UIColor clearColor];

        UIImage *strechTrack = [[UIImage imageNamed:@"cook_edit_serveslider_bg"]
									resizableImageWithCapInsets:UIEdgeInsetsMake(28.0f, 25.0f, 28.0f, 25.0f)];
        [self.servesSlider setThumbImage: [UIImage imageNamed:@"cook_edit_serveslider_button"] forState:UIControlStateNormal];
        [self.servesSlider setMinimumTrackImage:strechTrack forState:UIControlStateNormal];
        [self.servesSlider setMaximumTrackImage:strechTrack forState:UIControlStateNormal];
        self.servesSlider.minimumValue = 0.0;
        self.servesSlider.maximumValue = 10.0;
        self.servesSlider.continuous = YES;
        self.servesSlider.value = 2.0;
    
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
@end

