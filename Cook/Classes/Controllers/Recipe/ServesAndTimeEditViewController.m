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

@interface ServesAndTimeEditViewController () <CKNotchSliderViewDelegate>

@property (nonatomic, strong) RecipeDetails *recipeDetails;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *servesTitleLabel;
@property (nonatomic, strong) UILabel *servesLabel;
@property (nonatomic, strong) ServesNotchSliderView *servesSlider;
@property (nonatomic, strong) UILabel *prepTitleLabel;
@property (nonatomic, strong) UILabel *prepLabel;
@property (nonatomic, strong) TimeSliderView *prepSlider;
@property (nonatomic, strong) UILabel *cookTitleLabel;
@property (nonatomic, strong) UILabel *cookLabel;
@property (nonatomic, strong) UISlider *cookSlider;

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
    UIImageView *smallServesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_details_icons_serves_sm.png"]];
    UIImageView *largeServesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_details_icons_serves_lg.png"]];
    smallServesImageView.translatesAutoresizingMaskIntoConstraints = NO;
    largeServesImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:smallServesImageView];
    [self.containerView addSubview:largeServesImageView];
    
    //Setup layout
    {
        NSDictionary *metrics = @{@"controlHeight":@50, @"longControlWidth":@700, @"dividerWidth":@800, @"sliderWidth":[NSNumber numberWithFloat:self.servesSlider.frame.size.width]};
        NSDictionary *views = @{@"servesTitle":self.servesTitleLabel, @"servesLabel":self.servesLabel, @"servesSlider":self.servesSlider, @"servesLine":hr2Line,
                                @"prepTitle":self.prepTitleLabel, @"prepLabel":self.prepLabel,
                                @"prepSlider":self.prepSlider,
                                @"cookTitle":self.cookTitleLabel, @"cookLabel":self.cookLabel,
                                @"cookSlider":self.cookSlider,
                                @"smallServesIcon":smallServesImageView, @"largeServesIcon":largeServesImageView};

        self.servesTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.servesLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.servesSlider.translatesAutoresizingMaskIntoConstraints = NO;
        self.prepTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.prepLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.prepSlider.translatesAutoresizingMaskIntoConstraints = NO;
        self.cookTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.cookLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.cookSlider.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(30)-[servesTitle]-(20)-[servesSlider(controlHeight)]-(30)-[servesLine(1)]-(40)-[prepTitle]-(5)-[prepSlider(controlHeight)]-(30)-[cookTitle]-(5)-[cookSlider(controlHeight)]-(>=20)-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[servesTitle]-[servesLabel]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[smallServesIcon]-[servesSlider(sliderWidth)]-[largeServesIcon]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[servesLine(dividerWidth)]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[prepTitle]-[prepLabel]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[prepSlider(800)]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[cookTitle]-[cookLabel]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[cookSlider(800)]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];

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
        [self.servesSlider selectNotch:[self servesIndex] animated:YES];
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

- (UILabel *)servesTitleLabel {
    if (!_servesTitleLabel) {
        _servesTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _servesTitleLabel.backgroundColor = [UIColor clearColor];
        _servesTitleLabel.font = [Theme editServesTitleFont];
        _servesTitleLabel.textColor = [Theme editServesTitleColour];
        _servesTitleLabel.text = @"SERVES";
        [_servesTitleLabel sizeToFit];
    }
    return _servesTitleLabel;
}

- (UILabel *)servesLabel {
    if (!_servesLabel) {
        _servesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _servesLabel.backgroundColor = [UIColor clearColor];
        _servesLabel.font = [Theme editServesFont];
        _servesLabel.textColor = [Theme editServesColour];
        _servesLabel.text = @"0";   // Starts at 0
        [_servesLabel sizeToFit];
    }
    return _servesLabel;
}

- (ServesNotchSliderView *)servesSlider {
    if (!_servesSlider) {
        _servesSlider = [[ServesNotchSliderView alloc] initWithNumNotches:10 delegate:self];
    }
    return _servesSlider;
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
        _prepSlider.minimumValueImage = [UIImage imageNamed:@"cook_book_recipe_icon_time_edit.png"];
        _prepSlider.maximumValueImage = [UIImage imageNamed:@"cook_book_recipe_icon_time_edit.png"];
        _prepSlider.minimumValue = 0.0;
        _prepSlider.maximumValue = 38.0;
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
        _cookSlider.minimumValueImage = [UIImage imageNamed:@"cook_book_recipe_icon_time_edit.png"];
        _cookSlider.maximumValueImage = [UIImage imageNamed:@"cook_book_recipe_icon_time_edit.png"];
        _cookSlider.minimumValue = 0.0;
        _cookSlider.maximumValue = 38.0;
    }
    return _cookSlider;
}

#pragma mark - CKNotchSliderViewDelegate methods

- (void)notchSliderView:(CKNotchSliderView *)sliderView selectedIndex:(NSInteger)notchIndex {
    
    if (sliderView == self.servesSlider) {
        NSInteger serves = [self numServesForIndex:notchIndex];
        
        // Nil out if num serves was zero.
        self.recipeDetails.numServes = (serves == 0) ? nil : [NSNumber numberWithInteger:serves];
        
        NSMutableString *servesDisplay = [NSMutableString stringWithString:@""];
        if (serves > [CKRecipe maxServes]) {
            [servesDisplay appendFormat:@"%d+", [CKRecipe maxServes]];
        } else {
            [servesDisplay appendFormat:@"%d", serves];
        }
        self.servesLabel.text = servesDisplay;
        [self.servesLabel sizeToFit];
    }
}

#pragma mark - Private methods

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
            serves = 6;
            break;
        case 6:
            serves = 8;
            break;
        case 7:
            serves = 10;
            break;
        case 8:
            serves = 12;
            break;
        case 9:
            serves = 14;
            break;
        default:
            serves = 0;
            break;
    }
    return serves;
}

- (void)initServes {
    [self.containerView addSubview:self.servesTitleLabel];
    [self.containerView addSubview:self.servesLabel];
    [self.containerView addSubview:self.servesSlider];
}

- (void)initDialers {
    [self.containerView addSubview:self.prepTitleLabel];
    [self.containerView addSubview:self.prepLabel];
    [self.containerView addSubview:self.prepSlider];
    [self.containerView addSubview:self.cookTitleLabel];
    [self.containerView addSubview:self.cookLabel];
    [self.containerView addSubview:self.cookSlider];
    
    [self.cookSlider addTarget:self action:@selector(cookSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.prepSlider addTarget:self action:@selector(prepSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (CGSize)availableSize {
    return CGSizeMake(self.containerView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.containerView.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

- (NSInteger)servesIndex {
    NSInteger numServes = [self.recipeDetails.numServes integerValue];
    NSInteger notchIndex = 0;
    if (numServes < 6)
    {
        notchIndex = numServes;
    } else if (numServes >= 6 && numServes < 8) {
        notchIndex = 5;
    } else if (numServes >= 8 && numServes < 10) {
        notchIndex = 6;
    } else if (numServes >= 10 && numServes < [CKRecipe maxServes]) {
        notchIndex = 7;
    } else if (numServes == [CKRecipe maxServes]) {
        notchIndex = 8;
    } else {
        //Set to max index
        notchIndex = self.servesSlider.numNotches - 1;
    }
    return notchIndex;
}

- (NSInteger)prepIndex {
    return [self dialerIndexForMinutes:[self.recipeDetails.prepTimeInMinutes integerValue]];
}

- (NSInteger)cookIndex {
    return [self dialerIndexForMinutes:[self.recipeDetails.cookingTimeInMinutes integerValue]];
}

- (NSInteger)dialerIndexForMinutes:(NSInteger)minutes {
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

- (NSInteger)minutesForDialerIndex:(NSInteger)dialerIndex {
    DLog(@"Dialer Index: %d", dialerIndex);
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

- (NSInteger)maxIndexForDialer:(CKDialerControl *)dialer {
    return (360 / dialer.unitDegrees - 2);
}

#pragma mark - SLider actions
- (void)cookSliderValueChanged {
    NSInteger notchIndex = self.cookSlider.value;
    NSInteger minutes = [self minutesForDialerIndex:notchIndex];
    NSMutableString *minutesDisplay = [NSMutableString string];
    [minutesDisplay appendString:[[DateHelper sharedInstance] formattedDurationDisplayForMinutes:minutes]];
    if (minutes >= [RecipeDetails maxPrepCookMinutes]) {
        [minutesDisplay appendString:@"+"];
    }
    // Nil out if num was zero.
    self.recipeDetails.cookingTimeInMinutes = (minutes == 0) ? nil : [NSNumber numberWithInteger:minutes];
    self.cookLabel.text = minutesDisplay;
    [self.cookLabel sizeToFit];
}

- (void)prepSliderValueChanged {
    NSInteger notchIndex = self.prepSlider.value;
    NSInteger minutes = [self minutesForDialerIndex:notchIndex];
    NSMutableString *minutesDisplay = [NSMutableString stringWithString:@""];
    [minutesDisplay appendString:[[DateHelper sharedInstance] formattedDurationDisplayForMinutes:minutes]];
    if (minutes >= [RecipeDetails maxPrepCookMinutes]) {
        [minutesDisplay appendString:@"+"];
    }
    // Nil out if num was zero.
    self.recipeDetails.prepTimeInMinutes = (minutes == 0) ? nil : [NSNumber numberWithInteger:minutes];
    self.prepLabel.text = minutesDisplay;
    [self.prepLabel sizeToFit];
}

@end
