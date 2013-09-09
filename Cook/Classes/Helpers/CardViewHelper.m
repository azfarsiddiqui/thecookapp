//
//  CardViewHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CardViewHelper.h"
#import "UIColor+Expanded.h"

@interface CardViewHelper ()

@property (nonatomic, strong) NSMutableDictionary *cards;

@end

@implementation CardViewHelper

#define kCardSize           (CGSize){ 300.0, 215.0 }
#define kContentSize        (CGSize){ 250.0, 215.0 }
#define kIconOffset         50.0
#define kIconTitleGap       6.0
#define kTitleSubtitleGap   10.0
#define kTitleDividerGap    3.0
#define kTitleFont          [UIFont fontWithName:@"BrandonGrotesque-Medium" size:18.0]
#define kSubtitleFont       [UIFont fontWithName:@"BrandonGrotesque-Medium" size:13.0]
#define kTitleColour        [UIColor colorWithHexString:@"555555"]
#define kSubtitleColour     [UIColor colorWithHexString:@"555555"]

+ (CardViewHelper *)sharedInstance {
    static dispatch_once_t pred;
    static CardViewHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CardViewHelper alloc] init];
    });
    return sharedInstance;
}

+ (CGSize)cardViewSize {
    return kCardSize;
}

- (id)init {
    if (self = [super init]) {
        self.cards = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)showCardViewWithTag:(NSString *)tag icon:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle
                       view:(UIView *)view anchor:(CardViewAnchor)anchor center:(CGPoint)center {
    
    // Remove any existing one.
    UIView *cardView = [self.cards objectForKey:tag];
    if (cardView) {
        [cardView removeFromSuperview];
        [self.cards removeObjectForKey:tag];
    }
    
    // Create and fade it in.
    cardView = [self cardViewWithIcon:icon title:title subtitle:subtitle anchor:anchor];
    [self.cards setObject:cardView forKey:tag];
    
    // Position it in the given parent view.
    cardView.center = center;
    cardView.alpha = 0.0;
    [view addSubview:cardView];
    
    // Fade it in.
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         cardView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)hideCardViewWithTag:(NSString *)tag {
    UIView *cardView = [self.cards objectForKey:tag];
    
    // No such card or not attached to any view.
    if (!cardView || !cardView.superview) {
        return;
    }
    
    // Fade it out then remove.
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         cardView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [cardView removeFromSuperview];
                         [self.cards removeObjectForKey:tag];
                     }];
}

#pragma mark - Private methods

- (UIView *)cardViewWithIcon:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle
                      anchor:(CardViewAnchor)anchor {
    
    // Background image view..
    UIImageView *cardView = [[UIImageView alloc] initWithFrame:(CGRect){ 0.0, 0.0, kCardSize.width, kCardSize.height }];
    cardView.userInteractionEnabled = YES;
    cardView.autoresizingMask = [self viewAutoresizingForAnchor:anchor];
    cardView.image = [self backgroundImageForAnchor:anchor];
    cardView.backgroundColor = [UIColor clearColor];
    
    // Keep track of content container frame.
    CGRect containerFrame = CGRectZero;
    CGSize contentSize = kContentSize;
    
    // Icon.
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:icon];
    CGRect iconFrame = iconImageView.frame;
    iconFrame.origin = (CGPoint){
        floorf((contentSize.width - iconFrame.size.width) / 2.0),
        0.0
    };
    iconImageView.frame = iconFrame;
    containerFrame = CGRectUnion(containerFrame, iconFrame);
    
    // Title.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = kTitleFont;
    titleLabel.textColor = kTitleColour;
    titleLabel.numberOfLines = 1;
    titleLabel.text = title;
    [titleLabel sizeToFit];
    CGRect titleFrame = titleLabel.frame;
    titleFrame.origin = (CGPoint){
        floorf((contentSize.width - titleFrame.size.width) / 2.0),
        iconFrame.origin.y + iconFrame.size.height + kIconTitleGap
    };
    titleLabel.frame = titleFrame;
    containerFrame = CGRectUnion(containerFrame, titleFrame);
    
    // Divider.
    UIImageView *dividerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_intro_divider.png"]];
    dividerView.frame = (CGRect){
        floorf((contentSize.width - dividerView.frame.size.width) / 2.0),
        titleFrame.origin.y + titleFrame.size.height + kTitleDividerGap,
        dividerView.frame.size.width,
        dividerView.frame.size.height
    };
    containerFrame = CGRectUnion(containerFrame, dividerView.frame);
    
    // Subtitle.
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.font = kSubtitleFont;
    subtitleLabel.textColor = kSubtitleColour;
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.text = subtitle;
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    CGSize size = [subtitleLabel sizeThatFits:(CGSize){ 200.0, cardView.bounds.size.height }];
    subtitleLabel.frame = (CGRect){
        floorf((contentSize.width - size.width) / 2.0),
        titleFrame.origin.y + titleFrame.size.height + kTitleSubtitleGap,
        size.width,
        size.height
    };
    containerFrame = CGRectUnion(containerFrame, subtitleLabel.frame);
    
    // Container view.
    UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){
        floorf((cardView.bounds.size.width - contentSize.width) / 2.0) + 3.0,
        floorf((contentSize.height - containerFrame.size.height) / 2.0),
        contentSize.width,
        containerFrame.size.height
    }];
    containerView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:iconImageView];
    [containerView addSubview:titleLabel];
    [containerView addSubview:dividerView];
    [containerView addSubview:subtitleLabel];
    [cardView addSubview:containerView];
    
    // Register tap to dismiss.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [cardView addGestureRecognizer:tapGesture];
    
    return cardView;
}

- (UIImage *)backgroundImageForAnchor:(CardViewAnchor)anchor {
    UIImage *backgroundImage = nil;
    switch (anchor) {
        case CardViewAnchorCenter:
            backgroundImage = [[UIImage imageNamed:@"cook_intro_popover_middle.png"]
                               resizableImageWithCapInsets:(UIEdgeInsets){ 27.0, 107.0, 27.0, 107.0 }];
            break;
        case CardViewAnchorTopRight:
            backgroundImage = [[UIImage imageNamed:@"cook_intro_popover_topright.png"]
                               resizableImageWithCapInsets:(UIEdgeInsets){ 30.0, 107.0, 24.0, 107.0 }];
            break;
        case CardViewAnchorMidLeft:
            backgroundImage = [[UIImage imageNamed:@"cook_intro_popover_left.png"]
                               resizableImageWithCapInsets:(UIEdgeInsets){ 0.0, 30.0, 0.0, 30.0 }];
            break;
        default:
            break;
    }
    return backgroundImage;
}

- (UIEdgeInsets)contentInsetsForAnchor:(CardViewAnchor)anchor {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    switch (anchor) {
        case CardViewAnchorCenter:
            contentInsets = (UIEdgeInsets) {25.0, 20.0, 26.0, 20.0 };
            break;
        case CardViewAnchorTopRight:
            contentInsets = (UIEdgeInsets) {29.0, 20.0, 23.0, 20.0 };
            break;
        case CardViewAnchorMidLeft:
            contentInsets = (UIEdgeInsets) {20.0, 29.0, 23.0, 23.0 };
            break;
        default:
            break;
    }
    return contentInsets;
}

- (UIViewAutoresizing)viewAutoresizingForAnchor:(CardViewAnchor)anchor {
    UIViewAutoresizing autoresizing = UIViewAutoresizingNone;
    switch (anchor) {
        case CardViewAnchorCenter:
            autoresizing = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            break;
        case CardViewAnchorTopRight:
            autoresizing = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
            break;
        case CardViewAnchorMidLeft:
            autoresizing = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            break;
        default:
            break;
    }
    return autoresizing;
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    UIView *cardView = tapGesture.view;
    NSString *tagToDismiss = nil;
    for (NSString *tagName in [self.cards allKeys]) {
        if (cardView == [self.cards objectForKey:tagName]) {
            tagToDismiss = tagName;
            break;
        }
    }
    
    if (tagToDismiss) {
        [self hideCardViewWithTag:tagToDismiss];
    }
}

@end
