//
//  MeasurePickerViewController.m
//  Cook
//
//  Created by Gerald on 24/03/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "MeasurePickerViewController.h"
#import "ViewHelper.h"
#import "ModalOverlayHelper.h"
#import "CKUser.h"
#import "CKMeasureConverter.h"

@interface MeasurePickerViewController ()

@property (nonatomic, strong) UIButton *imperialButton;
@property (nonatomic, strong) UIButton *metricButton;
@property (nonatomic, strong) UIButton *auMetricButton;
@property (nonatomic, strong) UIButton *ukMetricButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UILabel *imperialLabel;
@property (nonatomic, strong) UILabel *metricLabel;
@property (nonatomic, strong) UILabel *auMetricLabel;
@property (nonatomic, strong) UILabel *ukMetricLabel;

@end

@implementation MeasurePickerViewController

#define kContentInsets      (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.closeButton];
    
    UIView *middleContentView = [[UIView alloc] init];
    middleContentView.translatesAutoresizingMaskIntoConstraints = NO;
    middleContentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:middleContentView];
    
    // Setting up constraints to center share content horizontally and vertically
    {
        NSDictionary *metrics = @{@"height":@180.0, @"width":@520.0};
        NSDictionary *views = NSDictionaryOfVariableBindings(middleContentView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[middleContentView]-(>=20)-|"
                                                                          options:NSLayoutFormatAlignAllCenterX
                                                                          metrics:metrics
                                                                            views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=20)-[middleContentView(height)]-(>=20)-|"
                                                                          options:NSLayoutFormatAlignAllCenterY
                                                                          metrics:metrics
                                                                            views:views]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:middleContentView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.f constant:0.f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:middleContentView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.f constant:0.f]];
    }
    
    //Styling and placing buttons
    self.imperialButton = [[UIButton alloc] init];
    [self.imperialButton setBackgroundImage:[UIImage imageNamed:@"cook_book_measurement_icon_usimperial"] forState:UIControlStateNormal];
    [self.imperialButton setBackgroundImage:[UIImage imageNamed:@"cook_book_measurement_icon_usimperial_onpress"] forState:UIControlStateSelected];
    self.imperialButton.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.imperialButton];
    self.metricButton = [[UIButton alloc] init];
    [self.metricButton setBackgroundImage:[UIImage imageNamed:@"cook_book_measurement_icon_metric"] forState:UIControlStateNormal];
    [self.metricButton setBackgroundImage:[UIImage imageNamed:@"cook_book_measurement_icon_metric_onpress"] forState:UIControlStateSelected];
    self.metricButton.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.metricButton];
    self.auMetricButton = [[UIButton alloc] init];
    [self.auMetricButton setBackgroundImage:[UIImage imageNamed:@"cook_book_measurement_icon_aumetric"] forState:UIControlStateNormal];
    [self.auMetricButton setBackgroundImage:[UIImage imageNamed:@"cook_book_measurement_icon_aumetric_onpress"] forState:UIControlStateSelected];
    self.auMetricButton.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.auMetricButton];
    self.ukMetricButton = [[UIButton alloc] init];
    [self.ukMetricButton setBackgroundImage:[UIImage imageNamed:@"cook_book_measurement_icon_ukmetric"] forState:UIControlStateNormal];
    [self.ukMetricButton setBackgroundImage:[UIImage imageNamed:@"cook_book_measurement_icon_ukmetric_onpress"] forState:UIControlStateSelected];
    self.ukMetricButton.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.ukMetricButton];
    
    //Styling and placing labels
    self.imperialLabel = [UILabel new];
    self.imperialLabel.text = @"IMPERIAL";
    self.imperialLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Light" size:20.0];
    self.imperialLabel.textColor = [UIColor whiteColor];
    self.imperialLabel.textAlignment = NSTextAlignmentCenter;
    self.imperialLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.imperialLabel];
    self.metricLabel = [UILabel new];
    self.metricLabel.text = @"METRIC";
    self.metricLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Light" size:20.0];
    self.metricLabel.textColor = [UIColor whiteColor];
    self.metricLabel.textAlignment = NSTextAlignmentCenter;
    self.metricLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.metricLabel];
    self.auMetricLabel = [UILabel new];
    self.auMetricLabel.text = @"AU METRIC";
    self.auMetricLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Light" size:20.0];
    self.auMetricLabel.textColor = [UIColor whiteColor];
    self.auMetricLabel.textAlignment = NSTextAlignmentCenter;
    self.auMetricLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.auMetricLabel];
    self.ukMetricLabel = [UILabel new];
    self.ukMetricLabel.text = @"UK METRIC";
    self.ukMetricLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Light" size:20.0];
    self.ukMetricLabel.textColor = [UIColor whiteColor];
    self.ukMetricLabel.textAlignment = NSTextAlignmentCenter;
    self.ukMetricLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [middleContentView addSubview:self.ukMetricLabel];
    
    UILabel *measureTitleLabel = [[UILabel alloc] init];
    [measureTitleLabel setBackgroundColor:[UIColor clearColor]];
    measureTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //    shareTitleLabel.textAlignment = NSTextAlignmentCenter;
    measureTitleLabel.text = @"MEASUREMENTS";
    measureTitleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Light" size:40.0];
    measureTitleLabel.textColor = [UIColor whiteColor];
    [measureTitleLabel sizeToFit];
    [middleContentView addSubview:measureTitleLabel];
    
    { //Setting up constraints to space buttons in content view
        NSDictionary *metrics = @{@"height":@110.0, @"width":@110.0, @"titleHeight":@38.0, @"spacing":@20.0};
        NSDictionary *views = @{@"imperial" : self.imperialButton,
                                @"imperialLabel" : self.imperialLabel,
                                @"metric" : self.metricButton,
                                @"metricLabel" : self.metricLabel,
                                @"aumetric" : self.auMetricButton,
                                @"aumetricLabel" : self.auMetricLabel,
                                @"ukmetric" : self.ukMetricButton,
                                @"ukmetricLabel" : self.ukMetricLabel,
                                @"title" : measureTitleLabel};
        NSString *buttonConstraints = @"|-(>=0)-[imperial(width)]-spacing-[metric(imperial)]-spacing-[aumetric(imperial)]-spacing-[ukmetric(imperial)]-(>=0)-|";
        NSString *labelConstraints = @"|-(>=0)-[imperialLabel(imperial)]-spacing-[metricLabel(imperial)]-spacing-[aumetricLabel(imperial)]-spacing-[ukmetricLabel(imperial)]-(>=0)-|";
        [middleContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:buttonConstraints options:NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
        [middleContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:labelConstraints options:NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
        [middleContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title(titleHeight)]-(10)-[imperial(height)]-[imperialLabel]" options:0 metrics:metrics views:views]];
        [middleContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[title]-(>=20)-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
        [middleContentView addConstraint:[NSLayoutConstraint constraintWithItem:measureTitleLabel
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:middleContentView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.f constant:0.f]];
    }
   
    UILabel *bottomLabel = [[UILabel alloc] init];
    [bottomLabel setBackgroundColor:[UIColor clearColor]];
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLabel.textAlignment = NSTextAlignmentLeft;
    bottomLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
    bottomLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:bottomLabel];
    bottomLabel.text = @"RECIPES YOU VIEW OR CREATE WILL USE THESE MEASUREMENTS";
    
    { //Setting up constraints to space label and lock at bottom
        NSDictionary *metrics = @{@"width":@39.0, @"height":@39.0};
        NSDictionary *views = NSDictionaryOfVariableBindings(bottomLabel);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[bottomLabel]-(>=20)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=100)-[bottomLabel(height)]-10.0-|" options:0 metrics:metrics views:views]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.f constant:0.f]];
    }
    
    //Set button pressed actions
    [self.imperialButton addTarget:self action:@selector(imperialPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.metricButton addTarget:self action:@selector(metricButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.auMetricButton addTarget:self action:@selector(auMetricButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.ukMetricButton addTarget:self action:@selector(ukMetricButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self resetMeasureButtons];
}

- (void)resetMeasureButtons {
    switch ([CKUser currentUser].measurementType) {
        case CKMeasureTypeMetric:
            [self metricButtonPressed:nil];
            break;
        case CKMeasureTypeAUMetric:
            [self auMetricButtonPressed:nil];
            break;
        case CKMeasureTypeUKMetric:
            [self ukMetricButtonPressed:nil];
            break;
        case CKMeasureTypeImperial:
            [self imperialPressed:nil];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            kContentInsets.top,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

#pragma mark - Action handlers

- (void)closeTapped:(id)sender {
    if (self.imperialButton.selected) {
        [CKUser currentUser].measurementType = CKMeasureTypeImperial;
    } else if (self.metricButton.selected) {
        [CKUser currentUser].measurementType = CKMeasureTypeMetric;
    } else if (self.auMetricButton.selected) {
        [CKUser currentUser].measurementType = CKMeasureTypeAUMetric;
    } else if (self.ukMetricButton.selected) {
        [CKUser currentUser].measurementType = CKMeasureTypeUKMetric;
    }
    if (self.delegate) {
        [self.delegate measurePickerControllerCloseRequested];
    }
}

- (void)imperialPressed:(id)sender {
    [self resetButtonStates];
    self.imperialButton.selected = YES;
    self.imperialLabel.alpha = 0.5;
}

- (void)metricButtonPressed:(id)sender {
    [self resetButtonStates];
    self.metricButton.selected = YES;
    self.metricLabel.alpha = 0.5;
}

- (void)auMetricButtonPressed:(id)sender {
    [self resetButtonStates];
    self.auMetricButton.selected = YES;
    self.auMetricLabel.alpha = 0.5;
}

- (void)ukMetricButtonPressed:(id)sender {
    [self resetButtonStates];
    self.ukMetricButton.selected = YES;
    self.ukMetricLabel.alpha = 0.5;
}

- (void)resetButtonStates {
    self.imperialButton.selected = NO;
    self.metricButton.selected = NO;
    self.auMetricButton.selected = NO;
    self.ukMetricButton.selected = NO;
    
    self.imperialLabel.alpha = 1.0;
    self.metricLabel.alpha = 1.0;
    self.auMetricLabel.alpha = 1.0;
    self.ukMetricLabel.alpha = 1.0;
}

@end
