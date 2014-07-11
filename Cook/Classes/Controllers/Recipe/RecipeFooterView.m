//
//  RecipeFooterView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeFooterView.h"
#import "RecipeDetails.h"
#import "CKLocation.h"
#import "UIColor+Expanded.h"
#import "DateHelper.h"
#import "TTTAttributedLabel.h"
#import "CKBookCover.h"
#import "Theme.h"

@interface RecipeFooterView () <TTTAttributedLabelDelegate>

@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) UIImageView *dividerView;
@property (nonatomic, strong) TTTAttributedLabel *creditsLabel;
@property (nonatomic, strong) UIView *infoContainerView;
@property (nonatomic, strong) RecipeDetails *recipeDetails;

@end

@implementation RecipeFooterView

#define kElementsGap        100.0
#define kIconLabelGap       8.0
#define kDividerCreditsGap  30.0
#define kCreditsInfoGap     40.0
#define kLabelFont          [UIFont fontWithName:@"BrandonGrotesque-Regular" size:14.0]
#define kLabelColour        [UIColor colorWithHexString:@"A0A0A0"]
#define kContentInsets      (UIEdgeInsets){ 0.0, 0.0, 0.0, 0.0 }
#define kWidth              780.0
#define kDividerWidth       600.0
#define kCreditsWidth       650.0

- (id)init {
    if (self = [super initWithFrame:(CGRect){ 0.0, 0.0, kWidth, 0.0}]) {
        self.currentUser = [CKUser currentUser];
    }
    return self;
}

- (void)updateFooterWithRecipeDetails:(RecipeDetails *)recipeDetails {
    self.recipeDetails = recipeDetails;
    self.backgroundColor = [UIColor clearColor];
//    self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    
    [self reset];
    
    CGFloat infoXOffset = 0.0;
    CGFloat yOffset = kContentInsets.top;
    
    CGRect infoFrame = self.infoContainerView.frame;
    
    // Visibility and Creation date.
    UIView *dateView = [self elementViewWithIcon:[self imageForPrivacy:recipeDetails.privacy]
                                            text:[[[DateHelper sharedInstance] relativeDateTimeDisplayForDate:recipeDetails.createdDateTime] uppercaseString]];
    dateView.frame = (CGRect){
        infoXOffset,
        0.0,
        dateView.frame.size.width,
        dateView.frame.size.height
    };
    infoXOffset += dateView.frame.size.width + kElementsGap;
    infoFrame = CGRectUnion(dateView.frame, infoFrame);
    [self.infoContainerView addSubview:dateView];
    
    // Location if any.
    if (recipeDetails.location) {
        UIView *locationView = [self elementViewWithIcon:[UIImage imageNamed:@"cook_book_inner_icon_small_location.png"]
                                                    text:[[recipeDetails.location localeDisplayName] uppercaseString]];
        locationView.frame = (CGRect){
            infoXOffset,
            yOffset,
            locationView.frame.size.width,
            locationView.frame.size.height
        };
        infoXOffset += locationView.frame.size.width + kElementsGap;
        infoFrame = CGRectUnion(locationView.frame, infoFrame);
        [self.infoContainerView addSubview:locationView];
    }
    
    // Size info container.
    self.infoContainerView.frame = infoFrame;

    // Credits text.
    if ([recipeDetails hasCredits]) {
        
        // Center the divider at the top.
        self.dividerView.frame = (CGRect) {
            floorf((self.bounds.size.width - kDividerWidth) / 2.0),
            0.0,
            kDividerWidth,
            self.dividerView.frame.size.height
        };

        // Credits label.
        NSAttributedString *creditsDisplay = [self attributedTextForCredits:recipeDetails.credits];
        self.creditsLabel.text = creditsDisplay;
        
        // Resize and reframe.
        CGSize size = [self.creditsLabel sizeThatFits:(CGSize){ kCreditsWidth, MAXFLOAT }];
        self.creditsLabel.frame = CGRectIntegral((CGRect){
            floorf((self.bounds.size.width - size.width) / 2.0),
            self.dividerView.frame.origin.y + self.dividerView.frame.size.height + kDividerCreditsGap,
            size.width,
            size.height
        });
        
        // Position the info footer and reframe self.
        self.infoContainerView.frame = (CGRect){
            floorf((self.bounds.size.width - self.infoContainerView.frame.size.width) / 2.0),
            self.creditsLabel.frame.origin.y + self.creditsLabel.frame.size.height + kCreditsInfoGap,
            self.infoContainerView.frame.size.width,
            self.infoContainerView.frame.size.height
        };
        self.frame = (CGRect){
            0.0,
            0.0,
            self.frame.size.width,
            kContentInsets.top + self.dividerView.frame.size.height + kDividerCreditsGap + self.creditsLabel.frame.size.height + kCreditsInfoGap + self.infoContainerView.frame.size.height + kContentInsets.bottom
        };
        
        [self addSubview:self.dividerView];
        [self addSubview:self.creditsLabel];
        
    } else {
        
        // Position the info footer and reframe self.
        self.infoContainerView.frame = (CGRect){
            floorf((self.bounds.size.width - self.infoContainerView.frame.size.width) / 2.0),
            kContentInsets.top,
            self.infoContainerView.frame.size.width,
            self.infoContainerView.frame.size.height
        };
        self.frame = (CGRect){
            0.0,
            0.0,
            self.frame.size.width,
            kContentInsets.top + self.infoContainerView.frame.size.height + kContentInsets.bottom
        };
    }

    [self addSubview:self.infoContainerView];
}

#pragma mark - TTTAttributedLabelDelegate method

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Properties

- (TTTAttributedLabel *)creditsLabel {
    if (!_creditsLabel) {
        _creditsLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _creditsLabel.numberOfLines = 0;
        _creditsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _creditsLabel.textAlignment = NSTextAlignmentCenter;
        _creditsLabel.backgroundColor = [UIColor clearColor];
        _creditsLabel.userInteractionEnabled = YES;
        _creditsLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _creditsLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        _creditsLabel.linkAttributes = @{
                                         NSUnderlineStyleAttributeName   : @(NSUnderlineStyleSingle)
                                         };
        _creditsLabel.activeLinkAttributes = @{
                                               NSUnderlineStyleAttributeName     : @(NSUnderlineStyleSingle)
                                               };
        _creditsLabel.delegate = self;
    }
    return _creditsLabel;
}

- (UIImageView *)dividerView {
    if (!_dividerView) {
        _dividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_recipe_divider_tile.png"]];
        _dividerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    }
    return _dividerView;
}

- (UIView *)infoContainerView {
    if (!_infoContainerView) {
        _infoContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _infoContainerView.backgroundColor = [UIColor clearColor];
        _infoContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _infoContainerView;
}

#pragma mark - Private methods

- (UIView *)elementViewWithIcon:(UIImage *)icon text:(NSString *)text {
    
    // Left icon.
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
    CGRect combinedFrame = iconView.frame;
    
    // Right label.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kLabelFont;
    label.textColor = kLabelColour;
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = (CGSize){ 0.0, 1.0 };
    label.text = text;
    [label sizeToFit];
    label.frame = (CGRect){
        iconView.frame.origin.x + iconView.frame.size.width + kIconLabelGap,
        floorf((combinedFrame.size.height - label.frame.size.height) / 2.0),
        label.frame.size.width,
        label.frame.size.height
    };
    
    // Combine their frames.
    combinedFrame = CGRectUnion(combinedFrame, label.frame);
    
    // Container frame.
    UIView *containerView = [[UIView alloc] initWithFrame:combinedFrame];
    containerView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:iconView];
    [containerView addSubview:label];
    return containerView;
}

- (UIImage *)imageForPrivacy:(CKPrivacy)privacy {
    UIImage *privacyIcon = nil;
    switch (privacy) {
        case CKPrivacyPrivate:
            privacyIcon = [UIImage imageNamed:@"cook_book_inner_icon_small_secret.png"];
            break;
        case CKPrivacyFriends:
            privacyIcon = [UIImage imageNamed:@"cook_book_inner_icon_small_friends.png"];
            break;
        case CKPrivacyPublic:
            privacyIcon = [UIImage imageNamed:@"cook_book_inner_icon_small_public.png"];
            break;
        default:
            break;
    }
    return privacyIcon;
}

- (NSString *)textForPrivacy:(CKPrivacy)privacy {
    NSString *info = nil;
    switch (privacy) {
        case CKPrivacyPrivate:
            info = NSLocalizedString(@"SECRET", nil);
            break;
        case CKPrivacyFriends:
            info = NSLocalizedString(@"FRIENDS", nil);
            break;
        case CKPrivacyPublic:
            info = NSLocalizedString(@"PUBLIC", nil);
            break;
        default:
            break;
    }
    return info;
}

- (NSAttributedString *)attributedTextForCredits:(NSString *)text {
    
    // Paragraph attributes.
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = 8.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *paragraphAttributes = @{
                                          NSFontAttributeName : [Theme creditsFont],
                                          NSForegroundColorAttributeName : [Theme creditsColor],
                                          NSParagraphStyleAttributeName : paragraphStyle
                                          };
    return [[NSAttributedString alloc] initWithString:text attributes:paragraphAttributes];
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing colour:(UIColor *)colour
                               textAlignment:(NSTextAlignment)textAlignment shadowColour:(UIColor *)shadowColour
                                shadowOffset:(CGSize)shadowOffset {
    
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = textAlignment;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       font, NSFontAttributeName,
                                       colour, NSForegroundColorAttributeName,
                                       paragraphStyle, NSParagraphStyleAttributeName,
                                       nil];
    if (shadowColour) {
        NSShadow *shadow = [NSShadow new];
        shadow.shadowColor = [UIColor whiteColor];
        shadow.shadowOffset = CGSizeMake(0.0, 1.0);
        [attributes setObject:shadow forKey:NSShadowAttributeName];
    }
    return attributes;
}

- (void)reset {
    [self.infoContainerView removeFromSuperview];
    _infoContainerView = nil;
    [self.dividerView removeFromSuperview];
    _dividerView = nil;
    [self.creditsLabel removeFromSuperview];
    _creditsLabel = nil;
}

@end
