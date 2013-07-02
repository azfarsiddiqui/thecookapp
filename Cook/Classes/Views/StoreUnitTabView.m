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
@property (nonatomic, strong) UIImageView *selectedTabImageView;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UILabel *normalLabel;
@property (nonatomic, strong) UILabel *selectedLabel;

@end

@implementation StoreUnitTabView

#define kHeight                         105
#define kTextNormalOffsetFromBottom     63.0
#define kTextSelectedOffsetFromBottom   48.0
#define kIconTextGap                    6.0

- (id)initWithText:(NSString *)text icon:(UIImage *)icon{
    if (self = [super initWithFrame:CGRectZero]) {
        self.text = text;
        self.iconImageView = [[UIImageView alloc] initWithImage:icon];
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
    self.normalLabel.alpha = select ? 0.0 : 1.0;
    self.selectedLabel.alpha = select ? 1.0 : 0.0;
    
    // Translations.
    //self.normalLabel.transform = select ? CGAffineTransformMakeTranslation(0.0, 20.0) : CGAffineTransformIdentity;
    self.selectedLabel.transform = select ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, -20.0);
}

#pragma mark - Private

- (void)initTab {
    
    // Selected tab image to be hidden to start off with.
    self.selectedTabImageView.frame = (CGRect){
        self.bounds.origin.x,
        self.bounds.size.height - self.selectedTabImageView.frame.size.height,
        self.selectedTabImageView.frame.size.width,
        self.selectedTabImageView.frame.size.height
    };
    self.selectedTabImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.selectedTabImageView];
    
    // Normal label.
    UILabel *normalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    normalLabel.backgroundColor = [UIColor clearColor];
    normalLabel.font = [Theme storeTabFont];
    normalLabel.textColor = [Theme storeTabTextColour];
    normalLabel.text = self.text;
    normalLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [normalLabel sizeToFit];
    normalLabel.frame = (CGRect){
        floorf((self.bounds.size.width - normalLabel.frame.size.width) / 2.0),
        self.bounds.size.height - kTextNormalOffsetFromBottom,
        normalLabel.frame.size.width,
        normalLabel.frame.size.height
    };
    [self addSubview:normalLabel];
    self.normalLabel = normalLabel;

    // Selected label to be hidden to start off with.
    UILabel *selectedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    selectedLabel.backgroundColor = [UIColor clearColor];
    selectedLabel.font = [Theme storeTabSelectedFont];
    selectedLabel.textColor = [Theme storeTabSelectedTextColour];
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
    self.selectedLabel = selectedLabel;
    
    // Selected icon that is hidden to start off with.
    self.iconImageView.frame = (CGRect) {
        floorf((self.bounds.size.width - self.iconImageView.frame.size.width) / 2.0),
        self.selectedLabel.frame.origin.y - self.iconImageView.frame.size.height - kIconTextGap,
        self.iconImageView.frame.size.width,
        self.iconImageView.frame.size.height
    };
    [self addSubview:self.iconImageView];
    
    [self select:NO];
}

@end
