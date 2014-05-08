//
//  ServesTabView.m
//  Cook
//
//  Created by Gerald on 23/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesTabView.h"
#import "ImageHelper.h"
#import "Theme.h"

@interface ServesTabView ()

@property (nonatomic, assign) id<ServesTabViewDelegate> delegate;

@end

@implementation ServesTabView

- (id)initWithDelegate:(id<ServesTabViewDelegate>)delegate selectedType:(CKQuantityType)selectedType quantityString:(NSString *)quantity
{
    self = [super initWithOptions:@[@"SERVES", @"MAKES"]
                       buttonFont:[UIFont fontWithName:@"BrandonGrotesque-Regular" size:32]
                      buttonWidth:220];
    if (self) {
        // Initialization code
        self.delegate = delegate;
        self.selectedType = selectedType;
        self.quantity = quantity;
        [self.buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
            [obj setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            NSInteger shadowOffset = 7;
            if (idx == 0) {
                obj.frame = CGRectMake(obj.frame.origin.x,
                                       obj.frame.origin.y,
                                       obj.frame.size.width + shadowOffset,
                                       obj.frame.size.height);
            } else {
                obj.frame = CGRectMake(obj.frame.origin.x - shadowOffset,
                                       obj.frame.origin.y,
                                       obj.frame.size.width + (shadowOffset * 2),
                                       obj.frame.size.height);
            }
        }];
    }
    return self;
}

- (void)alignButton:(UIButton *)button atIndex:(NSInteger)optionIndex {
    if (optionIndex == 0) //Leftmost button compensate rounded edge
    {
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 20.0f, 5.0f, 10.0f)];
    }
    else if (optionIndex == [self.options count] -1) //Rightmost button compensate rounded edge
    {
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 5.0f, 25.0f)];
    }
}

- (void)reset {
    [self updateQuantity:self.quantity];
    [self selectOptionAtIndex:self.selectedType == CKQuantityServes ? 0 : 1];
}

- (void)didSelectOptionAtIndex:(NSInteger)optionIndex {
    if (optionIndex == 0) {
        self.selectedType = CKQuantityServes;
        [self.delegate didSelectQuantityType:CKQuantityServes];
    } else {
        self.selectedType = CKQuantityMakes;
        [self.delegate didSelectQuantityType:CKQuantityMakes];
    }
    [self updateQuantity:self.quantity];
}

- (void)selectOptionAtIndex:(NSInteger)optionIndex {
    
    // Change state of the option.
    for (NSInteger buttonIndex = 0; buttonIndex < [self.buttons count]; buttonIndex++) {
        UIButton *button = [self.buttons objectAtIndex:buttonIndex];
        if (buttonIndex == optionIndex) {
            [button setBackgroundImage:[self selectedImageForOptionIndex:buttonIndex] forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:[self deselectedImageForOptionIndex:buttonIndex] forState:UIControlStateNormal];
        }
    }
    
    [self didSelectOptionAtIndex:optionIndex];
}

- (UIImage *)backgroundImage {
    return [ImageHelper stretchableXImageWithName:@"cook_customise_toggle_bg"];
//    [[UIImage imageNamed:@"cook_dash_settings_tab_bg.png"] resizableImageWithCapInsets:(UIEdgeInsets){
//        0.0, 17.0, 0.0, 17.0
//    }];
}

- (UIImage *)deselectedImageForOptionIndex:(NSInteger)optionIndex {
    UIImage *image = nil;
    if (optionIndex == 0) {
        image = [[UIImage imageNamed:@"cook_customise_toggle_left_off"] resizableImageWithCapInsets:(UIEdgeInsets){
            0.0, 45.0, 0.0, 15.0
        }];
    } else if (optionIndex == [self.options count] - 1) {
        image = [[UIImage imageNamed:@"cook_customise_toggle_right_off"] resizableImageWithCapInsets:(UIEdgeInsets){
            0.0, 15.0, 0.0, 45.0
        }];
    } else {
        image = [[UIImage imageNamed:@"cook_dash_settings_tab_selected_mid.png"] resizableImageWithCapInsets:(UIEdgeInsets){
            0.0, 17.0, 0.0, 17.0
        }];
    }
    return image;
}

- (UIImage *)selectedImageForOptionIndex:(NSInteger)optionIndex {
    return nil;
}

- (void)updateQuantity:(NSString *)quantity {
    self.quantity = quantity;
    NSDictionary *activeTitleAttributes = @{NSFontAttributeName: [Theme editServesTitleFont],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSDictionary *activeNumAttributes = @{NSFontAttributeName: [Theme editServesFont],
                                          NSForegroundColorAttributeName: [Theme editServesColour]};
    NSDictionary *inactiveTitleAttributes = @{NSFontAttributeName: [Theme editServesFont],
                                              NSForegroundColorAttributeName: [UIColor colorWithRed:0.102 green:0.533 blue:0.961 alpha:1.000]};
    
    // TODO: Redo this so that i have makesTitle, servesTitle with the attributes chosen by the ternary operatoriph
    NSMutableAttributedString *makesTitle = [[NSMutableAttributedString alloc] initWithString:@"MAKES" attributes:self.selectedType == CKQuantityMakes ?activeTitleAttributes : inactiveTitleAttributes];
    NSAttributedString *activeNumber = [[NSAttributedString alloc] initWithString:quantity attributes:activeNumAttributes];
    NSMutableAttributedString *servesTitle = [[NSMutableAttributedString alloc] initWithString:@"SERVES" attributes:self.selectedType == CKQuantityServes ? activeTitleAttributes : inactiveTitleAttributes];
    
    NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" "];
    [self.selectedType == CKQuantityMakes ? makesTitle : servesTitle appendAttributedString:spaceString];
    [self.selectedType == CKQuantityMakes ? makesTitle : servesTitle appendAttributedString:activeNumber];
    
    [self updateTitle:servesTitle forButtonIndex:0];
    [self updateTitle:makesTitle forButtonIndex:1];
}

@end
