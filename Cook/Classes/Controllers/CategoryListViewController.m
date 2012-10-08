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

@interface CategoryListViewController ()
@end

@implementation CategoryListViewController

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
    Category *categorySelected = [self.categories objectAtIndex:indexPath.row];
    [self.delegate didSelectCategory:categorySelected];
}

#pragma mark - Private methods
@end
