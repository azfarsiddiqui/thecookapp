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

@end

@interface BookNavigationView : UICollectionReusableView

@property (nonatomic, weak) id<BookNavigationViewDelegate> delegate;

+ (CGFloat)navigationHeight;
+ (CGFloat)darkNavigationHeight;

- (void)setTitle:(NSString *)title editable:(BOOL)editable book:(CKBook *)book;
- (void)updateTitle:(NSString *)title;
- (void)enableAddAndEdit:(BOOL)enable;

@end
