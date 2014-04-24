//
//  CKCollectionViewSpringsHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 24/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKCollectionViewSpringsHelper : NSObject

@property (nonatomic, assign) CGFloat springDamping;
@property (nonatomic, assign) CGFloat springMaxOffset;
@property (nonatomic, assign) CGFloat springResistance;

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)collectionViewLayout;
- (void)reset;
- (BOOL)shouldInvalidateAfterApplyingOffsetsForNewBounds:(CGRect)newBounds collectionView:(UICollectionView *)collectionView;
- (NSArray *)layoutAttributesInFrame:(CGRect)frame;
- (UICollectionViewLayoutAttributes *)layoutAttributesAtIndexPath:(NSIndexPath *)indexPath;
- (void)applyAttachmentBehaviourToAttributes:(UICollectionViewLayoutAttributes *)attributes;

@end
