//
//  IngredientListEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientListEditViewController.h"
#import "IngredientListCell.h"
#import "Ingredient.h"
#import "NSString+Utilities.h"
#import "IngredientsKeyboardAccessoryViewController.h"

@interface IngredientListEditViewController ()

@property (nonatomic, strong) IngredientsKeyboardAccessoryViewController *ingredientsAccessoryViewController;
@property (nonatomic, strong) UIView *hintsView;

@end

@implementation IngredientListEditViewController

#define kFooterId   @"FooterId"

- (void)tappedToAddCell:(id)sender {
    [self addCellToBottom];
}

#pragma mark - CKEditViewController methods

- (id)updatedValue {
    return self.items;
}

#pragma mark - Lifecycle events.

- (void)targetTextEditingViewDidCreated {
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterId];
}

#pragma mark - CKListEditViewController methods

- (Class)classForListCell {
    return [IngredientListCell class];
}

- (void)configureCell:(IngredientListCell *)itemCell indexPath:(NSIndexPath *)indexPath {
    [super configureCell:itemCell indexPath:indexPath];
    itemCell.ingredientsAccessoryViewController = self.ingredientsAccessoryViewController;
    itemCell.allowSelection = NO;
}

- (id)createNewItem {
    return [Ingredient ingredientwithName:nil measurement:nil];
}

- (CGSize)cellSize {
    CGSize size = [super cellSize];
    return (CGSize){
        size.width,
        70.0
    };
}

- (BOOL)isEmptyForValue:(id)currentValue {
    
    Ingredient *ingredient = (Ingredient *)currentValue;
    
    // Empty if both contains no value.
    return (![ingredient.measurement CK_containsText] && ![ingredient.name CK_containsText]);
}

#pragma mark - UICollectionViewDataSource methods

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *suppView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        suppView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                      withReuseIdentifier:kFooterId forIndexPath:indexPath];
        CGRect hintsFrame = self.hintsView.frame;
        hintsFrame.origin.x = floorf((self.collectionView.bounds.size.width - hintsFrame.size.width) / 2.0);
        self.hintsView.frame = hintsFrame;
        self.hintsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [suppView addSubview:self.hintsView];
    }
    
    return suppView;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    CGSize footerSize = CGSizeZero;
    
    footerSize = self.hintsView.frame.size;
    
    return footerSize;
}

#pragma mark - Properties

- (IngredientsKeyboardAccessoryViewController *)ingredientsAccessoryViewController {
    if (!_ingredientsAccessoryViewController) {
        _ingredientsAccessoryViewController = [[IngredientsKeyboardAccessoryViewController alloc] init];
    }
    return _ingredientsAccessoryViewController;
}

- (UIView *)hintsView {
    if (!_hintsView) {
        _hintsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_Ingredientshint.png"]];
        //TEST to add cells
        _hintsView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapToAddGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToAddCell:)];
        [_hintsView addGestureRecognizer:tapToAddGesture];
    }
    return _hintsView;
}

@end
