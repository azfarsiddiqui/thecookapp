//
//  CardViewHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CardViewHelper.h"
#import "UIColor+Expanded.h"
#import "Theme.h"

@interface CardViewHelper ()

@property (nonatomic, strong) NSMutableDictionary *cards;
@property (nonatomic, strong) NSMutableDictionary *cardsDismissed;

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
#define kCardTag            1911

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
        self.cardsDismissed = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)showCardViewWithTag:(NSString *)tag icon:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle
                       view:(UIView *)view anchor:(CardViewAnchor)anchor center:(CGPoint)center {
    
    // Has this been dismissed in this session.
    if ([[self.cardsDismissed objectForKey:tag] boolValue]) {
        return;
    }
    
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

- (void)clearDismissedStates {
    
    // Forget about manually dismissed cards.
    [self.cardsDismissed removeAllObjects];
}

#pragma mark - Connection messages

- (UIView *)messageCardViewWithText:(NSString *)text subtitle:(NSString *)subtitle {
    UIEdgeInsets contentInsets = (UIEdgeInsets) { 25.0, 30.0, 20.0, 30.0 };
    CGFloat titleSubtitleGap = 0.0;
    
    UIImage *cardImage = [[UIImage imageNamed:@"cook_message_popover.png"]
                          resizableImageWithCapInsets:(UIEdgeInsets){ 13.0, 12.0, 13.0, 12.0 }];
    
    // Title label.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [Theme cardViewTitleFont];
    label.textColor = [Theme cardViewTitleColour];
    label.text = text;
    label.shadowOffset = CGSizeZero;
    [label sizeToFit];
    CGRect labelFrame = label.frame;
    
    // Subtitle label.
    UILabel *subtitleLabel = nil;
    CGRect subtitleFrame = CGRectZero;
    if ([subtitle length] > 0) {
        subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.font = [Theme cardViewSubtitleFont];
        subtitleLabel.textColor = [Theme cardViewSubtitleColour];
        subtitleLabel.text = subtitle;
        subtitleLabel.shadowOffset = CGSizeZero;
        [subtitleLabel sizeToFit];
        subtitleFrame = subtitleLabel.frame;
        subtitleFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + titleSubtitleGap;
    }
    
    // Combined frame.
    CGRect cardFrame = CGRectUnion(labelFrame, subtitleFrame);
    UIImageView *cardImageView = [[UIImageView alloc] initWithImage:cardImage];
    cardImageView.userInteractionEnabled = YES;
    cardFrame.size.width += contentInsets.left + contentInsets.right;
    cardFrame.size.height += contentInsets.top + contentInsets.bottom;
    cardImageView.frame = cardFrame;
    
    // Position labels.
    labelFrame.origin.x = floorf((cardImageView.bounds.size.width - labelFrame.size.width) / 2.0);
    labelFrame.origin.y = contentInsets.top;
    subtitleFrame.origin.x = floorf((cardImageView.bounds.size.width - subtitleFrame.size.width) / 2.0);
    subtitleFrame.origin.y = labelFrame.origin.y + labelFrame.size.height + titleSubtitleGap;
    label.frame = labelFrame;
    [cardImageView addSubview:label];
    if (subtitleLabel) {
        subtitleLabel.frame = subtitleFrame;
        [cardImageView addSubview:subtitleLabel];
    }
    
    // Register tap to dismiss.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(altMessageCardTapped:)];
    [cardImageView addGestureRecognizer:tapGesture];
    
    return cardImageView;
}

- (void)hideNoConnectionCardInView:(UIView *)view {
    [self showNoConnectionCard:NO view:view center:CGPointZero];
}

- (void)showNoConnectionCard:(BOOL)show view:(UIView *)view center:(CGPoint)center {
    [self showCardText:@"CANNOT CONNECT" subtitle:@"CHECK YOUR WI-FI OR CELLULAR DATA" view:view show:show center:center];
}

- (void)showCardText:(NSString *)text subtitle:(NSString *)subtitle view:(UIView *)view show:(BOOL)show
              center:(CGPoint)center {
    
    // Check for existing card.
    UIView *cardView = [view viewWithTag:kCardTag];
    BOOL alreadyVisible = (cardView != nil);
    
    if (show) {
        
        // Remove any existing one straigh away.
        [cardView removeFromSuperview];
        
        // Create a new card with the given text.
        cardView = [self messageCardViewWithText:text subtitle:subtitle];
        cardView.tag = kCardTag;
        cardView.center = center;
        
        // Straight replace.
        if (alreadyVisible) {
            [view addSubview:cardView];
        } else {
            cardView.alpha = 0.0;
            [view addSubview:cardView];
            
            // Fade it in.
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 cardView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        
    } else {
        
        // Fade it out if there was something there.
        if (alreadyVisible) {
            
            // Fade it out then remove.
            [UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 cardView.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 [cardView removeFromSuperview];
                             }];
        }
        
    }
}

- (void)hideCardInView:(UIView *)view {
    [self showCardText:nil subtitle:nil view:view show:NO center:CGPointZero];
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
        [self.cardsDismissed setObject:@YES forKey:tagToDismiss];
        [self hideCardViewWithTag:tagToDismiss];
    }
}

- (void)altMessageCardTapped:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.view.superview) {
        [self hideCardInView:tapGesture.view.superview];
    }
}

@end
