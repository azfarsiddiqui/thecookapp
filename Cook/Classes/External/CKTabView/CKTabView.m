//
//  CKTabView.m
//  Cook
//
//  Created by Gerald on 23/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTabView.h"
#import "ViewHelper.h"
#import "EventHelper.h"

@interface CKTabView ()

@property (nonatomic, strong) UIFont *buttonFont;
@property (nonatomic, assign) CGFloat buttonWidth;

@end

@implementation CKTabView

#define kContentInsets  (UIEdgeInsets){ 0.0, 50.0, 0.0, 50.0 }

- (id)initWithOptions:(NSArray *)options buttonFont:(UIFont *)font buttonWidth:(CGFloat)width {
    if (self = [super initWithFrame:CGRectZero]) {
        self.options = options;
        self.buttonFont = font;
        self.buttonWidth = width;
        [self initTabs];
    }
    return self;
}

- (void)reset {
    
}

- (void)initTabs {
    self.buttons = [NSMutableArray array];
    
    UIImage *backgroundImage = [self backgroundImage];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [self addSubview:backgroundImageView];
    
    BOOL secondPassAdjustment = NO;
    CGSize size = (CGSize){ 0.0, backgroundImage.size.height };
    
    for (NSInteger optionIndex = 0; optionIndex < [self.options count]; optionIndex++) {
        
        NSString *optionName = [self.options objectAtIndex:optionIndex];
        UIImage *selectedImage = [self selectedImageForOptionIndex:optionIndex];;
        
        UIButton *button = [ViewHelper buttonWithImage:nil selectedImage:selectedImage target:self selector:@selector(optionTapped:)];
        button.titleLabel.font = self.buttonFont;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:optionName forState:UIControlStateNormal];
        button.titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        
        [self alignButton:button atIndex:optionIndex];
        
        [button sizeToFit];
        
        // Check if we need second-pass size adjustment
        if (button.frame.size.width > self.buttonWidth - kContentInsets.left - kContentInsets.right) {
            self.buttonWidth = button.frame.size.width + kContentInsets.left + kContentInsets.right;
            secondPassAdjustment = YES;
        }
        
        button.frame = (CGRect){
            size.width,
            self.bounds.origin.y,
            self.buttonWidth,
            size.height
        };
        [self addSubview:button];
        [self.buttons addObject:button];
        
        // Update required size.
        size.width += button.frame.size.width;
    }
    
    // Second-pass adjustment.
    if (secondPassAdjustment) {
        size.width = 0.0;
        
        for (UIButton *button in self.buttons) {
            CGRect buttonFrame = button.frame;
            buttonFrame.origin.x = size.width;
            buttonFrame.size.width = self.buttonWidth;
            button.frame = buttonFrame;
            size.width += buttonFrame.size.width;
        }
        
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

- (void)alignButton:(UIButton *)button atIndex:(NSInteger)optionIndex {
    if (optionIndex == 0) //Leftmost button compensate rounded edge
    {
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)];
    }
    else if (optionIndex == [self.options count] -1) //Rightmost button compensate rounded edge
    {
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 5.0f)];
    }
}

- (void)updateTitle:(NSAttributedString *)title forButtonIndex:(NSInteger)index {
    [[self.buttons objectAtIndex:index] setAttributedTitle:title forState:UIControlStateNormal];
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
    
    [self didSelectOptionAtIndex:optionIndex];
}

- (void)didSelectOptionAtIndex:(NSInteger)optionIndex {
    
}

@end
