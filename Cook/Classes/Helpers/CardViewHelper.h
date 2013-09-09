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

- (void)showCardViewWithTag:(NSString *)tag icon:(UIImage *)icon title:(NSString *)title subtitle:(NSString *)subtitle
                       view:(UIView *)view anchor:(CardViewAnchor)anchor center:(CGPoint)center;
- (void)hideCardViewWithTag:(NSString *)tag;
- (void)clearDismissedStates;

@end
