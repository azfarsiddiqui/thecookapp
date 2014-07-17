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
#import "Theme.h"

@interface IngredientListEditViewController ()

@property (nonatomic, strong) IngredientsKeyboardAccessoryViewController *ingredientsAccessoryViewController;
@property (nonatomic, strong) UIView *hintsView;

@end

@implementation IngredientListEditViewController

#define kFooterId   @"FooterId"

- (void)tappedToAddCell:(id)sender {
    if ([self allowedToAdd]) {
        [self addCellToBottom];
        [self fadeHintAcoordingToCount];
    }
}

- (void)addCellFromTop {
    if ([self allowedToAdd]) {
        [super addCellFromTop];
        [self fadeHintAcoordingToCount];
    }
}

- (void)fadeHintAcoordingToCount {
    if ([self.items count] > 2) {
        self.hintsView.alpha = 0.38;
    } else if ([self.items count] > 1) {
        self.hintsView.alpha = 0.5;
    } else {
        self.hintsView.alpha = 1.0;
    }
}

- (BOOL)allowedToAdd {
    return YES;
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

- (void)setEditing:(BOOL)editing {
    [super setEditing:editing];
    self.canReorderItems = YES;
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
        [self fadeHintAcoordingToCount];
        [suppView addSubview:self.hintsView];
        
        UITapGestureRecognizer *tapToAddGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToAddCell:)];
        [suppView addGestureRecognizer:tapToAddGesture];
    }
    
    return suppView;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    CGSize footerSize = CGSizeZero;
    
    footerSize = CGSizeMake(self.view.frame.size.width, 400);
    
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
        
        CGFloat verticalOffset = 66.0;
        
        UILabel *addLabel = [self hintLabelWithText:NSLocalizedString(@"TAP BELOW TO ADD", nil)];
        addLabel.frame = (CGRect){
            116.0 - floorf(addLabel.frame.size.width / 2.0),
            verticalOffset,
            addLabel.frame.size.width,
            addLabel.frame.size.height
        };
        [_hintsView addSubview:addLabel];
        
        UILabel *pullLabel = [self hintLabelWithText:NSLocalizedString(@"PULL DOWN TO ADD ABOVE", nil)];
        pullLabel.frame = (CGRect){
            306.0 - floorf(pullLabel.frame.size.width / 2.0),
            verticalOffset,
            pullLabel.frame.size.width,
            pullLabel.frame.size.height
        };
        [_hintsView addSubview:pullLabel];
        
        UILabel *swipeLabel = [self hintLabelWithText:NSLocalizedString(@"SWIPE RIGHT TO DELETE", nil)];
        swipeLabel.frame = (CGRect){
            498.0 - floorf(swipeLabel.frame.size.width / 2.0),
            verticalOffset,
            swipeLabel.frame.size.width,
            swipeLabel.frame.size.height
        };
        [_hintsView addSubview:swipeLabel];
        
        UILabel *dragLabel = [self hintLabelWithText:NSLocalizedString(@"PRESS AND DRAG TO REORDER", nil)];
        dragLabel.frame = (CGRect){
            688.0 - floorf(dragLabel.frame.size.width / 2.0),
            verticalOffset,
            dragLabel.frame.size.width,
            dragLabel.frame.size.height
        };
        [_hintsView addSubview:dragLabel];
        
    }
    return _hintsView;
}

- (UILabel *)hintLabelWithText:(NSString *)text {
    
    CGFloat maxWidth = 180.0;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [Theme ingredientsHintTextColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    label.shadowColor = [Theme ingredientsHintShadowColor];
    label.font = [Theme ingredientsHintTextFont];
    label.shadowOffset = (CGSize) { 0.0, 2.0 };
    label.text = text;
    
    CGSize labelSize = (CGSize){ maxWidth, MAXFLOAT };
    CGRect labelFrame = label.frame;
    CGSize size = [label sizeThatFits:labelSize];
    labelFrame.size = size;
    label.frame = labelFrame;

    return label;
}

@end
