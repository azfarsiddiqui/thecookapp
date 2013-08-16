//
//  CKButtonView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 14/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKButtonView.h"
#import "UIColor+Expanded.h"

@interface CKButtonView ()

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation CKButtonView

#define kIconOffset         20.0
#define kTextFont           [UIFont fontWithName:@"BrandonGrotesque-Medium" size:14.0]
#define kIconTextGap        5.0
#define kActivityTextGap    10.0

- (id)initWithTarget:(id)target action:(SEL)selector {  
    return [self initWithTarget:target action:selector backgroundImage:[UIImage imageNamed:@"cook_dash_library_selected_btn.png"]];
}

- (id)initWithTarget:(id)target action:(SEL)selector backgroundImage:(UIImage *)backgroundImage {
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundImage = backgroundImage;
        self.backgroundColor = [UIColor clearColor];
        [self initButtonViewWithTarget:target selector:selector];
    }
    return self;
}

- (void)setText:(NSString *)text activity:(BOOL)activity icon:(UIImage *)icon enabled:(BOOL)enabled {
    [self setText:text activity:activity icon:icon enabled:enabled target:nil selector:nil];
}

- (void)setText:(NSString *)text activity:(BOOL)activity icon:(UIImage *)icon enabled:(BOOL)enabled target:(id)target
       selector:(SEL)selector {
    
    // Button text.
    [self.textLabel removeFromSuperview];
    UIFont *buttonFont = kTextFont;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor colorWithHexString:@"333333"];
    textLabel.text = text;
    textLabel.font = buttonFont;
    textLabel.alpha = [self textAlphaForEnabled:enabled];
    [self addSubview:textLabel];
    [textLabel sizeToFit];
    self.textLabel = textLabel;
    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.y = ceilf((self.bounds.size.height - textFrame.size.height) / 2.0);
    
    // Icon
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
    [self.iconImageView removeFromSuperview];
    
    // Spinner on button.
    if (activity) {
        if (!self.activityView) {
            self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        }
        self.activityView.frame = CGRectMake(floorf((self.bounds.size.width - self.textLabel.frame.size.width - kActivityTextGap - self.activityView.frame.size.width) / 2.0) - 2.0,
                                             ceilf((self.bounds.size.height - self.activityView.frame.size.height) / 2) - 1.0,
                                             self.activityView.frame.size.width,
                                             self.activityView.frame.size.height);
        [self.activityView startAnimating];
        [self addSubview:self.activityView];
        
        textFrame.origin.x = self.activityView.frame.origin.x + self.activityView.frame.size.width + kActivityTextGap;
        
    } else if (icon) {
        
        if (!self.iconImageView) {
            self.iconImageView = [[UIImageView alloc] initWithImage:icon];
        }
        self.iconImageView.frame = CGRectMake(floorf((self.bounds.size.width - self.textLabel.frame.size.width - kIconTextGap - self.activityView.frame.size.width) / 2.0) - 5.0,
                                              ceilf((self.bounds.size.height - self.iconImageView.frame.size.height) / 2),
                                              self.iconImageView.frame.size.width,
                                              self.iconImageView.frame.size.height);
        self.iconImageView.alpha = [self iconAlphaForEnabled:enabled];
        [self addSubview:self.iconImageView];
        
        textFrame.origin.x = self.iconImageView.frame.origin.x + self.iconImageView.frame.size.width + kIconTextGap;
        
    } else {
        
        textFrame.origin.x = floorf((self.bounds.size.width - self.textLabel.frame.size.width) / 2.0);
        
    }
    
    // Update the position of the label.
    self.textLabel.frame = textFrame;
    
    // Update selector if non-nil target
    if (target != nil) {
        [self updateButtonWithTarget:target selector:selector];
    }
    
    // Enabled?
    self.button.userInteractionEnabled = enabled;
}

#pragma mark - Private

- (void)initButtonViewWithTarget:(id)target selector:(SEL)selector {
    self.frame = CGRectMake(0.0, 0.0, self.backgroundImage.size.width, self.backgroundImage.size.height);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:self.backgroundImage forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0, 0.0, self.backgroundImage.size.width, self.backgroundImage.size.height)];
    button.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:button];
    self.button = button;
    [self updateButtonWithTarget:target selector:selector];
}

- (void)updateButtonWithTarget:(id)target selector:(SEL)selector {
    [self.button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (CGFloat)textAlphaForEnabled:(BOOL)enabled {
    return enabled ? 1.0 : 0.5;
}

- (CGFloat)iconAlphaForEnabled:(BOOL)enabled {
    return enabled ? 1.0 : 0.5;
}

@end
