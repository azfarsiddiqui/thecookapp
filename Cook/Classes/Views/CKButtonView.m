//
//  CKButtonView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 14/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKButtonView.h"

@interface CKButtonView ()

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation CKButtonView

#define kIconOffset     10.0
#define kTextFont       [UIFont boldSystemFontOfSize:12.0];

- (id)initWithTarget:(id)target action:(SEL)selector {
    return [self initWithTarget:target action:selector backgroundImage:[UIImage imageNamed:@"cook_dash_library_profile_btn.png"]];
}

- (id)initWithTarget:(id)target action:(SEL)selector backgroundImage:(UIImage *)backgroundImage {
    if (self = [super initWithFrame:CGRectZero]) {
        self.target = target;
        self.action = selector;
        self.backgroundImage = backgroundImage;
        self.backgroundColor = [UIColor clearColor];
        [self initButtonView];
    }
    return self;
}

- (void)setText:(NSString *)text activity:(BOOL)activity icon:(UIImage *)icon enabled:(BOOL)enabled {
    [self setText:text activity:activity icon:icon enabled:enabled selector:nil];
}

- (void)setText:(NSString *)text activity:(BOOL)activity icon:(UIImage *)icon enabled:(BOOL)enabled selector:(SEL)selector {
    
    // Change selector?
    if (selector) {
        self.action = selector;
    }
    
    // Icon
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
    [self.iconImageView removeFromSuperview];
    
    // Spinner on button.
    if (activity) {
        if (!self.activityView) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityView.frame = CGRectMake(kIconOffset,
                                            ceilf((self.bounds.size.height - activityView.frame.size.height) / 2),
                                            activityView.frame.size.width,
                                            activityView.frame.size.height);
            self.activityView = activityView;
        }
        [self.activityView startAnimating];
        [self addSubview:self.activityView];
        
    } else if (icon) {
        
        if (!self.iconImageView) {
            UIImageView *iconImageView = [[UIImageView alloc] initWithImage:icon];
            iconImageView.frame = CGRectMake(kIconOffset,
                                             ceilf((self.bounds.size.height - iconImageView.frame.size.height) / 2),
                                             iconImageView.frame.size.width,
                                             iconImageView.frame.size.height);
            self.iconImageView = iconImageView;
        }
        
        self.iconImageView.alpha = [self iconAlphaForEnabled:enabled];
        [self addSubview:self.iconImageView];
    }
    
    // Button text.
    CGFloat offset = 0.0;
    if (activity || icon) {
        offset = 30.0;
    }
    [self.textLabel removeFromSuperview];
    UIFont *buttonFont = kTextFont;
    CGSize textSize = [text sizeWithFont:buttonFont constrainedToSize:CGSizeMake(self.bounds.size.width - offset, self.bounds.size.height)
                           lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset + floorf((self.bounds.size.width - offset - textSize.width) / 2.0),
                                                                   floorf((self.bounds.size.height - textSize.height) / 2.0),
                                                                   textSize.width,
                                                                   textSize.height)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.shadowColor = [UIColor blackColor];
    textLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    textLabel.text = text;
    textLabel.font = buttonFont;
    textLabel.alpha = [self textAlphaForEnabled:enabled];
    [self addSubview:textLabel];
    self.textLabel = textLabel;
    
    // Enabled?
    self.button.userInteractionEnabled = enabled;
}

#pragma mark - Private

- (void)initButtonView {
    self.frame = CGRectMake(0.0, 0.0, self.backgroundImage.size.width, self.backgroundImage.size.height);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:self.backgroundImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, self.backgroundImage.size.width, self.backgroundImage.size.height)];
    button.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:button];
    self.button = button;
}

- (void)buttonTapped:(id)sender {
    if ([self.target respondsToSelector:self.action]) {
        [self.target performSelector:self.action];
    }
}

- (CGFloat)textAlphaForEnabled:(BOOL)enabled {
    return enabled ? 1.0 : 0.5;
}

- (CGFloat)iconAlphaForEnabled:(BOOL)enabled {
    return enabled ? 1.0 : 0.5;
}

@end
