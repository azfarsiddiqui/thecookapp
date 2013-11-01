//
//  SocialMediaActionHeader.m
//  Cook
//
//  Created by Gerald Kim on 31/10/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "SocialMediaActionHeader.h"
#import "Theme.h"
#import "ImageHelper.h"

@interface SocialMediaActionHeader()

@property (nonatomic, strong) UIButton *socialButton;

@end

@implementation SocialMediaActionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.socialButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.socialButton setBackgroundImage:[ImageHelper stretchableXImageWithName:@"cook_library_btn_facebook"] forState:UIControlStateNormal];
        [self.socialButton setBackgroundImage:[ImageHelper stretchableXImageWithName:@"cook_library_btn_facebook_onpress"] forState:UIControlStateHighlighted];
        self.socialButton.contentMode = UIViewContentModeCenter;
        [self.socialButton addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.socialButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.socialButton];
        
        UILabel *fbSocialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height/2, frame.size.width, 30)];
        fbSocialLabel.textAlignment = NSTextAlignmentCenter;
        fbSocialLabel.font = [Theme suggestFacebookFont];
        fbSocialLabel.textColor = [UIColor whiteColor];
        fbSocialLabel.text = @"GET SUGGESTIONS";
        [fbSocialLabel sizeToFit];
        fbSocialLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.socialButton addSubview:fbSocialLabel];
        
        UIImageView *fbSocialIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_buttonicon_facebook"]];
        fbSocialIcon.translatesAutoresizingMaskIntoConstraints = NO;
        [self.socialButton addSubview:fbSocialIcon];
        
        NSDictionary *metrics = @{@"height":@168.0f};
        NSDictionary *views = @{@"socialButton": self.socialButton, @"fbSocialLabel" : fbSocialLabel, @"fbSocialIcon" : fbSocialIcon};
        [self.socialButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(==32.0)-[fbSocialIcon(70)]-(==22.0)-[fbSocialLabel]-(>=62.0)-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
        //Need to manually set offset from top since button image is off center
        [self.socialButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==62.0)-[fbSocialLabel]-(>=0)-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[socialButton]-(>=20)-|"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=20)-[socialButton(height)]-(>=20)-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.socialButton
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.f constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.socialButton
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1.f constant:0.f]];
        
        
        
        
    }
    return self;
}

- (void)buttonPressed
{
    self.completionBlock();
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
