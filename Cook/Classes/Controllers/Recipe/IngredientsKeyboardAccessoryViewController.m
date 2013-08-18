//
//  IngredientsKeyboardAccessoryViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientsKeyboardAccessoryViewController.h"
#import "IngredientsKeyboardAccessoryCell.h"
#import "AppHelper.h"

@interface IngredientsKeyboardAccessoryViewController ()

@property (nonatomic, strong) NSArray *keyboardIngredients;
@property (nonatomic, strong) NSArray *flattenKeyboardIngredients;

@end

@implementation IngredientsKeyboardAccessoryViewController

#define kHeight 56.0
#define kCellId @"CellId"

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
        self.keyboardIngredients = [[AppHelper sharedInstance] keyboardIngredients];
        self.flattenKeyboardIngredients = [self.keyboardIngredients valueForKeyPath:@"@unionOfArrays.self"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = self.view.frame;
    frame.size.width = [[AppHelper sharedInstance] fullScreenFrame].size.width;
    frame.size.height = kHeight;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.view.frame = frame;
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"cook_keyboard_autosuggest_bg.png"]
                                resizableImageWithCapInsets:(UIEdgeInsets){ 0.0, 4.0, 0.0, 4.0 }];
    self.collectionView.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView registerClass:[IngredientsKeyboardAccessoryCell class] forCellWithReuseIdentifier:kCellId];
}

- (NSArray *)allUnitOfMeasureOptions {
    return self.flattenKeyboardIngredients;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    UIEdgeInsets insets = (UIEdgeInsets) { 10.0, 7.0, 6.0, 21.0 };
    NSInteger numSections = [self.collectionView numberOfSections];
    if (section == numSections - 1) {
        insets.right = 7.0; // Ends with a 7pt.
    }
    return insets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    // Space between columns.
    return 10.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [IngredientsKeyboardAccessoryCell cellSize];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[self.keyboardIngredients objectAtIndex:indexPath.section] objectAtIndex:indexPath.item];
    [self.delegate ingredientsKeyboardAccessorySelectedValue:text];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.keyboardIngredients count];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [[self.keyboardIngredients objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    IngredientsKeyboardAccessoryCell *cell = (IngredientsKeyboardAccessoryCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    [cell configureText:[[self.keyboardIngredients objectAtIndex:indexPath.section] objectAtIndex:indexPath.item]];
    
    return cell;
}

@end
