//
//  BookContentGridLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BookContentGridType) {
    BookContentGridTypeExtraSmall,
    BookContentGridTypeSmall,
    BookContentGridTypeMedium,
    BookContentGridTypeLarge
};

@protocol BookContentGridLayoutDelegate <NSObject>

- (void)bookContentGridLayoutDidFinish;
- (NSInteger)bookContentGridLayoutNumColumns;
- (BookContentGridType)bookContentGridTypeForItemAtIndex:(NSInteger)itemIndex;
- (CGSize)bookContentGridLayoutHeaderSize;

@end

@interface BookContentGridLayout : UICollectionViewLayout

+ (CGSize)sizeForBookContentGridType:(BookContentGridType)gridType;
- (id)initWithDelegate:(id<BookContentGridLayoutDelegate>)delegate;
- (void)setNeedsRelayout:(BOOL)relayout;

@end
