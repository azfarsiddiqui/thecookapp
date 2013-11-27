//
//  WelcomeCollectionViewLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 28/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "WelcomeCollectionViewLayout.h"

@interface WelcomeCollectionViewLayout ()

@property (nonatomic, assign) id<WelcomeCollectionViewLayoutDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;
@property (nonatomic, assign) BOOL layoutGenerated;

@end

@implementation WelcomeCollectionViewLayout

#define kAdornmentOffset    190.0
#define kPagingUpOffset     30.0
#define kWelcomeSection     0
#define kCreateSection      1
#define kCollectSection     2
#define kLibrarySection     3
#define kSignUpSection      4

- (id)initWithDataSource:(id<WelcomeCollectionViewLayoutDataSource>)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
        self.layoutGenerated = NO;
    }
    return self;
}

- (CGFloat)pageOffsetForPage:(NSInteger)page {
    CGSize size = self.collectionView.bounds.size;
    return size.width * page;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    NSInteger numPages = [self.dataSource numberOfPagesForWelcomeLayout];
    return CGSizeMake(self.collectionView.bounds.size.width * numPages,
                      self.collectionView.bounds.size.height);
}

- (void)prepareLayout {
    
    // Don't rebuild everytime.
    if (self.layoutGenerated) {
        return;
    }
    
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.supplementaryLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    
    [self buildPages];
    
    // Mark as layout generated.
    self.layoutGenerated = YES;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Section cells.
    for (UICollectionViewLayoutAttributes *attributes in self.supplementaryLayoutAttributes) {
        [layoutAttributes addObject:attributes];
    }
    
    // Item cells.
    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
        [layoutAttributes addObject:attributes];
    }
    
    // Apply transform for paging.
    [self applyPagingEffects:layoutAttributes];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind
                                                                        atIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathSupplementaryAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    // Nil if it was a normal cell.
    if (itemIndexPath.section == kWelcomeSection && attributes.representedElementKind == nil) {
        
        CGFloat offset = 100.0;
        CGFloat initialAlpha = 0.7;
        switch (itemIndexPath.item) {
            case 0:
                attributes.transform3D = CATransform3DMakeTranslation(-offset, 0.0, 0.0);
                attributes.alpha = initialAlpha;
                break;
            case 1:
                attributes.transform3D = CATransform3DMakeTranslation(offset, 0.0, 0.0);
                attributes.alpha = initialAlpha;
                break;
            default:
                break;
        }
        
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind
                                                                                        atIndexPath:(NSIndexPath *)elementIndexPath {
    
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryElementOfKind:elementKind
                                                                                           atIndexPath:elementIndexPath];
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]
        && elementIndexPath.section == kWelcomeSection) {
        attributes.alpha = 1.0;
    }
    return attributes;
}

#pragma mark - Private methods

- (void)buildPages {
    NSInteger numPages = [self.dataSource numberOfPagesForWelcomeLayout];
    
    for (NSInteger page = 0; page < numPages; page++) {
        
        // Section
        [self buildSectionsForPage:page];

        // Cells
        [self buildAdornmentsForPage:page];
    }
    
}

- (void)buildSectionsForPage:(NSInteger)page {
    CGSize size = self.collectionView.bounds.size;
    CGFloat pageOffset = [self pageOffsetForPage:page];
    
    NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:page];
    UICollectionViewLayoutAttributes *sectionAttributes = [UICollectionViewLayoutAttributes
                                                           layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                           withIndexPath:sectionIndexPath];
    CGSize pageHeaderSize = [self.dataSource sizeOfPageHeaderForPage:page indexPath:sectionIndexPath];
    CGRect frame = CGRectMake(pageOffset, 0.0, pageHeaderSize.width, pageHeaderSize.height);
    switch (page) {
        case kWelcomeSection:
            frame.origin.x = pageOffset + floorf((size.width - pageHeaderSize.width) / 2.0);
            frame.origin.y = floorf((size.height - pageHeaderSize.height) / 2.0);
            break;
        case kCreateSection:
            frame.origin.x = pageOffset + 95.0;
            frame.origin.y = floorf((size.height - pageHeaderSize.height) / 2.0);
            break;
        case kCollectSection:
            frame.origin.x = pageOffset + floorf((size.width - pageHeaderSize.width) / 2.0);
            frame.origin.y = floorf((size.height - pageHeaderSize.height) / 2.0);
            break;
        case kLibrarySection:
            frame.origin.x = pageOffset + floorf((size.width - pageHeaderSize.width) / 2.0);
            frame.origin.y = floorf((size.height - pageHeaderSize.height) / 2.0);
            break;
        case kSignUpSection:
            frame.origin.x = pageOffset + floorf((size.width - pageHeaderSize.width) / 2.0);
            frame.origin.y = floorf((size.height - pageHeaderSize.height) / 2.0);
            break;
        default:
            break;
    }

    sectionAttributes.frame = frame;
    [self.supplementaryLayoutAttributes addObject:sectionAttributes];
    [self.indexPathSupplementaryAttributes setObject:sectionAttributes forKey:sectionIndexPath];
    
    // Welcome section has additional views, which are the sticky buttons. It crashes if this was implemented as
    // decoration views instead.
    if (page == kWelcomeSection) {
        [self buildWelcomeSectionControls];
    }
}

- (void)buildWelcomeSectionControls {
    
    // Paging view.
    NSIndexPath *pagingIndexPath = [NSIndexPath indexPathForItem:1 inSection:kWelcomeSection];
    CGSize pagingSize = [self.dataSource sizeOfPageHeaderForPage:kWelcomeSection indexPath:pagingIndexPath];
    CGPoint pagingStartPoint = [self startOffsetForPagingView];
    UICollectionViewLayoutAttributes *pagingAttributes = [UICollectionViewLayoutAttributes
                                                          layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                          withIndexPath:pagingIndexPath];
    pagingAttributes.frame = CGRectMake(pagingStartPoint.x, pagingStartPoint.y, pagingSize.width, pagingSize.height);
    [self.supplementaryLayoutAttributes addObject:pagingAttributes];
    [self.indexPathSupplementaryAttributes setObject:pagingAttributes forKey:pagingIndexPath];
    
}

- (void)buildAdornmentsForPage:(NSInteger)page {
    switch (page) {
        case kWelcomeSection:
            [self buildWelcomeAdornments];
            break;
        case kCreateSection:
            [self buildCreateAdornments];
            break;
        case kCollectSection:
            [self buildCollectAdornments];
            break;
        case kLibrarySection:
            [self buildLibraryAdornments];
            break;
        case kSignUpSection:
            [self buildSignUpAdornments];
            break;
        default:
            break;
    }
}

- (void)buildWelcomeAdornments {
    CGFloat pageOffset = [self pageOffsetForPage:kWelcomeSection];
    CGSize size = self.collectionView.bounds.size;
    
    // Left adornment.
    NSIndexPath *leftIndexPath = [NSIndexPath indexPathForItem:0 inSection:kWelcomeSection];
    CGSize leftSize = [self.dataSource sizeOfAdornmentForIndexPath:leftIndexPath];
    UICollectionViewLayoutAttributes *leftLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:leftIndexPath];
    leftLayoutAttributes.frame = CGRectMake(pageOffset - kAdornmentOffset - 100.0,
                                            floorf((size.height - leftSize.height) / 2.0),
                                            leftSize.width,
                                            leftSize.height);
    [self.itemsLayoutAttributes addObject:leftLayoutAttributes];
    [self.indexPathItemAttributes setObject:leftLayoutAttributes forKey:leftIndexPath];
    
    // Right adornment.
    NSIndexPath *rightIndexPath = [NSIndexPath indexPathForItem:1 inSection:kWelcomeSection];
    CGSize rightSize = [self.dataSource sizeOfAdornmentForIndexPath:rightIndexPath];
    UICollectionViewLayoutAttributes *rightLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:rightIndexPath];
    rightLayoutAttributes.frame = CGRectMake(pageOffset + size.width - rightSize.width + kAdornmentOffset + 100.0,
                                             floorf((size.height - rightSize.height) / 2.0),
                                             rightSize.width,
                                             rightSize.height);
    [self.itemsLayoutAttributes addObject:rightLayoutAttributes];
    [self.indexPathItemAttributes setObject:rightLayoutAttributes forKey:rightIndexPath];
}

- (void)buildCreateAdornments {
    
    CGFloat pageOffset = [self pageOffsetForPage:kCreateSection];
    CGSize size = self.collectionView.bounds.size;
    
    // Right adornment.
    NSIndexPath *rightIndexPath = [NSIndexPath indexPathForItem:0 inSection:kCreateSection];
    CGSize rightSize = [self.dataSource sizeOfAdornmentForIndexPath:rightIndexPath];
    UICollectionViewLayoutAttributes *rightLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:rightIndexPath];
    rightLayoutAttributes.frame = CGRectMake(pageOffset + size.width - rightSize.width - 30.0,
                                             floorf((size.height - rightSize.height) / 2.0),
                                             rightSize.width,
                                             rightSize.height);
    [self.itemsLayoutAttributes addObject:rightLayoutAttributes];
    [self.indexPathItemAttributes setObject:rightLayoutAttributes forKey:rightIndexPath];
    
}

- (void)buildCollectAdornments {
    CGFloat pageOffset = [self pageOffsetForPage:kCollectSection];
    CGSize size = self.collectionView.bounds.size;
    
    // Left adornment.
    NSIndexPath *leftIndexPath = [NSIndexPath indexPathForItem:0 inSection:kCollectSection];
    CGSize leftSize = [self.dataSource sizeOfAdornmentForIndexPath:leftIndexPath];
    UICollectionViewLayoutAttributes *leftLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:leftIndexPath];
    leftLayoutAttributes.frame = CGRectMake(pageOffset,
                                            size.height - 225.0,
                                            leftSize.width,
                                            leftSize.height);
    [self.itemsLayoutAttributes addObject:leftLayoutAttributes];
    [self.indexPathItemAttributes setObject:leftLayoutAttributes forKey:leftIndexPath];
    
    // Right adornment.
    NSIndexPath *rightIndexPath = [NSIndexPath indexPathForItem:1 inSection:kCollectSection];
    CGSize rightSize = [self.dataSource sizeOfAdornmentForIndexPath:rightIndexPath];
    UICollectionViewLayoutAttributes *rightLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:rightIndexPath];
    rightLayoutAttributes.frame = CGRectMake(pageOffset + size.width - rightSize.width,
                                             size.height - 225.0,
                                             rightSize.width,
                                             rightSize.height);
    [self.itemsLayoutAttributes addObject:rightLayoutAttributes];
    [self.indexPathItemAttributes setObject:rightLayoutAttributes forKey:rightIndexPath];
}

- (void)buildLibraryAdornments {
    CGFloat pageOffset = [self pageOffsetForPage:kLibrarySection];
    
    // Top/center adornment.
    NSIndexPath *topIndexPath = [NSIndexPath indexPathForItem:0 inSection:kLibrarySection];
    CGSize topSize = [self.dataSource sizeOfAdornmentForIndexPath:topIndexPath];
    UICollectionViewLayoutAttributes *topLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:topIndexPath];
    topLayoutAttributes.frame = CGRectMake(pageOffset,
                                           0.0,
                                           topSize.width,
                                           topSize.height);
    [self.itemsLayoutAttributes addObject:topLayoutAttributes];
    [self.indexPathItemAttributes setObject:topLayoutAttributes forKey:topIndexPath];
}

- (void)buildSignUpAdornments {
    // No adornments.
}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        NSIndexPath *indexPath = attributes.indexPath;
        switch (indexPath.section) {
            case kWelcomeSection:
                [self applyPagingEffectsForWelcomeWithAttributes:attributes];
                break;
            case kCreateSection:
                [self applyPagingEffectsForCreateWithAttributes:attributes];
                break;
            case kCollectSection:
                [self applyPagingEffectsForCollectWithAttributes:attributes];
                break;
            case kLibrarySection:
                [self applyPagingEffectsForLibraryWithAttributes:attributes];
                break;
            case kSignUpSection:
                [self applyPagingEffectsForSignUpWithAttributes:attributes];
                break;
            default:
                break;
        }
    }
}

- (void)applyPagingEffectsForWelcomeWithAttributes:(UICollectionViewLayoutAttributes *)attributes {
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat pageOffset = [self pageOffsetForPage:kWelcomeSection];
    
    if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]
        && indexPath.item > 0) {
        
        if (indexPath.item == 1) {
            
            // Paging view.
            CGPoint startOffsetForPagingView = [self startOffsetForPagingView];
            CGRect frame = attributes.frame;
            frame.origin.x = startOffsetForPagingView.x + self.collectionView.contentOffset.x;
            frame.origin.y = startOffsetForPagingView.y;
            attributes.frame = frame;
            
        }
        
    } else {
        
        if (self.collectionView.contentOffset.x >= pageOffset) {
            
            CGFloat translateRatio = 0.0;
            
            if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                translateRatio = 0.4;
                attributes.alpha = [self alphaForTitleLabelForPage:kWelcomeSection origin:attributes.center.x
                                                        leftOffset:400.0
                                                       rightOffset:floorf((attributes.frame.size.width) / 2.0)];
                
            } else if (indexPath.item == 1) {
                translateRatio = 0.5;
            } else if (indexPath.item == 0) {
                translateRatio = 0.1;
            }
            
            CGFloat distance = self.collectionView.contentOffset.x - pageOffset;
            CATransform3D translate = CATransform3DMakeTranslation(-distance * translateRatio, 0.0, 0.0);
            attributes.transform3D = translate;
            
        } else {
            attributes.transform3D = CATransform3DIdentity;
            attributes.alpha = 1.0;
        }
        
    }
    
}

- (void)applyPagingEffectsForCreateWithAttributes:(UICollectionViewLayoutAttributes *)attributes {
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat startOffset = [self pageOffsetForPage:kWelcomeSection];
    CGFloat pageOffset = [self pageOffsetForPage:kCreateSection];
    
    if (self.collectionView.contentOffset.x >= startOffset &&
        self.collectionView.contentOffset.x <= pageOffset + self.collectionView.bounds.size.width) {
        
        CGFloat translateRatio = 0.0;
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            translateRatio = 0.2;
            
            // Apply alpha.
            attributes.alpha = [self alphaForTitleLabelForPage:kCreateSection origin:attributes.center.x
                                                    leftOffset:floorf(attributes.frame.size.width / 2.0)
                                                   rightOffset:700.0];
            
        } else if (indexPath.item == 0) {
            translateRatio = 0.6;
        }
        
        
        // CGFloat distanceCap = self.collectionView.bounds.size.width;
        CGFloat distance = self.collectionView.contentOffset.x - pageOffset;
        CATransform3D translate = CATransform3DMakeTranslation(-distance * translateRatio, 0.0, 0.0);
        attributes.transform3D = translate;
        
    } else {
        attributes.alpha = 1.0;
        attributes.transform3D = CATransform3DIdentity;
    }
    

}

- (void)applyPagingEffectsForCollectWithAttributes:(UICollectionViewLayoutAttributes *)attributes {
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat startOffset = [self pageOffsetForPage:kCreateSection];
    CGFloat pageOffset = [self pageOffsetForPage:kCollectSection];
    
    if (self.collectionView.contentOffset.x >= startOffset - floorf(self.collectionView.bounds.size.width / 2.0)) {
        
        CGFloat translateRatio = 0.0;
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            translateRatio = 0.4;
            attributes.alpha = [self alphaForTitleLabelForPage:kCollectSection origin:attributes.center.x
                                                    leftOffset:400.0
                                                   rightOffset:400.0];
            CGFloat distance = self.collectionView.contentOffset.x - pageOffset;
            CATransform3D translate = CATransform3DMakeTranslation(-distance * translateRatio, 0.0, 0.0);
            attributes.transform3D = translate;
            
        } else if (indexPath.item == 0 || indexPath.item == 1) {
            translateRatio = 0.5;
            CGFloat distance = self.collectionView.contentOffset.x - pageOffset;
            CATransform3D translate = CATransform3DMakeTranslation(distance, ABS(distance * 0.5), 0.0);
            attributes.transform3D = translate;
        }
        
    } else {
        attributes.transform3D = CATransform3DIdentity;
        attributes.alpha = 1.0;
    }
}

- (void)applyPagingEffectsForLibraryWithAttributes:(UICollectionViewLayoutAttributes *)attributes {
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat startOffset = [self pageOffsetForPage:kCreateSection];
    CGFloat pageOffset = [self pageOffsetForPage:kLibrarySection];
    
    if (self.collectionView.contentOffset.x >= startOffset - floorf(self.collectionView.bounds.size.width / 2.0)) {
        
        CGFloat translateRatio = 0.0;
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            translateRatio = 0.4;
            attributes.alpha = [self alphaForTitleLabelForPage:kLibrarySection origin:attributes.center.x
                                                    leftOffset:400.0
                                                   rightOffset:400.0];
            
            CGFloat distance = self.collectionView.contentOffset.x - pageOffset;
            CATransform3D translate = CATransform3DMakeTranslation(-distance * translateRatio, 0.0, 0.0);
            attributes.transform3D = translate;
            
        } else if (indexPath.item == 0) {
            
            // Library shelf
            CGFloat distance = self.collectionView.contentOffset.x - pageOffset;
            CATransform3D translate = CATransform3DMakeTranslation(distance, -ABS(distance * 0.5), 0.0);
            attributes.transform3D = translate;
        }
        
        
    } else {
        attributes.transform3D = CATransform3DIdentity;
        attributes.alpha = 1.0;
    }
}

- (void)applyPagingEffectsForSignUpWithAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGFloat startOffset = [self pageOffsetForPage:kLibrarySection];
    CGFloat pageOffset = [self pageOffsetForPage:kSignUpSection];
    
    if (self.collectionView.contentOffset.x >= startOffset - floorf(self.collectionView.bounds.size.width / 2.0)) {
        
        CGFloat translateRatio = 0.0;
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            translateRatio = 0.4;
            attributes.alpha = [self alphaForTitleLabelForPage:kSignUpSection origin:attributes.center.x
                                                    leftOffset:400.0
                                                   rightOffset:400.0];
        }
        
        // CGFloat distanceCap = self.collectionView.bounds.size.width;
        CGFloat distance = self.collectionView.contentOffset.x - pageOffset;
        CATransform3D translate = CATransform3DMakeTranslation(-distance * translateRatio, 0.0, 0.0);
        attributes.transform3D = translate;
        
    } else {
        attributes.transform3D = CATransform3DIdentity;
        attributes.alpha = 1.0;
    }
}

- (CGPoint)startOffsetForPagingView {
    CGFloat bottomGap = kPagingUpOffset;
    CGFloat pageOffset = [self pageOffsetForPage:kWelcomeSection];
    CGSize size = [self.dataSource sizeOfPageHeaderForPage:kWelcomeSection indexPath:[NSIndexPath indexPathForItem:1 inSection:kWelcomeSection]];
    
    CGPoint startPoint = CGPointMake(pageOffset + floorf((self.collectionView.bounds.size.width - size.width)) / 2.0,
                                     self.collectionView.bounds.size.height - size.height - bottomGap);
    return startPoint;
}

- (CGFloat)alphaForTitleLabelForPage:(NSInteger)page origin:(CGFloat)originOffset leftOffset:(CGFloat)leftOffset
                         rightOffset:(CGFloat)rightOffset {
    CGFloat alpha = 0.0;
    CGFloat pageOffset = [self pageOffsetForPage:page];
    CGFloat adjustment = originOffset - pageOffset;
    CGFloat distance = originOffset - self.collectionView.contentOffset.x - adjustment;
//    DLog(@"PAGE[%d] ORIGIN[%f] ADJUSTMENT[%f] DISTANCE[%f]", page, originOffset, adjustment, distance);
    if (distance >= 0 && distance <= rightOffset) {
        alpha = 1.0 - ABS(distance / rightOffset);
    } else if (distance <= 0 &&  ABS(distance <= leftOffset)) {
        alpha = 1.0 - ABS(distance / leftOffset);
    }
    
    return alpha;
}

@end
