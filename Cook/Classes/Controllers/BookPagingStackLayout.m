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
@property (nonatomic, assign) BOOL layoutCompleted;
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
#define kProfileHeaderOffset        50.0
#define kMaxScale                   0.9
#define kMaxRotationDegrees         10.0
#define kForceVisibleOffset         1.0
#define DEGREES_TO_RADIANS(angle)   ((angle) / 180.0 * M_PI)
#define kPageNavigationtKind        @"PageNavigationtKind"
#define kLayoutDebug                0

+ (NSString *)bookPagingNavigationElementKind {
    return kPageNavigationtKind;
}

- (id)initWithDelegate:(id<BookPagingStackLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setNeedsRelayout:(BOOL)relayout {
    self.layoutCompleted = !relayout;
}

- (CGFloat)pageOffsetForIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section * self.collectionView.bounds.size.width;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    NSInteger numSections = [self.collectionView numberOfSections];
    return (CGSize) { numSections * self.collectionView.bounds.size.width, self.collectionView.bounds.size.height };
}

- (void)prepareLayout {
    
    // Skip if layout does not need to be regenerated.
    if (self.layoutCompleted) {
        return;
    }
    DLog();
    
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.supplementaryLayoutAttributes = [NSMutableArray array];
    self.decorationLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    self.indexPathDecorationAttributes = [NSMutableDictionary dictionary];
    
    [self buildPagesLayout];
    [self buildHeadersLayout];
    [self buildNavigationLayout];
    
    // Mark layout as generated.
    self.layoutCompleted = YES;
    
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
            
            NSIndexPath *indexPath = attributes.indexPath;
            
            // Dark nav.
            if (indexPath.section == 1) {
                [layoutAttributes addObject:attributes];
            }
            
            // Light nav only in category sections.
            NSInteger numSections = [self.collectionView numberOfSections];
            if (numSections > [self.delegate stackContentStartSection]) {
                [layoutAttributes addObject:attributes];
            }
            
        } else {
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
        if (numSections > [self.delegate stackContentStartSection]) {
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
            attributes.zIndex = -numSections * 2;   // Sme big number.
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
    NSInteger categoryStartSection = [self.delegate stackContentStartSection];
    for (NSInteger sectionIndex = categoryStartSection; sectionIndex < numSections; sectionIndex++) {
        
        // Category header.
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:sectionIndex];
        UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                            withIndexPath:sectionIndexPath];
        headerAttributes.frame = (CGRect){
            [self pageOffsetForIndexPath:sectionIndexPath] - kForceVisibleOffset,
            self.collectionView.bounds.origin.y,
            self.collectionView.bounds.size.width + (kForceVisibleOffset * 2.0),
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
    UICollectionViewLayoutAttributes *profileHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:profileIndexPath];
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
    
    UICollectionViewLayoutAttributes *homeAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    
    // White content nav header.
    NSInteger categoryStartSection = [self.delegate stackContentStartSection];
    NSIndexPath *navigationIndexPath = [NSIndexPath indexPathForItem:0 inSection:categoryStartSection];
    
    UICollectionViewLayoutAttributes *navigationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kPageNavigationtKind withIndexPath:navigationIndexPath];
    navigationAttributes.frame = [self navigationFrameForDark:NO];
    navigationAttributes.zIndex = homeAttributes.zIndex - 1;        // Goes under the homepage.
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
    attributes.transform3D = CATransform3DMakeTranslation(requiredTranslation, 0.0, 0.0);
}

- (void)applyProfilePagingEffects:(UICollectionViewLayoutAttributes *)attributes {
    
    if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        // Profile header slides in later when in view.
        [self applyProfileHeaderPagingEffects:attributes];
        
    } else {
        
        // Profile page slides under the index page.
        CGFloat requiredTranslation = [self shiftedTranslationForProfileAttributes:attributes];
        attributes.transform3D = CATransform3DMakeTranslation(requiredTranslation, 0.0, 0.0);
    }
    
}

- (void)applyStickyNavigationHeaderEffect:(UICollectionViewLayoutAttributes *)attributes {
    
    if (![attributes.representedElementKind isEqualToString:kPageNavigationtKind]) {
        return;
    }
    
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    NSIndexPath *navigationIndexPath = attributes.indexPath;
    if (navigationIndexPath.section >= [self.delegate stackContentStartSection]) {
        
        CGFloat offset =  kShiftOffset;
        CGRect navigationFrame = [self navigationFrameForDark:NO];
        NSInteger categoryStartSection = [self.delegate stackContentStartSection];
        CGFloat startOffset = categoryStartSection * self.collectionView.bounds.size.width;
        CGSize contentSize = [self collectionViewContentSize];
        
        if (visibleFrame.origin.x > startOffset) {
            
            CGFloat offset = MIN(visibleFrame.origin.x, contentSize.width - self.collectionView.bounds.size.width);
            CGFloat requiredTranslation = offset - navigationFrame.origin.x;
            attributes.transform3D = CATransform3DMakeTranslation(requiredTranslation, 0.0, 0.0);
            
        } else if (visibleFrame.origin.x > self.collectionView.bounds.size.width
                   && navigationFrame.origin.x >= visibleFrame.origin.x) {
            
            // Figure out the pageDistance and the ratio.
            CGFloat distance = navigationFrame.origin.x - visibleFrame.origin.x;
            CGFloat normalisedDistance = distance / self.collectionView.bounds.size.width;
            NSInteger pageDistance = (NSInteger)normalisedDistance;
            
            // Magic formula.
            CGFloat effectiveDistance = (pageDistance * offset) + (self.collectionView.bounds.size.width - ((pageDistance + 1) * offset));
            CGFloat distanceRatio = distance / self.collectionView.bounds.size.width;
            CGFloat requiredTranslation = -effectiveDistance * distanceRatio;
            
            attributes.transform3D = CATransform3DMakeTranslation(requiredTranslation, 0.0, 0.0);
        }
    }
    
    // Set the alpha of the navigation view.
    attributes.alpha = [self.delegate alphaForBookNavigationView];

}

- (CGFloat)shiftedTranslationForAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGFloat requiredTranslation = 0.0;
    
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat pageOffset = [self pageOffsetForIndexPath:indexPath];
    CGFloat availableDistance = self.collectionView.bounds.size.width;
    
    CGFloat offset =  kShiftOffset;
    if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        offset = kHeaderShiftOffset;
        pageOffset -= kForceVisibleOffset;
        availableDistance += (kForceVisibleOffset * 2.0);
    }
    
    if (pageOffset >= visibleFrame.origin.x) {
        
        // Figure out the pageDistance and the ratio.
        CGFloat distance = pageOffset - visibleFrame.origin.x;
        CGFloat normalisedDistance = distance / availableDistance;
        NSInteger pageDistance = (NSInteger)normalisedDistance;
        
        if (pageDistance < 1) {
            
            // Magic formula.
            CGFloat effectiveDistance = (pageDistance * offset) + (availableDistance - ((pageDistance + 1) * offset));
            CGFloat distanceRatio = distance / availableDistance;
            requiredTranslation = -effectiveDistance * distanceRatio;
            
        }
        
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

- (void)applyProfileHeaderPagingEffects:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGFloat requiredTranslation = 0.0;
    CGFloat requiredAlpha = 1.0;
    
    CGFloat offset = kProfileHeaderOffset;
    NSIndexPath *indexPath = attributes.indexPath;
    CGFloat pageOffset = [self pageOffsetForIndexPath:indexPath];
    
    if (visibleFrame.origin.x >= pageOffset) {
        
        // Figure out the percentage of distance.
        CGFloat distance = visibleFrame.origin.x - pageOffset;
        CGFloat distanceRatio = distance / self.collectionView.bounds.size.width;
        
        // Full effective distance to travel.
        CGFloat effectiveDistance = offset;
        requiredTranslation = effectiveDistance * distanceRatio;
        requiredAlpha = 1.0 - distanceRatio;
    }
    
    attributes.transform3D = CATransform3DMakeTranslation(requiredTranslation, 0.0, 0.0);
    attributes.alpha = requiredAlpha;
}

- (CGRect)navigationFrameForDark:(BOOL)dark {
    if (dark) {
        NSIndexPath *navigationIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
        return (CGRect){
            [self pageOffsetForIndexPath:navigationIndexPath],
            self.collectionView.bounds.origin.y,
            self.collectionView.bounds.size.width,
            [BookNavigationView darkNavigationHeight]
        };
    } else {
        NSInteger categoryStartSection = [self.delegate stackContentStartSection];
        NSIndexPath *navigationIndexPath = [NSIndexPath indexPathForItem:0 inSection:categoryStartSection];
        return (CGRect){
            [self pageOffsetForIndexPath:navigationIndexPath],
            self.collectionView.bounds.origin.y,
            self.collectionView.bounds.size.width,
            [BookNavigationView navigationHeight]
        };
    }
}

- (NSString *)stringTypeForElementCategory:(UICollectionElementCategory)category {
    NSString *type = nil;
    if (category == UICollectionElementCategoryCell) {
        type = @"cell";
    } else if (category == UICollectionElementCategorySupplementaryView) {
        type = @"supp";
    } else if (category == UICollectionElementCategoryDecorationView) {
        type = @"deco";
    }
    return type;
}

@end
