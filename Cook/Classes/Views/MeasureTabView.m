//
//  ThemeTabView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 31/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "MeasureTabView.h"
#import "ViewHelper.h"
#import "CKUser.h"
#import "EventHelper.h"
#import "CKMeasureConverter.h"

@interface MeasureTabView ()

@property (nonatomic, strong) CKUser *currentUser;

@end

@implementation MeasureTabView

- (id)init {
    if (self = [super initWithOptions:@[@"METRIC", @"US IMPERIAL"]
                           buttonFont:[UIFont fontWithName:@"BrandonGrotesque-Regular" size:12]
                          buttonWidth:100]) {
    }
    return self;
}

#pragma mark - Override superclass methods

- (void)reset {
    self.currentUser = [CKUser currentUser];
    [self selectOptionAtIndex:[self indexForMeasureType:[CKUser currentMeasureTypeForUser:self.currentUser]]];
}

- (void)didSelectOptionAtIndex:(NSInteger)optionIndex {
    CKMeasurementType selectedType = [self measureTypeForIndex:optionIndex];
    if (self.currentUser) {
        [self.currentUser setMeasurementType:selectedType];
    } else {
        [CKUser setGuestMeasure:selectedType];
    }
}

- (UIImage *)backgroundImage {
    return [[UIImage imageNamed:@"cook_dash_settings_tab_bg.png"] resizableImageWithCapInsets:(UIEdgeInsets){
        0.0, 17.0, 0.0, 17.0
    }];
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

- (void)alignButton:(UIButton *)button atIndex:(NSInteger)optionIndex {
    if (optionIndex == 0) //Leftmost button compensate rounded edge
    {
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(1.0f, 1.0f, 0.0f, 0.0f)];
    }
    else if (optionIndex == [self.options count] -1) //Rightmost button compensate rounded edge
    {
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(1.0f, 10.0f, 0.0f, 15.0f)];
    }
}

#pragma mark - Private methods

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
