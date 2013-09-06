//
//  ServesAndTimeEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesAndTimeEditViewController.h"
#import "CKDialerControl.h"
#import "CKNotchSliderView.h"
#import "Theme.h"
#import "RecipeDetails.h"
#import "UIColor+Expanded.h"
#import "CKRecipe.h"
#import "DateHelper.h"

@interface ServesAndTimeEditViewController () <CKDialerControlDelegate, CKNotchSliderViewDelegate>

@property (nonatomic, strong) RecipeDetails *recipeDetails;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *servesTitleLabel;
@property (nonatomic, strong) UILabel *servesLabel;
@property (nonatomic, strong) CKNotchSliderView *servesSlider;
@property (nonatomic, strong) UILabel *prepTitleLabel;
@property (nonatomic, strong) UILabel *prepLabel;
@property (nonatomic, strong) CKDialerControl *prepDialer;
@property (nonatomic, strong) UILabel *cookTitleLabel;
@property (nonatomic, strong) UILabel *cookLabel;
@property (nonatomic, strong) CKDialerControl *cookDialer;

@end

@implementation ServesAndTimeEditViewController

#define kSize               CGSizeMake(850.0, 600.0)
#define kContentInsets      UIEdgeInsetsMake(46.0, 60.0, 35.0, 60.0)
#define kServesSliderGap    8.0
#define kServesHRGap        31.0
#define kServesIconGap      25.0
#define kDialerGap          100.0
#define kTitleLabelGap      15.0
#define kTitleDialerGap     5.0
#define kUnitServes         2
#define kUnitMinutes        10

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
        [self.prepDialer selectOptionAtIndex:[self prepIndex] animated:YES];
        [self.cookDialer selectOptionAtIndex:[self cookIndex] animated:YES];
    }
    
    // Disable scrolling on appear.
    self.scrollView.scrollEnabled = !appear;
}

#pragma mark - Lazy getters

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - kSize.width) / 2.0),
                                                                  floorf((self.view.bounds.size.height - kSize.height) / 2.0),
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

- (CKNotchSliderView *)servesSlider {
    if (!_servesSlider) {
        _servesSlider = [[CKNotchSliderView alloc] initWithNumNotches:7 delegate:self];
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

- (CKDialerControl *)prepDialer {
    if (!_prepDialer) {
        _prepDialer = [[CKDialerControl alloc] initWithUnitDegrees:10 delegate:self];
    }
    return _prepDialer;
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

- (CKDialerControl *)cookDialer {
    if (!_cookDialer) {
        _cookDialer = [[CKDialerControl alloc] initWithUnitDegrees:10 delegate:self];
    }
    return _cookDialer;
}

#pragma mark - CKNotchSliderViewDelegate methods

- (void)notchSliderView:(CKNotchSliderView *)sliderView selectedIndex:(NSInteger)notchIndex {
    NSInteger serves = notchIndex * kUnitServes;
    
    // Nil out if num serves was zero.
    self.recipeDetails.numServes = (serves == 0) ? nil : [NSNumber numberWithInteger:serves];
    
    NSMutableString *servesDisplay = [NSMutableString stringWithString:@""];
    if (serves > [CKRecipe maxServes]) {
        [servesDisplay appendFormat:@"%d+", (notchIndex - 1) * kUnitServes];
    } else {
        [servesDisplay appendFormat:@"%d", serves];
    }
    self.servesLabel.text = servesDisplay;
    [self.servesLabel sizeToFit];
}

#pragma mark - CKDialerControlDelegate methods

- (void)dialerControl:(CKDialerControl *)dialerControl selectedIndex:(NSInteger)selectedIndex {
    NSInteger minutes = selectedIndex * kUnitMinutes;
    
    if (dialerControl == self.prepDialer) {
        
        NSMutableString *minutesDisplay = [NSMutableString stringWithString:@""];
        if (minutes > [CKRecipe maxPrepTimeInMinutes]) {
            [minutesDisplay appendFormat:@"%@+", [[DateHelper sharedInstance] formattedDurationDisplayForMinutes:[CKRecipe maxCookTimeInMinutes]]];
        } else {
            [minutesDisplay appendString:[[DateHelper sharedInstance] formattedDurationDisplayForMinutes:minutes]];
        }
        
        // Nil out if num was zero.
        self.recipeDetails.prepTimeInMinutes = (minutes == 0) ? nil : [NSNumber numberWithInteger:minutes];
        self.prepLabel.text = minutesDisplay;
        
        [self.prepLabel sizeToFit];
    } else if (dialerControl == self.cookDialer) {
        
        NSMutableString *minutesDisplay = [NSMutableString string];
        if (minutes > [CKRecipe maxCookTimeInMinutes]) {
            [minutesDisplay appendFormat:@"%@+", [[DateHelper sharedInstance] formattedDurationDisplayForMinutes:[CKRecipe maxCookTimeInMinutes]]];
        } else {
            [minutesDisplay appendString:[[DateHelper sharedInstance] formattedDurationDisplayForMinutes:minutes]];
        }
        
        // Nil out if num was zero.
        self.recipeDetails.cookingTimeInMinutes = (minutes == 0) ? nil : [NSNumber numberWithInteger:minutes];
        self.cookLabel.text = minutesDisplay;
        [self.cookLabel sizeToFit];
    }
}

#pragma mark - Private methods

- (void)initServes {
    CGFloat requiredWidth = self.servesTitleLabel.frame.size.width + kTitleLabelGap + self.servesLabel.frame.size.width;
    CGSize availableSize = [self availableSize];
    self.servesTitleLabel.frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - requiredWidth) / 2.0),
                                             kContentInsets.top,
                                             self.servesTitleLabel.frame.size.width,
                                             self.servesTitleLabel.frame.size.height);
    self.servesLabel.frame = CGRectMake(self.servesTitleLabel.frame.origin.x + self.servesTitleLabel.frame.size.width + kTitleLabelGap,
                                        self.servesTitleLabel.frame.origin.y + floorf((self.servesTitleLabel.frame.size.height - self.servesLabel.frame.size.height) / 2.0) + 2.0,
                                        self.servesLabel.frame.size.width,
                                        self.servesLabel.frame.size.height);
    self.servesSlider.frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - self.servesSlider.frame.size.width) / 2.0),
                                         self.servesTitleLabel.frame.origin.y + self.servesTitleLabel.frame.size.height + kServesSliderGap,
                                         self.servesSlider.frame.size.width,
                                         self.servesSlider.frame.size.height);
    [self.containerView addSubview:self.servesTitleLabel];
    [self.containerView addSubview:self.servesLabel];
    [self.containerView addSubview:self.servesSlider];
    
    // Left/right serving icons.
    UIImageView *smallServesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_details_icons_serves_sm.png"]];
    smallServesImageView.frame = CGRectMake(self.servesSlider.frame.origin.x - kServesIconGap - smallServesImageView.frame.size.width,
                                            self.servesSlider.frame.origin.y + floorf((self.servesSlider.frame.size.height - smallServesImageView.frame.size.height) / 2.0),
                                            smallServesImageView.frame.size.width,
                                            smallServesImageView.frame.size.height);
    UIImageView *largeServesImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_details_icons_serves_lg.png"]];
    largeServesImageView.frame = CGRectMake(self.servesSlider.frame.origin.x + self.servesSlider.frame.size.width + kServesIconGap,
                                            self.servesSlider.frame.origin.y + floorf((self.servesSlider.frame.size.height - largeServesImageView.frame.size.height) / 2.0),
                                            largeServesImageView.frame.size.width,
                                            largeServesImageView.frame.size.height);
    [self.containerView addSubview:smallServesImageView];
    [self.containerView addSubview:largeServesImageView];
    
    // HR
    UIView *hrLine = [[UIView alloc] initWithFrame:CGRectMake(kContentInsets.left,
                                                              self.servesSlider.frame.origin.y + self.servesSlider.frame.size.height + kServesHRGap,
                                                              self.containerView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                                                              1.0)];
    hrLine.backgroundColor = [Theme dividerRuleColour];
    [self.containerView addSubview:hrLine];
}

- (void)initDialers {
    CGFloat requiredWidth = self.prepDialer.frame.size.width + kDialerGap + self.cookDialer.frame.size.width;
    CGSize availableSize = [self availableSize];
    self.prepDialer.frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - requiredWidth) / 2.0),
                                       self.containerView.bounds.size.height - kContentInsets.bottom - self.prepDialer.frame.size.height,
                                       self.prepDialer.frame.size.width,
                                       self.prepDialer.frame.size.height);
    
    requiredWidth = self.prepTitleLabel.frame.size.width + kTitleLabelGap + self.prepLabel.frame.size.width;
    self.prepTitleLabel.frame = CGRectMake(self.prepDialer.frame.origin.x + floorf((self.prepDialer.frame.size.width - requiredWidth) / 2.0),
                                           self.prepDialer.frame.origin.y - kTitleDialerGap - self.prepTitleLabel.frame.size.height,
                                           self.prepTitleLabel.frame.size.width,
                                           self.prepTitleLabel.frame.size.height);
    self.prepLabel.frame = CGRectMake(self.prepTitleLabel.frame.origin.x + self.prepTitleLabel.frame.size.width + kTitleLabelGap,
                                      self.prepTitleLabel.frame.origin.y + floorf((self.prepTitleLabel.frame.size.height - self.prepLabel.frame.size.height) / 2.0) + 2.0,
                                      self.prepLabel.frame.size.width,
                                      self.prepLabel.frame.size.height);
    
    self.cookDialer.frame = CGRectMake(self.prepDialer.frame.origin.x + self.prepDialer.frame.size.width + kDialerGap,
                                       self.containerView.bounds.size.height - kContentInsets.bottom - self.cookDialer.frame.size.height,
                                       self.cookDialer.frame.size.width,
                                       self.cookDialer.frame.size.height);
    
    requiredWidth = self.cookTitleLabel.frame.size.width + kTitleLabelGap + self.cookLabel.frame.size.width;
    self.cookTitleLabel.frame = CGRectMake(self.cookDialer.frame.origin.x + floorf((self.cookDialer.frame.size.width - requiredWidth) / 2.0),
                                           self.cookDialer.frame.origin.y - kTitleDialerGap - self.cookTitleLabel.frame.size.height,
                                           self.cookTitleLabel.frame.size.width,
                                           self.cookTitleLabel.frame.size.height);
    self.cookLabel.frame = CGRectMake(self.cookTitleLabel.frame.origin.x + self.cookTitleLabel.frame.size.width + kTitleLabelGap,
                                      self.cookTitleLabel.frame.origin.y + floorf((self.cookTitleLabel.frame.size.height - self.cookLabel.frame.size.height) / 2.0) + 2.0,
                                      self.cookLabel.frame.size.width,
                                      self.cookLabel.frame.size.height);
    
    [self.containerView addSubview:self.prepTitleLabel];
    [self.containerView addSubview:self.prepLabel];
    [self.containerView addSubview:self.prepDialer];
    [self.containerView addSubview:self.cookTitleLabel];
    [self.containerView addSubview:self.cookLabel];
    [self.containerView addSubview:self.cookDialer];
}

- (CGSize)availableSize {
    return CGSizeMake(self.containerView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.containerView.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

- (NSInteger)servesIndex {
    NSInteger numServes = [self.recipeDetails.numServes integerValue];
    if (numServes % kUnitServes != 0) {
        numServes += 1;
    }
    return (numServes / kUnitServes);
}

- (NSInteger)prepIndex {
    return [self dialerIndexForMinutes:[self.recipeDetails.prepTimeInMinutes integerValue]];
}

- (NSInteger)cookIndex {
    return [self dialerIndexForMinutes:[self.recipeDetails.cookingTimeInMinutes integerValue]];
}

- (NSInteger)dialerIndexForMinutes:(NSInteger)minutes {
    NSInteger dialerIndex = 0;
    if (minutes % kUnitMinutes != 0) {
        minutes += (minutes % kUnitMinutes);
    }
    
    if (minutes > 0) {
        dialerIndex = (minutes / kUnitMinutes);
    }
    return dialerIndex;
}

@end
