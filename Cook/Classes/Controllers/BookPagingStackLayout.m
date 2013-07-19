//
//  BookPagingStackLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookPagingStackLayout.h"
#import "BookNavigationView.h"
#import "BookProfileHeaderView.h"
#import "ViewHelper.h"

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

#define kShiftOffset                400.0
#define kHeaderShiftOffset          200.0
#define kProfileHeaderOffset        400.0
#define kMaxScale                   0.9
#define kMaxRotationDegrees         10.0
#define DEGREES_TO_RADIANS(angle)   ((angle) / 180.0 * M_PI)
#define kPageNavigationtKind        @"PageNavigationtKind"

+ (NSString *)bookPagingNavigationElementKind {
    return kPageNavigationtKind;
}

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
    [self buildHeadersLayout];
    [self buildNavigationLayout];
    
    // Inform end of layout prep.
    [self.delegate stackPagingLayoutDidFinish];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    // Determine direction of travel.
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    self.forwardDirection = newBounds.origin.x > visibleFrame.origin.x;
    
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Header cells.
    for (UICollectionViewLayoutAttributes *attributes in self.supplementaryLayoutAttributes) {
        
        // Navigation header.
        if ([attributes.representedElementKind isEqualToString:kPageNavigationtKind]) {
            NSInteger numSections = [self.collectionView numberOfSections];
            if (numSections > [self.delegate stackCategoryStartSection]) {
                [layoutAttributes addObject:attributes];
            }
        } else {
            
            // Header cells.
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [layoutAttributes addObject:attributes];
            }
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
        NSInteger numSections = [self.collectionView numberOfSections];
        if (numSections > [self.delegate stackCategoryStartSection]) {
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
        
        // First page is under the second page.
        if (indexPath.section == 0) {
            attributes.zIndex = -3;
        } else {
            attributes.zIndex = -(sectionIndex * 2);
        }

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

- (void)buildHeadersLayout {
    [self buildProfileHeaderLayout];
    [self buildCategoryHeadersLayout];
}

- (void)buildCategoryHeadersLayout {
    
    // One header per recipe category.
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
            self.collectionView.bounds.size.height
        };
        
        // First page is under the second page.
        if (sectionIndexPath.section == 0) {
            headerAttributes.zIndex = -1;
        } else {
            headerAttributes.zIndex = -(sectionIndex * 2) - 1;
        }
        
        [self.supplementaryLayoutAttributes addObject:headerAttributes];
        [self.indexPathSupplementaryAttributes setObject:headerAttributes forKey:sectionIndexPath];
        
    }
}

- (void)buildProfileHeaderLayout {
    NSIndexPath *profileIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *profileHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                               withIndexPath:profileIndexPath];
    profileHeaderAttributes.frame = (CGRect){
        [self pageOffsetForIndexPath:profileIndexPath],
        self.collectionView.bounds.origin.y,
        [BookProfileHeaderView profileHeaderWidth],
        self.collectionView.bounds.size.height
    };
    
    // Profile header is above the profile page.
    profileHeaderAttributes.zIndex = -1;
    
    [self.supplementaryLayoutAttributes addObject:profileHeaderAttributes];
    [self.indexPathSupplementaryAttributes setObject:profileHeaderAttributes forKey:profileIndexPath];
}

- (void)buildNavigationLayout {
    NSInteger categoryStartSection = [self.delegate stackCategoryStartSection];
    NSIndexPath *navigationIndexPath = [NSIndexPath indexPathForItem:0 inSection:categoryStartSection];
    
    UICollectionViewLayoutAttributes *previousAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    UICollectionViewLayoutAttributes *navigationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kPageNavigationtKind
                                                                                                                            withIndexPath:navigationIndexPath];
    navigationAttributes.frame = (CGRect){
        [self pageOffsetForIndexPath:navigationIndexPath],
        self.collectionView.bounds.origin.y,
        self.collectionView.bounds.size.width,
        [BookNavigationView navigationHeight]
    };
    navigationAttributes.zIndex = previousAttributes.zIndex - 1;
    [self.supplementaryLayoutAttributes addObject:navigationAttributes];
    [self.indexPathSupplementaryAttributes setObject:navigationAttributes forKey:navigationIndexPath];
}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        NSIndexPath *indexPath = attributes.indexPath;
        
        if ([attributes.representedElementKind isEqualToString:kPageNavigationtKind]) {
            
            [self applyStickyNavigationHeaderEffect:attributes];
            
        } else if (indexPath.section == 0) {
            
            [self applyProfilePagingEffects:attributes];
            
        } else if (indexPath.section > 1) {
            
            [self applyCategoryPagingEffects:attributes];
        
        }
    }
}

- (void)applyCategoryPagingEffects:(UICollectionViewLayoutAttributes *)attributes {
    
    // Parallaxing on category pages.
    CGFloat requiredTranslation = [self shiftedTranslationForAttributes:attributes];
    CGRect frame = attributes.frame;
    frame.origin.x += requiredTranslation;
    attributes.frame = frame;
    
}

- (void)applyProfilePagingEffects:(UICollectionViewLayoutAttributes *)attributes {
    
    CGFloat requiredTranslation = 0.0;
    CGRect frame = attributes.frame;
    
    if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        // Profile header slides in later when in view.
        requiredTranslation = [self shiftedTranslationForProfileHeaderAttributes:attributes];
        
    } else {
        
        // Profile page slides under the index page.
        requiredTranslation = [self shiftedTranslationForProfileAttributes:attributes];
    }
    
    frame.origin.x += requiredTranslation;
    attributes.frame = frame;
}

- (void)applyStickyNavigationHeaderEffect:(UICollectionViewLayoutAttributes *)attributes {
    if (![attributes.representedElementKind isEqualToString:kPageNavigationtKind]) {
        return;
    }
    
    CGFloat offset =  kShiftOffset;
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGRect navigationFrame = attributes.frame;
    NSInteger categoryStartSection = [self.delegate stackCategoryStartSection];
    CGFloat startOffset = categoryStartSection * self.collectionView.bounds.size.width;
    
    if (visibleFrame.origin.x >= startOffset) {
        
        navigationFrame.origin.x = visibleFrame.origin.x;
        attributes.frame = navigationFrame;
        
    } else if (navigationFrame.origin.x >= visibleFrame.origin.x) {
        
        // Figure out the pageDistance and the ratio.
        CGFloat distance = navigationFrame.origin.x - visibleFrame.origin.x;
        CGFloat normalisedDistance = distance / self.collectionView.bounds.size.width;
        NSInteger pageDistance = (NSInteger)normalisedDistance;
        
        // Magic formula.
        CGFloat effectiveDistance = (pageDistance * offset) + (self.collectionView.bounds.size.width - ((pageDistance + 1) * offset));
        CGFloat distanceRatio = distance / self.collectionView.bounds.size.width;
        CGFloat requiredTranslation = -effectiveDistance * distanceRatio;
        
        navigationFrame.origin.x += requiredTranslation;
        attributes.frame = navigationFrame;
        
    }
    
}

- (CGFloat)shiftedTranslationForAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
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

- (CGFloat)shiftedTranslationForProfileAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGFloat requiredTranslation = 0.0;
    
    CGFloat offset = kShiftOffset;
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat pageOffset = [self pageOffsetForIndexPath:indexPath];
    
    if (visibleFrame.origin.x >= pageOffset) {
        
        // Figure out the percentage of distance.
        CGFloat distance = visibleFrame.origin.x - pageOffset;
        CGFloat distanceRatio = distance / self.collectionView.bounds.size.width;
        
        // Full effective distance to travel.
        CGFloat effectiveDistance = self.collectionView.bounds.size.width - offset;
        
        requiredTranslation = effectiveDistance * distanceRatio;
    }
    
    return requiredTranslation;
}

- (CGFloat)shiftedTranslationForProfileHeaderAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGFloat requiredTranslation = 0.0;
    
    CGFloat offset = kProfileHeaderOffset;
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat pageOffset = [self pageOffsetForIndexPath:indexPath];
    
    if (visibleFrame.origin.x >= pageOffset) {
        
        // Figure out the percentage of distance.
        CGFloat distance = visibleFrame.origin.x - pageOffset;
        CGFloat distanceRatio = distance / self.collectionView.bounds.size.width;
        
        // Full effective distance to travel.
        CGFloat effectiveDistance = -offset;
        requiredTranslation = effectiveDistance * distanceRatio;
    }
    
    return requiredTranslation;
}


- (CGFloat)pageOffsetForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section * self.collectionView.bounds.size.width;
}

@end
