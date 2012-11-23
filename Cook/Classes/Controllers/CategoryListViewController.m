//
//  CategoryListViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryListViewController.h"
#import "CategoryListCell.h"

#define kCellReuseIdentifier    @"CategoryListCell"
#define kCategoryLabelFont      [UIFont systemFontOfSize:14.0f]
@interface CategoryListViewController ()
@end

@implementation CategoryListViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IUCollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.categories count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    Category *category = [self.categories objectAtIndex:indexPath.row];
    [cell configure:category];
    
    return cell;
    
}


#pragma mark - IUCollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryListCell *cell = (CategoryListCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell selectCell:YES];
    Category *categorySelected = [self.categories objectAtIndex:indexPath.row];
    [self.delegate didSelectCategory:categorySelected];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryListCell *cell = (CategoryListCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell selectCell:NO];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Category *category = [self.categories objectAtIndex:indexPath.row];
    NSString *tester = [category.name uppercaseString];
    CGSize labelSize = [tester sizeWithFont:kCategoryLabelFont];
    return CGSizeMake(labelSize.width, [CategoryListCell cellSize].height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}

#pragma mark - Private methods
@end
