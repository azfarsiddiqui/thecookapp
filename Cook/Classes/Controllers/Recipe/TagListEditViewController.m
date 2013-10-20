//
//  TagListEditViewController.m
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "TagListEditViewController.h"
#import "TagListCell.h"
#import "CKRecipeTag.h"

@interface TagListEditViewController ()

@property (nonatomic, strong) NSMutableArray *selectedItems;

@end

@implementation TagListEditViewController

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate allItems:(NSArray *)allItems selectedItems:(NSArray *)selectedItems editingHelper:(CKEditingViewHelper *)editingHelper
{
    self = [super initWithEditView:editView delegate:delegate items:allItems
                     editingHelper:editingHelper white:YES title:@"TAGS"];
    if (self) {
        self.selectedIndexNumber = @(-1);
        self.selectedItems = [NSMutableArray arrayWithArray:selectedItems];
        self.allowMultipleSelection = YES;
    }
    return self;
}

#pragma mark - Override methods

- (Class)classForListCell {
    return [TagListCell class];
}

- (id)updatedValue {
    return self.selectedItems;
}

- (BOOL)isEmptyForValue:(CKRecipeTag *)currentValue {
    return ![self.selectedItems containsObject:currentValue];
}

- (void)itemsDidShow:(BOOL)show
{
    [super itemsDidShow:show];
    if (show)
    {
        [self.items enumerateObjectsUsingBlock:^(CKRecipeTag *obj, NSUInteger idx, BOOL *stop) {
            if ([self.selectedItems containsObject:obj])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                });
            }
        }];
    }
}

- (void)configureCell:(CKListCell *)cell indexPath:(NSIndexPath *)indexPath {
    if (self.itemsLoaded) {
        cell.allowSelection = YES;
        
        if ([self.items count] > 0) {
            CKRecipeTag *recipeTag = [self.items objectAtIndex:indexPath.row];
            // Loading actual item cells.
            [cell configureValue:[self.items objectAtIndex:indexPath.item]
                        selected:[self.selectedItems containsObject:recipeTag]];
        }
    } else {
        // This is the placeholder cell just prior to animating actual cells.
        cell.allowSelection = NO;
        [cell configureValue:nil selected:NO];
    }
}

#pragma mark - UICollectionView delegate override

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //Select Cell in UI
    
    //Add to selected array if doesn't already exist
    if (![self.selectedItems containsObject:[self.items objectAtIndex:indexPath.row]])
    {
        CKRecipeTag *selectedTag = [self.items objectAtIndex:indexPath.row];
        if (![self.selectedItems containsObject:selectedTag])
            [self.selectedItems addObject:selectedTag];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipeTag *selectedTag = [self.items objectAtIndex:indexPath.row];
    if ([self.selectedItems containsObject:selectedTag])
        [self.selectedItems removeObject:[self.items objectAtIndex:indexPath.row]];
}

#pragma mark - TagList original methods

- (void)updateCellsWithTagArray:(NSArray *)allItems
{
    self.items = [NSMutableArray arrayWithArray:allItems];
    [self.collectionView reloadData];
}

@end
