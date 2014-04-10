//
//  ThemeTabView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 31/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ThemeTabView.h"
#import "ViewHelper.h"
#import "CKUser.h"
#import "EventHelper.h"
#import "CKMeasureConverter.h"

@interface ThemeTabView ()

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation ThemeTabView

#define kFont               [UIFont fontWithName:@"BrandonGrotesque-Regular" size:12]
#define kLeftEdgeInsets     (UIEdgeInsets){ 10.0, 22.0, 10.0, 16.0 }
#define kMidEdgeInsets      (UIEdgeInsets){ 10.0, 20.0, 10.0, 20.0 }
#define kRightEdgeInsets    (UIEdgeInsets){ 10.0, 18.0, 10.0, 22.0 }

- (id)init {
    if (self = [super initWithFrame:CGRectZero]) {
        [self initTabs];
        [self selectOptionAtIndex:[self indexForMeasureType:[CKUser currentMeasureType]]];
    }
    return self;
}

- (void)reset {
    [self selectOptionAtIndex:[self indexForMeasureType:[CKUser currentMeasureType]]];
}

#pragma mark - Private methods

- (void)initTabs {
    self.options = @[@"METRIC", @"US IMPERIAL"];
    self.buttons = [NSMutableArray array];
    
    UIImage *backgroundImage = [self backgroundImage];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [self addSubview:backgroundImageView];
    
    CGSize size = (CGSize){ 0.0, backgroundImage.size.height };
    
    for (NSInteger optionIndex = 0; optionIndex < [self.options count]; optionIndex++) {
        
        NSString *optionName = [self.options objectAtIndex:optionIndex];
        UIImage *selectedImage = [self selectedImageForOptionIndex:optionIndex];
        UIEdgeInsets insets = [self insetsForOptionIndex:optionIndex];
        
        UIButton *button = [ViewHelper buttonWithImage:nil selectedImage:selectedImage target:self selector:@selector(optionTapped:)];
        button.titleLabel.font = kFont;
        [button setTitle:optionName forState:UIControlStateNormal];
        button.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        if (optionIndex == 0) //Leftmost button compensate rounded edge
        {
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 23.0f, 0.0f, 10.0f)];
        }
        else if (optionIndex == [self.options count] -1) //Rightmost button compensate rounded edge
        {
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 23.0f)];
        }
        [button sizeToFit];
        
        button.frame = (CGRect){
            size.width,
            self.bounds.origin.y,
            insets.left + button.frame.size.width + insets.right,
            size.height
        };
        [self addSubview:button];
        [self.buttons addObject:button];
        
        // Update required size.
        size.width += button.frame.size.width;
    }
    
    // Update background and self frame.
    backgroundImageView.frame = (CGRect){
        self.bounds.origin.x,
        self.bounds.origin.y,
        size.width,
        size.height
    };
    self.frame = backgroundImageView.frame;
}

- (void)loadData {
}

- (UIImage *)backgroundImage {
    return [[UIImage imageNamed:@"cook_dash_settings_tab_bg.png"] resizableImageWithCapInsets:(UIEdgeInsets){
        0.0, 17.0, 0.0, 17.0
    }];
}

- (UIEdgeInsets)insetsForOptionIndex:(NSInteger)optionIndex {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (optionIndex == 0) {
        insets = kLeftEdgeInsets;
    } else if (optionIndex == [self.options count] - 1) {
        insets = kRightEdgeInsets;
    } else {
        insets = kMidEdgeInsets;
    }
    return insets;
}

- (UIImage *)selectedImageForOptionIndex:(NSInteger)optionIndex {
    UIImage *image = nil;
    if (optionIndex == 0) {
        image = [[UIImage imageNamed:@"cook_dash_settings_tab_selected_left.png"] resizableImageWithCapInsets:(UIEdgeInsets){
            0.0, 17.0, 0.0, 17.0
        }];
    } else if (optionIndex == [self.options count] - 1) {
        image = [[UIImage imageNamed:@"cook_dash_settings_tab_selected_right.png"] resizableImageWithCapInsets:(UIEdgeInsets){
            0.0, 17.0, 0.0, 17.0
        }];
    } else {
        image = [[UIImage imageNamed:@"cook_dash_settings_tab_selected_mid.png"] resizableImageWithCapInsets:(UIEdgeInsets){
            0.0, 17.0, 0.0, 17.0
        }];
    }
    return image;
}

- (void)optionTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger buttonIndex = [self.buttons indexOfObject:button];
    [self selectOptionAtIndex:buttonIndex];
}

- (void)selectOptionAtIndex:(NSInteger)optionIndex {
    
    // Change state of the option.
    for (NSInteger buttonIndex = 0; buttonIndex < [self.buttons count]; buttonIndex++) {
        UIButton *button = [self.buttons objectAtIndex:buttonIndex];
        if (buttonIndex == optionIndex) {
            [button setBackgroundImage:[self selectedImageForOptionIndex:buttonIndex] forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
    
    CKUser *currentUser = [CKUser currentUser];
    CKMeasurementType *selectedType = [self measureTypeForIndex:optionIndex];
    if (currentUser) {
        [currentUser setMeasurementType:selectedType];
        [currentUser saveInBackground];
    } else {
        [CKUser setGuestMeasure:selectedType];
    }
}

- (CKMeasurementType)measureTypeForIndex:(NSInteger)measureIndex {
    if (measureIndex == 0) {
        return CKMeasureTypeMetric;
    } else {
        return CKMeasureTypeImperial;
    }
}

- (NSInteger)indexForMeasureType:(CKMeasurementType)measureType {
    if (measureType == CKMeasureTypeMetric) {
        return 0;
    } else {
        return 1;
    }
}

@end
