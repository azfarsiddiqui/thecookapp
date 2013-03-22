//
//  BookNavigationLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 12/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@protocol BookNavigationDataSource <NSObject>

- (NSUInteger)bookNavigationContentStartSection;
- (NSUInteger)bookNavigationLayoutNumColumns;
- (NSUInteger)bookNavigationLayoutColumnWidthForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol BookNavigationLayoutDelegate <NSObject>

- (void)prepareLayoutDidFinish;

@end

@interface BookNavigationLayout : UICollectionViewLayout

- (id)initWithDataSource:(id<BookNavigationDataSource>)dataSource delegate:(id<BookNavigationLayoutDelegate>)delegate;
- (CGFloat)pageOffsetForSection:(NSInteger)section;
- (NSArray *)pageOffsetsForContentsSections;

+ (CGSize)unitSize;
+ (UIEdgeInsets)contentPageInsets;
+ (UIEdgeInsets)otherPageInsets;
+ (CGFloat)columnSeparatorWidth;;

@end
