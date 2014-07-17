//
//  StoreUnitTabView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 2/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreUnitTabView.h"
#import "Theme.h"

@interface StoreUnitTabView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *offIconImageView;
@property (nonatomic, strong) UIImageView *selectedTabImageView;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UILabel *tabLabel;

@end

@implementation StoreUnitTabView

#define kHeight                         105
#define kTextNormalOffsetFromBottom     63.0
#define kTextSelectedOffsetFromBottom   48.0
#define kIconTextGap                    6.0

- (id)initWithText:(NSString *)text icon:(UIImage *)icon offIcon:(UIImage *)offIcon {
    if (self = [super initWithFrame:CGRectZero]) {
        self.text = text;
        self.iconImageView = [[UIImageView alloc] initWithImage:icon];
        self.offIconImageView = [[UIImageView alloc] initWithImage:offIcon];
        self.selectedTabImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_tab_selected.png"]];
        self.frame = (CGRect){ 0.0, 0.0, self.selectedTabImageView.frame.size.width, kHeight };
        self.backgroundColor = [UIColor clearColor];
        
        [self initTab];
    }
    return self;
}

- (void)select:(BOOL)select {
    
    // Visibility.
    self.selectedTabImageView.alpha = select ? 1.0 : 0.0;
    self.iconImageView.alpha = select ? 1.0 : 0.0;
    self.offIconImageView.alpha = select ? 0.0 : 1.0;
    
    // Text label.
    self.tabLabel.textColor = select ? [Theme storeTabSelectedTextColour] : [Theme storeTabTextColour];
}

#pragma mark - Private

- (void)initTab {
    
    // Tab icon.
    self.selectedTabImageView.frame = (CGRect){
        self.bounds.origin.x,
        self.bounds.size.height - self.selectedTabImageView.frame.size.height,
        self.selectedTabImageView.frame.size.width,
        self.selectedTabImageView.frame.size.height
    };
    self.selectedTabImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.selectedTabImageView];
    
    // Tab label.
    UILabel *selectedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    selectedLabel.backgroundColor = [UIColor clearColor];
    selectedLabel.font = [Theme storeTabFont];
    selectedLabel.textColor = [Theme storeTabTextColour];
    selectedLabel.text = self.text;
    selectedLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [selectedLabel sizeToFit];
    selectedLabel.frame = (CGRect){
        floorf((self.bounds.size.width - selectedLabel.frame.size.width) / 2.0),
        self.bounds.size.height - kTextSelectedOffsetFromBottom,
        selectedLabel.frame.size.width,
        selectedLabel.frame.size.height
    };
    [self addSubview:selectedLabel];
    self.tabLabel = selectedLabel;
    
    // Selected icon.
    self.iconImageView.frame = (CGRect) {
        floorf((self.bounds.size.width - self.iconImageView.frame.size.width) / 2.0),
        self.tabLabel.frame.origin.y - self.iconImageView.frame.size.height - kIconTextGap,
        self.iconImageView.frame.size.width,
        self.iconImageView.frame.size.height
    };
    [self addSubview:self.iconImageView];
    
    // Off icon.
    self.offIconImageView.frame = self.iconImageView.frame;
    [self addSubview:self.offIconImageView];
    
    [self select:NO];
}

@end
