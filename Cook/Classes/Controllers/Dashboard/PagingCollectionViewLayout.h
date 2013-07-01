//
//  CKPagingCollectionViewLayout.h
//  CKPagingBenchtopDemo
//
//  Created by Jeff Tan-Ang on 8/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PagingCollectionViewLayoutDelegate <NSObject>

- (void)pagingLayoutDidUpdate;

@end

@interface PagingCollectionViewLayout : UICollectionViewLayout

+ (CGSize)bookSize;

- (id)initWithDelegate:(id<PagingCollectionViewLayoutDelegate>)delegate;
- (void)markLayoutDirty;
- (void)enableEditMode:(BOOL)editMode;
- (CGRect)frameForGap;;
- (UICollectionViewLayoutAttributes *)layoutAttributesForMyBook;
- (UICollectionViewLayoutAttributes *)layoutAttributesForFollowBookAtIndex:(NSInteger)bookIndex;

@end
