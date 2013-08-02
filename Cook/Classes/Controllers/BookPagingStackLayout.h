//
//  BookPagingStackLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 12/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BookPagingStackLayoutTypeSlideOneWay,
    BookPagingStackLayoutTypeSlideOneWayScale,
    BookPagingStackLayoutTypeSlideBothWays
} BookPagingStackLayoutType;

@protocol BookPagingStackLayoutDelegate <NSObject>

- (void)stackPagingLayoutDidFinish;
- (BookPagingStackLayoutType)stackPagingLayoutType;
- (NSInteger)stackCategoryStartSection;

@end

@interface BookPagingStackLayout : UICollectionViewLayout

+ (NSString *)bookPagingNavigationElementKind;
- (id)initWithDelegate:(id<BookPagingStackLayoutDelegate>)delegate;
- (void)setNeedsRelayout:(BOOL)relayout;
- (CGFloat)pageOffsetForIndexPath:(NSIndexPath *)indexPath;

@end
