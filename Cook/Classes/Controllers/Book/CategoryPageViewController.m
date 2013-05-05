//
//  CategoryPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryPageViewController.h"
#import "CKCategory.h"
#import "Theme.h"
#import "ContentsTableViewCell.h"

@interface CategoryPageViewController ()
@property (nonatomic, strong) UIImageView *categoryImageView;
@end

@implementation CategoryPageViewController

#define kCategoryFont   [Theme defaultBoldFontWithSize:64.0]
#define kLabelOffset    CGPointMake(624.0, 190.0)
#define kRecipeCellId   @"kRecipeCellId"
#define kTableInsets    UIEdgeInsetsMake(50.0, 0.0, 0.0, 100.0)

- (void)initPageView {
    [super initPageView];
    [self initCategoryImageView];
}

-(void)setSectionName:(NSString *)sectionName
{
    [super setSectionName:sectionName];

    // Update category image.
    UIImage *categoryImage = [CKCategory bookImageForCategory:self.sectionName];
    if (categoryImage) {
        self.categoryImageView.frame = CGRectMake(self.view.bounds.origin.x,
                                                  self.view.bounds.origin.y,
                                                  categoryImage.size.width,
                                                  categoryImage.size.height);
        self.categoryImageView.image = categoryImage;
    }
    
    self.recipes = [self.dataSource recipesForSection:self.sectionName];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.row];
    UITableViewCell *cell = [self cellForTableView:tableView indexPath:indexPath];
    cell.textLabel.text = [recipe.name uppercaseString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.dataSource pageNumForRecipeAtCategoryIndex:indexPath.row forCategoryName:self.sectionName]];
    return cell;
}
#pragma mark - Private methods

- (void)initCategoryImageView {
    UIImageView *categoryImageView = [[UIImageView alloc] initWithImage:nil];
    [self.view insertSubview:categoryImageView atIndex:0];
    self.categoryImageView = categoryImageView;
}

@end
