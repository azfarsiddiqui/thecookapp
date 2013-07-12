//
//  BookPagingStackViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationStackViewController.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "CKCategory.h"
#import "BookPagingStackLayout.h"
#import "ParsePhotoStore.h"
#import "BookProfileViewController.h"
#import "BookIndexListViewController.h"
#import "BookHeaderView.h"
#import "MRCEnumerable.h"
#import "CKBookCover.h"

@interface BookNavigationStackViewController () <BookPagingStackLayoutDelegate, BookIndexListViewControllerDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *categoryHeaderViews;
@property (nonatomic, assign) BOOL justOpened;

@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) BookProfileViewController *profileViewController;
@property (nonatomic, strong) BookIndexListViewController *indexViewController;

@end

@implementation BookNavigationStackViewController

#define kCellId             @"CellId"
#define kProfileSection     0
#define kIndexSection       1
#define kProfileCellId      @"ProfileCellId"
#define kIndexCellId        @"IndexCellId"
#define kCategoryCellId     @"CategoryCellId"
#define kHeaderId           @"HeaderId"

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookPagingStackLayout alloc] initWithDelegate:self]]) {
        self.delegate = delegate;
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.profileViewController = [[BookProfileViewController alloc] initWithBook:book];
        self.indexViewController = [[BookIndexListViewController alloc] initWithBook:book delegate:self];
    }
    return self;
}

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[BookPagingStackLayout alloc] initWithDelegate:self]]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // Mark as just opened.
    self.justOpened = YES;
    
    [self initBookOutlineView];
    [self initCollectionView];
    [self loadData];
}

- (void)updateWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with recipe [%@][%@]", recipe.name, recipe.category);
}

- (void)setActive:(BOOL)active {
    if (active) {
        
        // Unselect cells.
        NSArray *selectedIndexPaths = [self.collectionView indexPathsForSelectedItems];
        if ([selectedIndexPaths count] > 0) {
            NSIndexPath *selectedIndexPath = [selectedIndexPaths objectAtIndex:0];
            UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:selectedIndexPath];
            [selectedCell setSelected:NO];
        }
        
    } else {
        
    }
}

#pragma mark - BookIndexListViewControllerDelegate methods

- (void)bookIndexSelectedCategory:(NSString *)category {
}

- (void)bookIndexAddRecipeRequested {
}

- (NSArray *)bookIndexRecipesForCategory:(NSString *)category {
    return nil;
}

#pragma mark - BookPagingStackLayoutDelegate methods

- (void)stackPagingLayoutDidFinish {
    
    if (self.justOpened) {
        
        // Start on page 1.
        [self.collectionView setContentOffset:(CGPoint){ kIndexSection * self.collectionView.bounds.size.width, 0.0 }
                                     animated:NO];
        self.justOpened = NO;
    }
}

- (BookPagingStackLayoutType)stackPagingLayoutType {
//    return BookPagingStackLayoutTypeSlideOneWay;
    return BookPagingStackLayoutTypeSlideOneWayScale;
//    return BookPagingStackLayoutTypeSlideBothWays;
}


- (NSInteger)stackCategoryStartSection {
    return kIndexSection + 1;
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numSections = 0;
    
    numSections += 1;                       // Profile page.
    numSections += 1;                       // Index page.
    numSections += [self.categories count]; // Category pages.
    
    return numSections;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    
    if (section == kProfileSection) {
        numItems = 1;
    } else if (section == kIndexSection) {
        numItems = 1;
    } else {
        numItems = [self.categories count];
    }
    
    return numItems;
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                        withReuseIdentifier:kHeaderId
                                                               forIndexPath:indexPath];
        BookHeaderView *categoryHeaderView = (BookHeaderView *)headerView;
        
        // Configure the category name.
        CKCategory *category = [self.categories objectAtIndex:indexPath.section - [self stackCategoryStartSection]];
        [categoryHeaderView  configureTitle:category.name];
    }
    
    return headerView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (indexPath.section == kProfileSection) {
        cell = [self profileCellAtIndexPath:indexPath];
    } else if (indexPath.section == kIndexSection) {
        cell = [self indexCellAtIndexPath:indexPath];
    } else {
        cell = [self categoryCellAtIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - Private methods

- (void)initBookOutlineView {
    UIImage *outlineImage = [CKBookCover outlineImageForCover:self.book.cover];
    UIImageView *bookOutlineView = [[UIImageView alloc] initWithImage:outlineImage];
    bookOutlineView.frame = CGRectMake(-26.0, -8.0, bookOutlineView.frame.size.width, bookOutlineView.frame.size.height);
    [self.view addSubview:bookOutlineView];
    [self.view sendSubviewToBack:bookOutlineView];
    
    // Decorations.
    UIImageView *bookOutlineOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay"]];
    bookOutlineOverlayView.frame = CGRectMake(-36.0, -18.0, bookOutlineOverlayView.frame.size.width, bookOutlineOverlayView.frame.size.height);
    [bookOutlineView addSubview:bookOutlineOverlayView];
    UIImageView *bookBindOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge_overlay_bind.png"]];
    bookBindOverlayView.frame = CGRectMake(-26.0, -18.0, bookBindOverlayView.frame.size.width, bookBindOverlayView.frame.size.height);
    [bookOutlineView addSubview:bookBindOverlayView];
}

- (void)initCollectionView {
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    
    // Headers
    [self.collectionView registerClass:[BookHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kHeaderId];
    
    // Profile, Index, Category.
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kProfileCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kIndexCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCategoryCellId];
}

- (void)loadData {
    DLog();
    
    // Fetch all categories for the book.
    [self.book fetchCategoriesSuccess:^(NSArray *categories) {
        self.categories = [NSMutableArray arrayWithArray:categories];
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
    
}

- (UICollectionViewCell *)profileCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *profileCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellId forIndexPath:indexPath];;
    if (!self.profileViewController.view.superview) {
        self.profileViewController.view.frame = profileCell.contentView.bounds;
        [profileCell.contentView addSubview:self.profileViewController.view];
    }
    return profileCell;
}

- (UICollectionViewCell *)indexCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *indexCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kIndexCellId forIndexPath:indexPath];
    if (!self.indexViewController.view.superview) {
        self.indexViewController.view.frame = indexCell.contentView.bounds;
        [indexCell.contentView addSubview:self.indexViewController.view];
    }
    return indexCell;
}

- (UICollectionViewCell *)categoryCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *categoryCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCategoryCellId forIndexPath:indexPath];
    categoryCell.contentView.backgroundColor = [UIColor lightGrayColor];
    return categoryCell;
}


@end
