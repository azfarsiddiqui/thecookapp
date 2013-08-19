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
#import "MRCEnumerable.h"

@interface IngredientsKeyboardAccessoryViewController ()

@property (nonatomic, strong) NSArray *keyboardIngredientsInfo;
@property (nonatomic, strong) NSMutableDictionary *ingredientsLookup;
@property (nonatomic, strong) NSMutableArray *keyboardIngredients;

@end

@implementation IngredientsKeyboardAccessoryViewController

#define kHeight 56.0
#define kCellId @"CellId"

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
        
        // Load from the plist.
        self.keyboardIngredientsInfo = [[AppHelper sharedInstance] keyboardIngredients];
        
        // Merge all the lookups, replaces duplicated keys.
        self.ingredientsLookup = [NSMutableDictionary dictionary];
        self.keyboardIngredients = [NSMutableArray array];
        for (NSArray *ingredients in self.keyboardIngredientsInfo) {
            for (NSDictionary *ingredientsInfo in ingredients) {
                
                NSString *ingredient = [ingredientsInfo valueForKey:@"Value"];
                [self.ingredientsLookup setObject:ingredientsInfo forKey:ingredient];
                [self.keyboardIngredients addObject:ingredient];
            }
        }
        
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
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView registerClass:[IngredientsKeyboardAccessoryCell class] forCellWithReuseIdentifier:kCellId];
}

- (NSArray *)allUnitOfMeasureOptions {
    return self.keyboardIngredients;
}

- (BOOL)isUnitForMeasure:(NSString *)measure {
    NSDictionary *ingredient = [self.ingredientsLookup valueForKey:measure];
    return [[ingredient valueForKey:@"Unit"] boolValue];
}

- (BOOL)unitOfMeasure:(NSString *)measure isEqualToMeasure:(NSString *)anotherMeasure {
    return ([measure isEqualToString:anotherMeasure]
            && ([self isUnitForMeasure:measure] == [self isUnitForMeasure:anotherMeasure]));
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    UIEdgeInsets insets = (UIEdgeInsets) { 10.0, 5.0, 6.0, 12.0 };
    NSInteger numSections = [self.collectionView numberOfSections];
    if (section == numSections - 1) {
        insets.right = 5.0; // Ends with a 7pt.
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
    return 6.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [IngredientsKeyboardAccessoryCell cellSize];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *ingredientsInfo = [self.keyboardIngredientsInfo objectAtIndex:indexPath.section];
    NSDictionary *ingredient = [ingredientsInfo objectAtIndex:indexPath.item];
    NSString *text = [ingredient valueForKey:@"Value"];
    BOOL unit = [[ingredient valueForKey:@"Unit"] boolValue];

    [self.delegate ingredientsKeyboardAccessorySelectedValue:text unit:unit];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.keyboardIngredientsInfo count];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [[self.keyboardIngredientsInfo objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    IngredientsKeyboardAccessoryCell *cell = (IngredientsKeyboardAccessoryCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    
    NSArray *ingredientsInfo = [self.keyboardIngredientsInfo objectAtIndex:indexPath.section];
    NSDictionary *ingredient = [ingredientsInfo objectAtIndex:indexPath.item];
    [cell configureText:[ingredient valueForKey:@"Value"]];
    
    return cell;
}

@end
