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
#import "Theme.h"
#import "TagLayout.h"
#import "NSArray+Enumerable.h"

@interface TagListEditViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableArray *selectedItems;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *mealTypeCollectionView;
@property (nonatomic, strong) UICollectionView *cookTypeCollectionView;
@property (nonatomic, strong) UICollectionView *allergyTypeCollectionView;
@property (nonatomic, strong) UICollectionView *foodTypeCollectionView;
@property (nonatomic, strong) UILabel *titleCountLabel;

@end

@implementation TagListEditViewController

#define kTagCellID          @"TagCell"
#define kTagSectionHeadID   @"TagSectionHeader"
#define kTagSectionFootID   @"TagSectionFooter"
#define kSize               CGSizeMake(884.0, 678.0)
#define kContentInsets      UIEdgeInsetsMake(45.0, -20.0, 40.0, -20.0)
#define kSectionHeadWidth   80.0
#define kSectionFootWidth   40.0

//top, left, bottom, right
- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate selectedItems:(NSArray *)selectedItems editingHelper:(CKEditingViewHelper *)editingHelper
{
    self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:YES];
    if (self) {
        self.selectedItems = [NSMutableArray arrayWithArray:selectedItems];
        [CKRecipeTag tagListWithSuccess:^(NSArray *tags) {
            self.items = [tags sortedArrayUsingComparator:^NSComparisonResult(CKRecipeTag *obj1, CKRecipeTag *obj2) {
                //Ordering by category and orderIndex
                return (obj1.categoryIndex * 1000 + obj1.orderIndex) < (obj2.categoryIndex * 1000 + obj2.orderIndex) ? NSOrderedAscending : NSOrderedDescending;
            }];
            [self reloadCollectionViews];
        } failure:^(NSError *error) {
            //Show error message and dismiss
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [self dismissEditView];
        }];
    }
    return self;
}

- (void)reloadCollectionViews {
    [self.mealTypeCollectionView reloadData];
    [self.cookTypeCollectionView reloadData];
    [self.allergyTypeCollectionView reloadData];
    [self.foodTypeCollectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.mealTypeCollectionView];
    [self.containerView addSubview:self.cookTypeCollectionView];
    [self.containerView addSubview:self.allergyTypeCollectionView];
    [self.containerView addSubview:self.foodTypeCollectionView];
    
    UIView *titleAlignView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.containerView addSubview:titleAlignView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [Theme editServesTitleFont];
    titleLabel.textColor = [Theme editServesTitleColour];
    titleLabel.text = @"TAGS";
    [titleAlignView addSubview:titleLabel];
    
    self.titleCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleCountLabel.font = [Theme editServesTitleFont];
    self.titleCountLabel.textColor = [UIColor colorWithRed:0.620 green:0.620 blue:0.616 alpha:1.000];
    self.titleCountLabel.text = [NSString stringWithFormat:@"%i", [self.selectedItems count]];
    [titleAlignView addSubview:self.titleCountLabel];
    
    // HR
    UIView *line1 = [self generateLine];
    UIView *line2 = [self generateLine];
    UIView *line3 = [self generateLine];
    [self.containerView addSubview:line1];
    [self.containerView addSubview:line2];
    [self.containerView addSubview:line3];
    
//    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mealTypeCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cookTypeCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.allergyTypeCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.foodTypeCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mealTypeCollectionView.clipsToBounds = NO;
    self.cookTypeCollectionView.clipsToBounds = NO;
    self.allergyTypeCollectionView.clipsToBounds = NO;
    self.foodTypeCollectionView.clipsToBounds = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleAlignView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    line1.translatesAutoresizingMaskIntoConstraints = NO;
    line2.translatesAutoresizingMaskIntoConstraints = NO;
    line3.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{@"mealCollection":self.mealTypeCollectionView,
                            @"cookCollection":self.cookTypeCollectionView,
                            @"allergyCollection":self.allergyTypeCollectionView,
                            @"foodCollection":self.foodTypeCollectionView,
                            @"titleLabel":titleLabel,
                            @"titleAlign":titleAlignView,
                            @"titleCount":self.titleCountLabel,
                            @"line1":line1,
                            @"line2":line2,
                            @"line3":line3};
    NSDictionary *metrics = @{@"leftInset":[NSNumber numberWithFloat:kContentInsets.left],
                              @"rightInset":[NSNumber numberWithFloat:kContentInsets.right],
                              @"topInset":[NSNumber numberWithFloat:kContentInsets.top],
                              @"bottomInset":[NSNumber numberWithFloat:kContentInsets.bottom],
                              @"collectionHeight":[NSNumber numberWithFloat:kItemHeight],
                              @"lineBottomSpacing":@15.0,
                              @"lineTopSpacing":@5.0,
                              @"lineHeight":@1};
    [titleAlignView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[titleLabel]-10-[titleCount]-|" options:NSLayoutFormatAlignAllTop metrics:0 views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=0)-[titleAlign]-(>=0)-|" options:NSLayoutFormatAlignAllTop metrics:0 views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[mealCollection]-|" options:0 metrics:metrics views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(leftInset)-[line1]-(rightInset)-|" options:0 metrics:metrics views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[cookCollection]-|" options:0 metrics:metrics views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(leftInset)-[line2]-(rightInset)-|" options:0 metrics:metrics views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[allergyCollection]-|" options:0 metrics:metrics views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(leftInset)-[line3]-(rightInset)-|" options:0 metrics:metrics views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[foodCollection]-|" options:0 metrics:metrics views:views]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topInset)-[titleAlign(30)]-30-[mealCollection(collectionHeight)]-(lineBottomSpacing)-[line1(lineHeight)]-(lineTopSpacing)-[cookCollection(collectionHeight)]-(lineBottomSpacing)-[line2(lineHeight)]-(lineTopSpacing)-[allergyCollection(collectionHeight)]-(lineBottomSpacing)-[line3(lineHeight)]-(lineTopSpacing)-[foodCollection(collectionHeight)]-(>=bottomInset)-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:titleAlignView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:line1
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.containerView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:line2
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:line3
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeCollectionView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.cookTypeCollectionView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.allergyTypeCollectionView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.f constant:0.f]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.foodTypeCollectionView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.f constant:0.f]];
}

- (UIView *)generateLine {
    UIView *hrLine = [[UIView alloc] initWithFrame:CGRectZero];
    hrLine.backgroundColor = [Theme dividerRuleColour];
    return hrLine;
}

- (UIView *)createTargetEditView {
    return self.containerView;
}

- (id)updatedValue {
    return self.selectedItems;
}

- (CGSize)availableSize {
    return CGSizeMake(self.containerView.bounds.size.width,
                      self.containerView.bounds.size.height);
}

- (BOOL)showSaveIcon {
    return YES;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

#pragma mark - UICollectionView datasource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    for (CKRecipeTag *obj in self.items) {
        if (obj.categoryIndex == [self categoryForCollectionView:collectionView]) {
            count++;
        }
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTagCellID forIndexPath:indexPath];
    
    //Get appropriate RecipeTag
    CKRecipeTag *recipeTag = [self recipeTagWithIndexPath:indexPath collectionView:collectionView];
    
    //Configure cell with RecipeTag
    if (recipeTag) {
        [cell configureTag:recipeTag];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionIdentifier = [kind isEqualToString:UICollectionElementKindSectionHeader] ? kTagSectionHeadID : kTagSectionFootID;
    UICollectionReusableView *sectionHead = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:sectionIdentifier forIndexPath:indexPath];
    sectionHead.backgroundColor = [UIColor clearColor];
    return sectionHead;
}

//Adds padding to the front of the row of cells to make sure first one isn't faded
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat tagWidth = self.mealTypeCollectionView.frame.size.width;
    CGFloat cellSumWidth = (kItemWidth + 10) * [collectionView numberOfItemsInSection:section];
    if (cellSumWidth > tagWidth)
        return CGSizeMake(kSectionHeadWidth, 0);
    else {
        CGFloat sectionWidth = tagWidth/2 - cellSumWidth/2;
        return CGSizeMake(sectionWidth > kSectionHeadWidth ? sectionWidth : kSectionHeadWidth, 0);
    }
}

//Adds padding to the end of the row of cells so that the last cell can be selected without fading
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(kSectionFootWidth, 0);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UICollectionView delegate 

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //Select Cell in UI
    TagListCell *listCell = (TagListCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [listCell setSelected:!listCell.isSelected];
    
    //Add to selected array if doesn't already exist
    CKRecipeTag *tag = [self recipeTagWithIndexPath:indexPath collectionView:collectionView];
    if (tag && ![self.selectedItems containsObject:tag])
    {
        if (![self.selectedItems containsObject:tag])
            [self.selectedItems addObject:tag];
    }
    self.titleCountLabel.text = [NSString stringWithFormat:@"%i", [self.selectedItems count]];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKRecipeTag *selectedTag = [self recipeTagWithIndexPath:indexPath collectionView:collectionView];
    if ([self.selectedItems containsObject:selectedTag])
        [self.selectedItems removeObject:selectedTag];
//    [self.selectedItems enumerateObjectsUsingBlock:^(CKRecipeTag *obj, NSUInteger idx, BOOL *stop) {
//        DLog(@"Selected Name: %@|%@, PArsed Name: %@|%@", selectedTag.displayName, selectedTag.objectId, obj.displayName, obj.objectId);
//        if ([obj.objectId isEqual:selectedTag.objectId]) {
//            [self.selectedItems removeObject:obj];
//            return;
//        }
//    }];
    self.titleCountLabel.text = [NSString stringWithFormat:@"%i", [self.selectedItems count]];
}

#pragma mark - Properties

- (UIView *)containerView {
    if (!_containerView) {
        //TODO: BUG IN ROTATE VIEW FRAME, hardcoding get around it.
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(floorf((1024 - kSize.width) / 2.0),
                                                                 floorf((768 - kSize.height) / 2.0),
                                                                 kSize.width,
                                                                 kSize.height)];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (UICollectionView *)mealTypeCollectionView {
    if (!_mealTypeCollectionView) {
        _mealTypeCollectionView = [self generateCollectionView];
    }
    return _mealTypeCollectionView;
}

- (UICollectionView *)cookTypeCollectionView {
    if (!_cookTypeCollectionView) {
        _cookTypeCollectionView = [self generateCollectionView];
    }
    return _cookTypeCollectionView;
}

- (UICollectionView *)allergyTypeCollectionView {
    if (!_allergyTypeCollectionView) {
        _allergyTypeCollectionView = [self generateCollectionView];
    }
    return _allergyTypeCollectionView;
}

- (UICollectionView *)foodTypeCollectionView {
    if (!_foodTypeCollectionView) {
        _foodTypeCollectionView = [self generateCollectionView];
    }
    return _foodTypeCollectionView;
}

#pragma mark - Private methods


- (UICollectionView *)generateCollectionView {
    TagLayout *flowLayout = [[TagLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    flowLayout.sectionInset = UIEdgeInsetsZero;
    //Header reference size too
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.bounces = YES;
    collectionView.alwaysBounceHorizontal = YES;
    collectionView.backgroundColor = [UIColor clearColor];
//    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.allowsMultipleSelection = YES;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [collectionView registerClass:[TagListCell class] forCellWithReuseIdentifier:kTagCellID];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kTagSectionHeadID];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kTagSectionFootID];
    return collectionView;
}

- (NSInteger)categoryForCollectionView:(UICollectionView *)collectionView {
    if ([collectionView isEqual:self.mealTypeCollectionView]) {
        return 0;
    } else if ([collectionView isEqual:self.cookTypeCollectionView]) {
        return 1;
    } else if ([collectionView isEqual:self.allergyTypeCollectionView]) {
        return 2;
    } else if ([collectionView isEqual:self.foodTypeCollectionView]) {
        return 3;
    } else {
//        [NSException raise:@"Invalid Collection" format:@"Invalid collectionview match"];
        return -1; //Shouldn't hit this
    }
}

- (CKRecipeTag *)recipeTagWithIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView {
    NSInteger categoryIndex = [self categoryForCollectionView:collectionView];
    NSInteger orderIndex = indexPath.item;
    for (CKRecipeTag *recipeTag in self.items) {
        if (recipeTag.categoryIndex == categoryIndex && recipeTag.orderIndex == orderIndex)
            return recipeTag;
    }
//    [NSException raise:@"Invalid recipe" format:@"Indexed do not match a recipe"];
    return nil; //Error, shouldn't hit this
}




@end
