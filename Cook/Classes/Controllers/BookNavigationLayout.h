//
//  BookPagingStackLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 12/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BookNavigationLayoutTypeSlideOneWay,
    BookNavigationLayoutTypeSlideOneWayScale,
    BookNavigationLayoutTypeSlideBothWays
} BookNavigationLayoutType;

@protocol BookNavigationLayoutDelegate <NSObject>

- (void)bookNavigationLayoutDidFinish;
- (BookNavigationLayoutType)bookNavigationLayoutType;
- (NSInteger)bookNavigationLayoutContentStartSection;
- (CGFloat)alphaForBookNavigationView;

@end

@interface BookNavigationLayout : UICollectionViewLayout

+ (NSString *)bookNavigationLayoutElementKind;
- (id)initWithDelegate:(id<BookNavigationLayoutDelegate>)delegate;
- (void)setNeedsRelayout:(BOOL)relayout;
- (CGFloat)pageOffsetForIndexPath:(NSIndexPath *)indexPath;

@end
