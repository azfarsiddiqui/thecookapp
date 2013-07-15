//
//  BookNavigationView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookNavigationViewDelegate <NSObject>

- (void)bookNavigationViewCloseTapped;
- (void)bookNavigationViewHomeTapped;
- (void)bookNavigationViewAddTapped;
- (UIColor *)bookNavigationColour;

@end

@interface BookNavigationView : UICollectionReusableView

@property (nonatomic, weak) id<BookNavigationViewDelegate> delegate;

+ (CGFloat)navigationHeight;

- (void)setTitle:(NSString *)title;

@end
