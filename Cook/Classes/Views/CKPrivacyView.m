//
//  CKPrivacyView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 10/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPrivacyView.h"

@interface CKPrivacyView ()

@property (nonatomic, assign) id<CKPrivacyViewDelegate> delegate;
@property (nonatomic, assign) BOOL privateMode;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation CKPrivacyView

#define kIconLabelGap   8.0
#define kFont           [UIFont boldSystemFontOfSize:13]
#define kSize           CGSizeMake(200.0, 40.0)

- (id)initWithPrivateMode:(BOOL)privateMode delegate:(id<CKPrivacyViewDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, kSize.width, kSize.height)]) {
        
        self.privateMode = privateMode;
        self.delegate = delegate;
        UIImage *backgroundImage = [[UIImage imageNamed:@"cook_dash_notitifcations_bg.png"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 19.0, 0.0, 19.0)];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundView.userInteractionEnabled = YES;
        backgroundView.frame = self.bounds;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:backgroundView];
        self.backgroundView = backgroundView;
        
        // Keep track of privacy.
        CGFloat requiredWidth = 0.0;
        
        // Privacy icon.
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[self imageForPrivateMode:privateMode]];
        [backgroundView addSubview:iconView];
        self.iconView = iconView;
        requiredWidth += iconView.frame.size.width;
        
        // Privacy label.
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.font = kFont;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.shadowColor = [UIColor blackColor];
        messageLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        messageLabel.text = [self displayForPrivateMode:privateMode];
        [backgroundView addSubview:messageLabel];
        self.messageLabel = messageLabel;
        requiredWidth += kIconLabelGap + messageLabel.frame.size.width;
        
        // Register tap on self.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tapGesture];
        
        // Reposition
        [self layoutIconLabel];
    }
    return self;
}

#pragma mark - Private methods

- (void)layoutIconLabel {
    [self.messageLabel sizeToFit];
    CGFloat requiredWidth = self.iconView.frame.size.width + kIconLabelGap + self.messageLabel.frame.size.width;
    self.iconView.frame = CGRectMake(floorf((self.bounds.size.width - requiredWidth) / 2.0),
                                     floorf((self.bounds.size.height - self.iconView.frame.size.height) / 2.0),
                                     self.iconView.frame.size.width,
                                     self.iconView.frame.size.height);
    self.messageLabel.frame = CGRectMake(self.iconView.frame.origin.x + self.iconView.frame.size.width + kIconLabelGap,
                                         floorf((self.bounds.size.height - self.messageLabel.frame.size.height) / 2.0),
                                         self.messageLabel.frame.size.width,
                                         self.messageLabel.frame.size.height);
}

- (void)enablePrivateMode:(BOOL)privateMode {
    self.privateMode = privateMode;
    self.iconView.image = [self imageForPrivateMode:privateMode];
    self.messageLabel.text = [self displayForPrivateMode:privateMode];
    [self layoutIconLabel];
    [self.delegate privacyViewSelectedPrivateMode:privateMode];
}

- (UIImage *)imageForPrivateMode:(BOOL)privateMode {
    if (privateMode) {
        return [UIImage imageNamed:@"cook_dash_notitifcations_private.png"];
    } else {
        return [UIImage imageNamed:@"cook_dash_notitifcations_public.png"];
    }
}

- (NSString *)displayForPrivateMode:(BOOL)privateMode {
    if (privateMode) {
        return @"SECRET RECIPE";
    } else {
        return @"VISIBLE TO FRIENDS";
    }
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    [self enablePrivateMode:!self.privateMode];
}

@end
