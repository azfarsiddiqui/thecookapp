//
//  BookPagingStackLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookPagingStackLayout.h"

@interface BookPagingStackLayout ()

@property (nonatomic, weak) id<BookPagingStackLayoutDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;
@property (nonatomic, strong) NSMutableArray *decorationLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathDecorationAttributes;

@property (nonatomic, assign) BOOL forwardDirection;

@end

@implementation BookPagingStackLayout

#define kShiftOffset                200.0
#define kHeaderShiftOffset          400.0
#define kMaxScale                   0.9
#define kMaxRotationDegrees         10.0
#define DEGREES_TO_RADIANS(angle)   ((angle) / 180.0 * M_PI)
#define kPageShadowLeftKind         @"PageShadowLeftKind"
#define kPageShadowRightKind        @"PageShadowRightKind"

- (id)initWithDelegate:(id<BookPagingStackLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    NSInteger numSections = [self.collectionView numberOfSections];
    return (CGSize) { numSections * self.collectionView.bounds.size.width, self.collectionView.bounds.size.height };
}

- (void)prepareLayout {
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.supplementaryLayoutAttributes = [NSMutableArray array];
    self.decorationLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    self.indexPathDecorationAttributes = [NSMutableDictionary dictionary];
    
    [self buildPagesLayout];
    [self buildCategoryHeadersLayout];
    
    // Inform end of layout prep.
    [self.delegate stackPagingLayoutDidFinish];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    // Determine direction of travel.
    CGRect visibleFrame = [self visibleFrame];
    self.forwardDirection = newBounds.origin.x > visibleFrame.origin.x;
    
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Header cells.
    for (UICollectionViewLayoutAttributes *attributes in self.supplementaryLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    // Item cells.
    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    // Decoration cells.
    for (UICollectionViewLayoutAttributes *attributes in self.decorationLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    // Apply transform for paging.
    [self applyPagingEffects:layoutAttributes];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                                                  atIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathDecorationAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathSupplementaryAttributes objectForKey:indexPath];
}

#pragma mark - Private methods

- (void)buildPagesLayout {
    
    // One page per section.
    NSInteger numSections = [self.collectionView numberOfSections];
    for (NSInteger sectionIndex = 0; sectionIndex < numSections; sectionIndex++) {
        
        // Single page layout.
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:sectionIndex];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.zIndex = -sectionIndex;
        attributes.frame = (CGRect){
            [self pageOffsetForIndexPath:indexPath],
            self.collectionView.bounds.origin.y,
            self.collectionView.bounds.size.width,
            self.collectionView.bounds.size.height
        };
        [self.itemsLayoutAttributes addObject:attributes];
        [self.indexPathItemAttributes setObject:attributes forKey:indexPath];
        
    }
    
}

- (void)buildCategoryHeadersLayout {
    
    // One page per category, only there are more than 2 sections.
    NSInteger numSections = [self.collectionView numberOfSections];
    NSInteger categoryStartSection = [self.delegate stackCategoryStartSection];
    for (NSInteger sectionIndex = categoryStartSection; sectionIndex < numSections; sectionIndex++) {
            
        // Category header.
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:sectionIndex];
        UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                            withIndexPath:sectionIndexPath];
        headerAttributes.frame = (CGRect){
            [self pageOffsetForIndexPath:sectionIndexPath],
            self.collectionView.bounds.origin.y,
            self.collectionView.bounds.size.width,
            400.0
        };
        headerAttributes.zIndex = -sectionIndex;
        [self.supplementaryLayoutAttributes addObject:headerAttributes];
        [self.indexPathSupplementaryAttributes setObject:headerAttributes forKey:sectionIndexPath];
        
    }

}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    
    switch ([self.delegate stackPagingLayoutType]) {
        case BookPagingStackLayoutTypeSlideOneWay:
            [self applySlideOneWayEffects:layoutAttributes];
            break;
        case BookPagingStackLayoutTypeSlideOneWayScale:
            [self applySlideOneWayScaleEffects:layoutAttributes];
            break;
        case BookPagingStackLayoutTypeSlideBothWays:
            [self applySlideBothWaysEffects:layoutAttributes];
            break;
        default:
            break;
    }
    
}

- (void)applySlideOneWayEffects:(NSArray *)layoutAttributes {
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        // Translate.
        CGFloat requiredTranslation = [self shiftedTranslationForAttributes:attributes];
        CATransform3D translate = CATransform3DMakeTranslation(requiredTranslation, 0.0, 0.0);
        if (requiredTranslation == 0) {
            translate = CATransform3DIdentity;
        }
        attributes.transform3D = translate;
        
    }
    
}

- (void)applySlideOneWayScaleEffects:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        // Translate.
        CGFloat requiredTranslation = [self shiftedTranslationForAttributes:attributes];
        CATransform3D translate = CATransform3DMakeTranslation(requiredTranslation, 0.0, 0.0);
        if (requiredTranslation == 0) {
            translate = CATransform3DIdentity;
        }
        attributes.transform3D = translate;
        
        // Scale
        CGFloat requiredScale = [self scaleForAttributes:attributes];
        CATransform3D scale = CATransform3DScale(translate, requiredScale, requiredScale, 0.0);
        if (requiredScale == 1.0) {
            scale = CATransform3DIdentity;
        }
        attributes.transform3D = scale;
        
        
    }
    
}

- (void)applySlideBothWaysEffects:(NSArray *)layoutAttributes {
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        CATransform3D transform = attributes.transform3D;
        
        // Translate.
        CGFloat requiredTranslation = [self shiftedTranslationForAttributes:attributes];
        transform = CATransform3DTranslate(transform, requiredTranslation, 0.0, 0.0);
        
        attributes.transform3D = transform;
    }
    
}

- (CGFloat)shiftedTranslationForAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [self visibleFrame];
    CGFloat requiredTranslation = 0.0;
    
    CGFloat offset =  kShiftOffset;
    if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        offset = kHeaderShiftOffset;
    }
    
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat pageOffset = [self pageOffsetForIndexPath:indexPath];
    CGRect cellFrame = attributes.frame;
    
    if (pageOffset >= visibleFrame.origin.x) {
        
        // Figure out the pageDistance and the ratio.
        CGFloat distance = cellFrame.origin.x - visibleFrame.origin.x;
        CGFloat normalisedDistance = distance / self.collectionView.bounds.size.width;
        NSInteger pageDistance = (NSInteger)normalisedDistance;
        
        // Magic formula.
        CGFloat effectiveDistance = (pageDistance * offset) + (self.collectionView.bounds.size.width - ((pageDistance + 1) * offset));
        
        CGFloat distanceRatio = distance / self.collectionView.bounds.size.width;
        requiredTranslation = -effectiveDistance * distanceRatio;
    }
    
    return requiredTranslation;
}

- (CGFloat)scaleForAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [self visibleFrame];
    CGFloat requiredScale = 0.0;
    
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat pageOffset = [self pageOffsetForIndexPath:indexPath];
    CGRect cellFrame = attributes.frame;
    
    if (pageOffset >= visibleFrame.origin.x) {
        CGFloat distance = cellFrame.origin.x - visibleFrame.origin.x;
        requiredScale = 1.0 - distance / self.collectionView.bounds.size.width;
    } else {
        requiredScale = 1.0;
    }
    
    return MAX(requiredScale, kMaxScale);
}

- (CGFloat)rotationForAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [self visibleFrame];
    CGFloat requiredRotation = 0.0;
    
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat pageOffset = [self pageOffsetForIndexPath:indexPath];
    CGRect cellFrame = attributes.frame;
    
    if (pageOffset >= visibleFrame.origin.x) {
        CGFloat distance = cellFrame.origin.x - visibleFrame.origin.x;
        requiredRotation = (distance / self.collectionView.bounds.size.width) * kMaxRotationDegrees;
    }
    
    return MIN(requiredRotation, kMaxRotationDegrees);
}

- (CGRect)visibleFrame {
    return (CGRect){
        self.collectionView.contentOffset.x,
        self.collectionView.contentOffset.y,
        self.collectionView.bounds.size.width,
        self.collectionView.bounds.size.height
    };
}

- (CGFloat)pageOffsetForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section * self.collectionView.bounds.size.width;
}

@end
