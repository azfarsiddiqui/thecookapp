//
//  BookNavigationView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@protocol BookNavigationViewDelegate <NSObject>

- (void)bookNavigationViewCloseTapped;
- (void)bookNavigationViewHomeTapped;
- (void)bookNavigationViewAddTapped;
- (void)bookNavigationViewEditTapped;
- (UIColor *)bookNavigationColour;

@end

@interface BookNavigationView : UICollectionReusableView

@property (nonatomic, weak) id<BookNavigationViewDelegate> delegate;

+ (CGFloat)navigationHeight;
+ (CGFloat)darkNavigationHeight;

- (void)setTitle:(NSString *)title editable:(BOOL)editable book:(CKBook *)book;
- (void)setDark:(BOOL)dark;
- (void)enableAddAndEdit:(BOOL)enable;

@end
