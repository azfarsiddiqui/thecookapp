//
//  ServesAndTimeEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesAndTimeEditViewController.h"
#import "CKDialerControl.h"
#import "ServesNotchSliderView.h"
#import "TimeSliderView.h"
#import "Theme.h"
#import "RecipeDetails.h"
#import "CKRecipe.h"
#import "DateHelper.h"
#import "CKMeasureConverter.h"
#import "ServesTabView.h"

@interface ServesAndTimeEditViewController () <CKNotchSliderViewDelegate, ServesTabViewDelegate>

@property (nonatomic, strong) RecipeDetails *recipeDetails;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) NSInteger originalNumServes;
@property (nonatomic, strong) ServesNotchSliderView *servesSlider;
@property (nonatomic, strong) TimeSliderView *makesSlider;
@property (nonatomic, strong) UILabel *prepTitleLabel;
@property (nonatomic, strong) UILabel *prepLabel;
@property (nonatomic, strong) TimeSliderView *prepSlider;
@property (nonatomic, strong) UILabel *cookTitleLabel;
@property (nonatomic, strong) UILabel *cookLabel;
@property (nonatomic, strong) TimeSliderView *cookSlider;
@property (nonatomic, strong) ServesTabView *servesTabButton;

@property (nonatomic, strong) UIImageView *smallServesImageView;
@property (nonatomic, strong) UIImageView *largeServesImageView;
@property (nonatomic, strong) UIImageView *smallMakesImageView;
@property (nonatomic, strong) UIImageView *largeMakesImageView;

@property (nonatomic, strong) NSLayoutConstraint *prepWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *cookWidthConstraint;

@end

@implementation ServesAndTimeEditViewController

#define kSize               CGSizeMake(850.0, 650.0)
#define kContentInsets      UIEdgeInsetsMake(68.0, 60.0, 61.0, 60.0)
#define kServesSliderGap    8.0
#define kServesHRGap        31.0
#define kServesIconGap      25.0
#define kDialerGap          100.0
#define kTitleLabelGap      15.0
#define kTitleDialerGap     5.0
#define kUnitServes         2

- (id)initWithEditView:(UIView *)editView recipeDetails:(RecipeDetails *)recipeDetails
              delegate:(id<CKEditViewControllerDelegate>)delegate editingHelper:(CKEditingViewHelper *)editingHelper
                 white:(BOOL)white {
    
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white]) {
        self.recipeDetails = recipeDetails;
        self.originalNumServes = [recipeDetails.numServes integerValue];
    }
    return self;
}

- (UIView *)createTargetEditView {
    [self initServes];
    [self initDialers];
    
    // HR
    UIView *hrLine = [[UIView alloc] initWithFrame:CGRectZero];
    hrLine.backgroundColor = [Theme dividerRuleColour];
    hrLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:hrLine];
    
    // HR
    UIView *hr2Line = [[UIView alloc] initWithFrame:CGRectZero];
    hr2Line.backgroundColor = [Theme dividerRuleColour];
    hr2Line.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:hr2Line];
    
    // Left/right serving icons.
    self.smallServesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_details_icons_serves_sm.png"]];
    self.largeServesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_details_icons_serves_lg.png"]];
    self.smallServesImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.largeServesImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.smallServesImageView];
    [self.containerView addSubview:self.largeServesImageView];
    self.smallMakesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_details_icons_makes_sm.png"]];
    self.largeMakesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_details_icons_makes_lg.png"]];
    self.smallMakesImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.largeMakesImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.smallMakesImageView];
    [self.containerView addSubview:self.largeMakesImageView];
    if (self.recipeDetails.quantityType == CKQuantityMakes) {
        self.smallServesImageView.alpha = 0.0;
        self.largeServesImageView.alpha = 0.0;
        self.servesSlider.alpha = 0.0;
    } else {
        self.smallMakesImageView.alpha = 0.0;
        self.largeMakesImageView.alpha = 0.0;
        self.makesSlider.alpha = 0.0;
    }
    
    [self.containerView addSubview:self.servesTabButton];
    UIView *prepView = [[UIView alloc] initWithFrame:CGRectZero];
    {
        prepView.translatesAutoresizingMaskIntoConstraints = NO;
        [prepView addSubview:self.prepTitleLabel];
        [prepView addSubview:self.prepLabel];
        [self.containerView addSubview:prepView];
        NSDictionary *views = @{@"title": self.prepTitleLabel, @"label": self.prepLabel};
        [prepView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[title]-[label]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    }
    UIView *cookView = [[UIView alloc] initWithFrame:CGRectZero];
    {
        cookView.translatesAutoresizingMaskIntoConstraints = NO;
        [cookView addSubview:self.cookTitleLabel];
        [cookView addSubview:self.cookLabel];
        [self.containerView addSubview:cookView];
        NSDictionary *views = @{@"title": self.cookTitleLabel, @"label": self.cookLabel};
        [cookView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[title]-[label]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    }
    
    //Setup layout
    {
        NSDictionary *metrics = @{@"controlHeight":@50, @"longControlWidth":@694, @"dividerWidth":@800, @"sliderWidth":[NSNumber numberWithFloat:self.servesSlider.frame.size.width]};
        NSDictionary *views = @{@"servesView":self.servesTabButton,
                                @"servesSlider":self.servesSlider, @"makesSlider":self.makesSlider, @"servesLine":hr2Line,
                                @"prepView":prepView,
                                @"prepSlider":self.prepSlider,
                                @"cookView":cookView,
                                @"cookSlider":self.cookSlider,
                                @"smallServesIcon":self.smallServesImageView, @"largeServesIcon":self.largeServesImageView};

        self.servesTabButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.servesSlider.translatesAutoresizingMaskIntoConstraints = NO;
        self.makesSlider.translatesAutoresizingMaskIntoConstraints = NO;
        self.prepTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.prepLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.prepSlider.translatesAutoresizingMaskIntoConstraints = NO;
        self.cookTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.cookLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.cookSlider.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(70)-[servesView(90)]-(20)-[servesSlider(controlHeight)]-(50)-[servesLine(1)]-(40)-[prepView(controlHeight)]-(5)-[prepSlider(controlHeight)]-(>=10)-[cookView(controlHeight)]-(5)-[cookSlider(controlHeight)]-(80)-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[servesView(440)]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[smallServesIcon]-(9)-[servesSlider(sliderWidth)]-(10)-[largeServesIcon]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[servesLine(dividerWidth)]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[prepView]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[prepSlider(longControlWidth)]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[cookView]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[cookSlider(longControlWidth)]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];

        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.servesSlider
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.f constant:0.f]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.prepSlider
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.f constant:0.f]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cookSlider
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.f constant:0.f]];
        // Serves and Makes icons overlay each other
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.smallMakesImageView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.smallServesImageView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1.f constant:0.f]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.smallMakesImageView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.smallServesImageView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.f constant:0.f]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.largeMakesImageView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.largeServesImageView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1.f constant:0.f]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.largeMakesImageView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.largeServesImageView
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.f constant:0.f]];
        // Serves and Makes sliders overlay each other
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.makesSlider
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.servesSlider
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1.f constant:20.f]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.makesSlider
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.servesSlider
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.f constant:-20.f]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.makesSlider
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.servesSlider
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.f constant:3.f]];
        
    }
    
    return self.containerView;
}

- (id)updatedValue {
    return self.recipeDetails;
}

#pragma mark - Lifecycle events

- (void)targetTextEditingViewDidAppear:(BOOL)appear {
    [super targetTextEditingViewDidAppear:appear];
    
    if (appear) {
        if (self.recipeDetails.quantityType == CKQuantityServes) {
            [self.servesSlider selectNotch:[self servesIndexForNumServes:self.originalNumServes] animated:YES];
        } else {
            [self.makesSlider setValue:[self sliderIndexForNumberOfMakes:self.originalNumServes] animated:YES];
            [self makesSliderValueChanged];
        }
        self.prepSlider.value = [self prepIndex];
        [self prepSliderValueChanged];
        self.cookSlider.value = [self cookIndex];
        [self cookSliderValueChanged];
    }
    
    // Disable scrolling on appear.
    self.scrollView.scrollEnabled = !appear;
    [self.targetEditTextBoxView disableSelectOnEditView];
}

#pragma mark - Lazy getters

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - kSize.width) / 2.0),
                                                                  floorf((self.view.bounds.size.height - kSize.height) / 2.0) + 2.0,
                                                                  kSize.width,
                                                                  kSize.height)];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (ServesTabView *)servesTabButton {
    if (!_servesTabButton) {
        _servesTabButton = [[ServesTabView alloc] initWithDelegate:self selectedType:self.recipeDetails.quantityType quantityString:@"0"];
        [_servesTabButton reset];
    }
    return _servesTabButton;
}

- (ServesNotchSliderView *)servesSlider {
    if (!_servesSlider) {
        _servesSlider = [[ServesNotchSliderView alloc] initWithNumNotches:12 delegate:self];
    }
    return _servesSlider;
}

- (TimeSliderView *)makesSlider {
    if (!_makesSlider) {
        _makesSlider = [[TimeSliderView alloc] init];
        _makesSlider.minimumValue = 0.0;
        _makesSlider.maximumValue = 32;
        _makesSlider.minimumTrackTintColor = [UIColor colorWithRed:0.102 green:0.533 blue:0.961 alpha:1.000];
        _makesSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.863 alpha:1.000];
        [_makesSlider setThumbImage:[UIImage imageNamed:@"cook_edit_serves_slider"] forState:UIControlStateNormal];
    }
    return _makesSlider;
}

- (UILabel *)prepTitleLabel {
    if (!_prepTitleLabel) {
        _prepTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _prepTitleLabel.backgroundColor = [UIColor clearColor];
        _prepTitleLabel.font = [Theme editPrepTitleFont];
        _prepTitleLabel.textColor = [Theme editPrepTitleColour];
        _prepTitleLabel.text = @"PREP";
        [_prepTitleLabel sizeToFit];
    }
    return _prepTitleLabel;
}

- (UILabel *)prepLabel {
    if (!_prepLabel) {
        _prepLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _prepLabel.backgroundColor = [UIColor clearColor];
        _prepLabel.font = [Theme editPrepFont];
        _prepLabel.textColor = [Theme editPrepColour];
        _prepLabel.text = @"0m";
        [_prepLabel sizeToFit];
    }
    return _prepLabel;
}

- (UISlider *)prepSlider {
    if (!_prepSlider) {
        _prepSlider = [[TimeSliderView alloc] init];
        _prepSlider.minimumValueImage = [UIImage imageNamed:@"cook_edit_details_icons_time_sm.png"];
        _prepSlider.maximumValueImage = [UIImage imageNamed:@"cook_edit_details_icons_time_lg.png"];
        _prepSlider.minimumValue = 0.0;
        _prepSlider.maximumValue = 38.0;
        _prepSlider.minimumTrackTintColor = [UIColor colorWithRed:0.102 green:0.533 blue:0.961 alpha:1.000];
        _prepSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.863 alpha:1.000];
        [_prepSlider setThumbImage:[UIImage imageNamed:@"cook_edit_serves_slider"] forState:UIControlStateNormal];
    }
    return _prepSlider;
}

- (UILabel *)cookTitleLabel {
    if (!_cookTitleLabel) {
        _cookTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cookTitleLabel.backgroundColor = [UIColor clearColor];
        _cookTitleLabel.font = [Theme editCookTitleFont];
        _cookTitleLabel.textColor = [Theme editCookTitleColour];
        _cookTitleLabel.text = @"COOK";
        [_cookTitleLabel sizeToFit];
    }
    return _cookTitleLabel;
}

- (UILabel *)cookLabel {
    if (!_cookLabel) {
        _cookLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cookLabel.backgroundColor = [UIColor clearColor];
        _cookLabel.font = [Theme editCookFont];
        _cookLabel.textColor = [Theme editCookColour];
        _cookLabel.text = @"0m";
        [_cookLabel sizeToFit];
    }
    return _cookLabel;
}

- (UISlider *)cookSlider {
    if (!_cookSlider) {
        _cookSlider = [[TimeSliderView alloc] init];
        _cookSlider.minimumValueImage = [UIImage imageNamed:@"cook_edit_details_icons_time_sm.png"];
        _cookSlider.maximumValueImage = [UIImage imageNamed:@"cook_edit_details_icons_time_lg.png"];
        _cookSlider.minimumValue = 0.0;
        _cookSlider.maximumValue = 38.0;
        _cookSlider.minimumTrackTintColor = [UIColor colorWithRed:0.102 green:0.533 blue:0.961 alpha:1.000];
        _cookSlider.maximumTrackTintColor = [UIColor colorWithWhite:0.863 alpha:1.000];
        [_cookSlider setThumbImage:[UIImage imageNamed:@"cook_edit_serves_slider"] forState:UIControlStateNormal];
    }
    return _cookSlider;
}

#pragma mark - CKNotchSliderViewDelegate methods

- (void)notchSliderView:(CKNotchSliderView *)sliderView selectedIndex:(NSInteger)notchIndex {
    
    if (sliderView == self.servesSlider) {
        NSInteger serves = [self numServesForIndex:notchIndex];
        
        // Nil out if num serves was zero.
        self.recipeDetails.numServes = [NSNumber numberWithInteger:serves];
        
        NSMutableString *servesDisplay = [NSMutableString stringWithString:@""];
        if (serves > [CKRecipe maxServes]) {
            [servesDisplay appendFormat:@"%i+", [CKRecipe maxServes]];
        } else {
            [servesDisplay appendFormat:@"%i", serves];
        }
        [self.servesTabButton updateQuantity:servesDisplay];
    }
}

#pragma mark - ServesTabViewDelegate methods

- (void)didSelectQuantityType:(CKQuantityType)quantityType {
    self.recipeDetails.quantityType = quantityType;
    if (quantityType == CKQuantityMakes) {
        [self makesSliderValueChanged];
        [UIView animateWithDuration:0.4 animations:^{
            self.smallServesImageView.alpha = 0.0;
            self.largeServesImageView.alpha = 0.0;
            self.servesSlider.alpha = 0.0;
            self.smallMakesImageView.alpha = 1.0;
            self.largeMakesImageView.alpha = 1.0;
            self.makesSlider.alpha = 1.0;
        }];
    } else {
        [self notchSliderView:self.servesSlider selectedIndex:self.servesSlider.currentNotchIndex];
        [UIView animateWithDuration:0.4 animations:^{
            self.smallServesImageView.alpha = 1.0;
            self.largeServesImageView.alpha = 1.0;
            self.servesSlider.alpha = 1.0;
            self.smallMakesImageView.alpha = 0.0;
            self.largeMakesImageView.alpha = 0.0;
            self.makesSlider.alpha = 0.0;
        }];
    }
}

#pragma mark - Private methods

- (void)initServes {
    [self.containerView addSubview:self.servesSlider];
}

- (void)initDialers {
    [self.containerView addSubview:self.prepSlider];
    [self.containerView addSubview:self.cookSlider];
    [self.containerView addSubview:self.makesSlider];
    
    [self.cookSlider addTarget:self action:@selector(cookSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.prepSlider addTarget:self action:@selector(prepSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.makesSlider addTarget:self action:@selector(makesSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (CGSize)availableSize {
    return CGSizeMake(self.containerView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.containerView.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

- (NSInteger)prepIndex {
    return [self sliderIndexForMinutes:[self.recipeDetails.prepTimeInMinutes integerValue]];
}

- (NSInteger)cookIndex {
    return [self sliderIndexForMinutes:[self.recipeDetails.cookingTimeInMinutes integerValue]];
}

- (NSInteger)sliderIndexForMinutes:(NSInteger)minutes {
    NSInteger dialerIndex = 0;
    
    if (minutes > 0) {
        
        if (minutes <= 60) {
            
            // 5-minute increments to 1-hour.
            dialerIndex = (minutes / 5);
            
            
        } else if (minutes <= 240) {
            
            // 10-minute increments from 1-hour to 4-hours.
            dialerIndex = 12 + ((minutes - 60) / 10);
            
        } else {
            // 30-minute increments onwards.
            dialerIndex = 30 + ((minutes - 240) / 30);
        }
        
    }
    return dialerIndex;
}

- (NSInteger)minutesForSliderIndex:(NSInteger)dialerIndex {
    NSInteger minutes = 0;
    
    if (dialerIndex <= 12) {
        
        // 5-minute increments to 1-hour.
        minutes = dialerIndex * 5;
        
    } else if (dialerIndex <= 30) {
        
        // 10-minute increments from 1-hour to 4-hours.
        minutes = 60 + ((dialerIndex - 12) * 10);
        
    } else {
        
        // 30-minute increments from 3-hours onwards.
        minutes = 240 + ((dialerIndex - 30) * 30);
    }
    
    return minutes;
}

- (NSInteger)numServesForIndex:(NSInteger)notchIndex {
    NSInteger serves = notchIndex * kUnitServes;
    switch (notchIndex) {
        case 0:
            serves = 0;
            break;
        case 1:
            serves = 1;
            break;
        case 2:
            serves = 2;
            break;
        case 3:
            serves = 3;
            break;
        case 4:
            serves = 4;
            break;
        case 5:
            serves = 5;
            break;
        case 6:
            serves = 6;
            break;
        case 7:
            serves = 7;
            break;
        case 8:
            serves = 8;
            break;
        case 9:
            serves = 10;
            break;
        case 10:
            serves = 12;
            break;
        case 11:
            serves = 14;
            break;
        default:
            serves = 0;
            break;
    }
    return serves;
}

- (NSInteger)servesIndex {
    return [self servesIndexForNumServes:[self.recipeDetails.numServes integerValue]];
}

- (NSInteger)servesIndexForNumServes:(NSInteger)numServes {
    NSInteger notchIndex = 0;
    if (numServes < 8)
    {
        notchIndex = numServes;
    } else if (numServes >= 8 && numServes < 10) {
        notchIndex = 8;
    } else if (numServes >= 10 && numServes < 12) {
        notchIndex = 9;
    } else if (numServes >= 12 && numServes < [CKRecipe maxServes]) {
        notchIndex = 10;
    } else if (numServes == [CKRecipe maxServes]) {
        notchIndex = 11;
    } else {
        //Set to max index
        notchIndex = self.servesSlider.numNotches - 1;
    }
    return notchIndex;
}

- (NSInteger)makesForSliderIndex:(NSInteger)sliderIndex {
    NSInteger makes = sliderIndex;
    if (makes > 2) {
        makes = (sliderIndex - 1) * 2;
    }
    return makes;
}

- (NSInteger)sliderIndexForNumberOfMakes:(NSInteger)makes {
    NSInteger index = makes;
    if (makes > 2) {
        index = makes/2 + 1;
    }
    return index;
}

#pragma mark - SLider actions
- (void)cookSliderValueChanged {
    NSInteger notchIndex = self.cookSlider.value;
    NSInteger minutes = [self minutesForSliderIndex:notchIndex];
    NSMutableString *minutesDisplay = [NSMutableString string];
    if (minutes >= [RecipeDetails maxPrepCookMinutes]) {
        [minutesDisplay appendString:@"+"];
        [minutesDisplay appendString:[[DateHelper sharedInstance] formattedDurationDisplayForMinutes:minutes isHourOnly:YES]];
    } else {
        [minutesDisplay appendString:[[DateHelper sharedInstance] formattedDurationDisplayForMinutes:minutes isHourOnly:NO]];
    }
    // Nil out if num was zero.
    self.recipeDetails.cookingTimeInMinutes = (minutes == 0) ? nil : [NSNumber numberWithInteger:minutes];
    self.cookLabel.text = minutesDisplay;
    [self.cookLabel sizeToFit];
    [self.cookLabel removeConstraint:self.cookWidthConstraint];
    self.cookWidthConstraint = [NSLayoutConstraint constraintWithItem:self.cookLabel
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:nil
                                                               toItem:nil
                                                            attribute:nil
                                                           multiplier:1.f constant:self.cookLabel.frame.size.width > 80 ? 110.f : 75.f];
    [self.cookLabel addConstraint:self.cookWidthConstraint];
}

- (void)prepSliderValueChanged {
    NSInteger notchIndex = self.prepSlider.value;
    NSInteger minutes = [self minutesForSliderIndex:notchIndex];
    NSMutableString *minutesDisplay = [NSMutableString stringWithString:@""];
    if (minutes >= [RecipeDetails maxPrepCookMinutes]) {
        [minutesDisplay appendString:[[DateHelper sharedInstance] formattedDurationDisplayForMinutes:minutes isHourOnly:YES]];
        [minutesDisplay appendString:@"+"];
    } else {
        [minutesDisplay appendString:[[DateHelper sharedInstance] formattedDurationDisplayForMinutes:minutes isHourOnly:NO]];
    }
    // Nil out if num was zero.
    self.recipeDetails.prepTimeInMinutes = (minutes == 0) ? nil : [NSNumber numberWithInteger:minutes];
    self.prepLabel.text = minutesDisplay;
    [self.prepLabel sizeToFit];
    [self.prepLabel removeConstraint:self.prepWidthConstraint];
    self.prepWidthConstraint = [NSLayoutConstraint constraintWithItem:self.prepLabel
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:nil
                                                               toItem:nil
                                                            attribute:nil
                                                           multiplier:1.f constant:self.prepLabel.frame.size.width > 80 ? 110.f : 75.f];
    [self.prepLabel addConstraint:self.prepWidthConstraint];
}

- (void)makesSliderValueChanged {
    NSInteger notchIndex = self.makesSlider.value;
    NSInteger makes = [self makesForSliderIndex:notchIndex];
    NSMutableString *makesDisplay = [NSMutableString stringWithString:@""];
    [makesDisplay appendString:[@(makes) stringValue]];
    if (makes > [RecipeDetails maxMakes]) {
        makesDisplay = [NSMutableString stringWithString:[@([RecipeDetails maxMakes]) stringValue]];
        [makesDisplay appendString:@"+"];
    }
    // Nil out if num is zero.
    self.recipeDetails.numServes = (makes == 0) ? nil : @(makes);
    [self.servesTabButton updateQuantity:makesDisplay];
}

@end
