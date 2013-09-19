//
//  CardViewHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CardViewAnchor) {
    CardViewAnchorCenter,
    CardViewAnchorTopRight,
    CardViewAnchorMidLeft
};

@interface CardViewHelper : NSObject

+ (CardViewHelper *)sharedInstance;
+ (CGSize)cardViewSize;

// Generic cards.
- (void)showCardViewWithTag:(NSString *)tag icon:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle
                       view:(UIView *)view anchor:(CardViewAnchor)anchor center:(CGPoint)center;
- (void)hideCardViewWithTag:(NSString *)tag;
- (void)clearDismissedStates;

// Connection cards.
- (UIView *)messageCardViewWithText:(NSString *)text subtitle:(NSString *)subtitle;
- (void)hideNoConnectionCardInView:(UIView *)view;
- (void)showNoConnectionCard:(BOOL)show view:(UIView *)view center:(CGPoint)center;
- (void)showCardText:(NSString *)text subtitle:(NSString *)subtitle view:(UIView *)view show:(BOOL)show
              center:(CGPoint)center;
- (void)hideCardInView:(UIView *)view;

@end
