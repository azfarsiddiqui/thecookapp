//
//  CategoryListViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryListViewController.h"
#import "CategoryListCell.h"
#import "NSArray+Enumerable.h"

#define kCellReuseIdentifier    @"CategoryListCell"
#define kCategoryLabelFont      [UIFont systemFontOfSize:14.0f]
@interface CategoryListViewController ()
@property(nonatomic,strong) IBOutlet UICollectionView *collectionView;
@property(nonatomic,strong) IBOutlet UIImageView *imageView;
@property(nonatomic,strong) Category *selectedCategory;
@end

@implementation CategoryListViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self style];
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

-(void)show:(BOOL)show
{
    self.view.hidden = !show;
}

-(void)selectCategoryWithName:(NSString *)categoryName
{
    NSUInteger categoryIndex = NSNotFound;
    if (categoryName) {
        for (int i = 0; i < [self.categories count]; i++) {
            Category *category = [self.categories objectAtIndex:i];
            if ([categoryName isEqualToString:category.name]) {
                categoryIndex = i;
                break;
            }
        }
        if (categoryIndex!= NSNotFound) {
            self.selectedCategory = [self.categories objectAtIndex:categoryIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:categoryIndex inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }
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
    [cell configure:category asSelected:[category isEqual:self.selectedCategory]];
    
    return cell;
    
}


#pragma mark - IUCollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryListCell *cell = (CategoryListCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell selectCell:YES];
    Category *categorySelected = [self.categories objectAtIndex:indexPath.row];
    self.selectedCategory = categorySelected;
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

-(void) style
{
    self.collectionView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f);
    UIImage *cappedImage = [[UIImage imageNamed:@"cook_editrecipe_categorybg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 34.0f, 0.0f, 34.0f)];
    self.imageView.image = cappedImage;
}

@end
