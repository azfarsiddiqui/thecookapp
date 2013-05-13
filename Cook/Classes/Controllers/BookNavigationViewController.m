//
//  BookNavigationViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationViewController.h"
#import "BookNavigationLayout.h"
#import "BookRecipeCollectionViewCell.h"
#import "BookCategoryView.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "CKCategory.h"
#import "MRCEnumerable.h"
#import "ViewHelper.h"
#import "ParsePhotoStore.h"
#import "BookProfileViewController.h"
#import "BookIndexViewController.h"
#import "Theme.h"
#import "BookTitleViewController.h"
#import "EventHelper.h"
#import "CKBookPagingView.h"

@interface BookNavigationViewController () <BookNavigationDataSource, BookNavigationLayoutDelegate,
    BookIndexViewControllerDelegate, BookTitleViewControllerDelegate>

@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *contentsButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) CKBookPagingView *bookPagingView;

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *actionedRecipe;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) ParsePhotoStore *photoStore;

@property (nonatomic, strong) BookProfileViewController *profileViewController;
@property (nonatomic, strong) BookTitleViewController *titleViewController;
@property (nonatomic, strong) BookIndexViewController *indexViewController;

@property (nonatomic, strong) NSString *selectedCategoryName;
@property (nonatomic, strong) NSString *currentCategoryName;
@property (nonatomic, assign) BOOL justOpened;
@property (nonatomic, assign) BOOL editMode;

@property (copy) BookNavigationUpdatedBlock bookUpdatedBlock;

@end

@implementation BookNavigationViewController

#define kRecipeCellId       @"RecipeCellId"
#define kCategoryHeaderId   @"CategoryHeaderId"
#define kProfileCellId      @"ProfileCellId"
#define kTitleCellId        @"TitleCellId"
#define kActivityCellId     @"ActivityCellId"
#define kNavTopLeftOffset   CGPointMake(20.0, 15.0)
#define kNavTitleOffset     CGPointMake(20.0, 28.0)

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookNavigationLayout alloc] initWithDataSource:self
                                                                                           delegate:self]]) {
        self.delegate = delegate;
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.profileViewController = [[BookProfileViewController alloc] initWithBook:book];
        self.titleViewController = [[BookTitleViewController alloc] initWithBook:book delegate:self];
        self.indexViewController = [[BookIndexViewController alloc] initWithBook:book delegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self initBookOutlineView];
    [self initCollectionView];
    [self initBookPagingView];
    [self loadData];
    
    // Mark as just opened.
    self.justOpened = YES;
    
    // Register for editing event.
    [EventHelper registerEditMode:self selector:@selector(editModeReceived:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateNavigationButtons];
}

- (void)updateWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    DLog(@"Updating layout with recipe [%@][%@]", recipe.name, recipe.category);
    
    // Check if this was a new recipe, in which case add it to the recipes list
    if (![self.recipes detect:^BOOL(CKRecipe *existingRecipe) {
        return [existingRecipe.objectId isEqualToString:recipe.objectId];
    }]) {
        
        // Add to the list of recipes.
        [self.recipes addObject:recipe];
    }
    
    // Remember the recipe that was actioned.
    self.actionedRecipe = recipe;
    
    // Check if we need to clear deep linking.
    NSString *categoryName = self.actionedRecipe.category.name;
    if (![categoryName isEqualToString:self.selectedCategoryName]) {
        self.selectedCategoryName = nil;
    }
    
    // Remember the block, which will be invoked in the prepareLayoutDidFinish method after layout completes.
    self.bookUpdatedBlock = completion;

    // Load recipes to rebuild the layout.
    [self loadRecipes];
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

#pragma mark - BookNavigationDataSource methods

- (NSUInteger)bookNavigationContentStartSection {
    return [self recipeSection];
}

- (NSUInteger)bookNavigationLayoutNumColumns {
    return 3;
}

- (NSUInteger)bookNavigationLayoutColumnWidthForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

#pragma mark - BookNavigationLayoutDelegate methods

- (void)prepareLayoutDidFinish {
    
    if (self.bookUpdatedBlock != nil) {
        
        // If we have an actioned recipe, then navigate there.
        if (self.actionedRecipe) {
            
            // Get the index of the category within the book.
            NSString *categoryName = self.actionedRecipe.category.name;
            NSInteger categoryIndex = [self.categoryNames indexOfObject:categoryName];
            
            // Get the index of the recipe within the category.
            NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
            NSInteger recipeIndex = [categoryRecipes findIndexWithBlock:^BOOL(CKRecipe *recipe) {
                return [recipe.objectId isEqualToString:self.actionedRecipe.objectId];
            }];
            
            // Figure out the section to go to.
            NSInteger bookSection = [self bookNavigationContentStartSection];
            if (![self isCategoryDeepLinked]) {
                bookSection += categoryIndex;
            }
            
            NSIndexPath *actionedIndexPath = [NSIndexPath indexPathForItem:recipeIndex inSection:bookSection];
            
            // Now deep link there.
            BookNavigationLayout *layout = (BookNavigationLayout *)self.collectionView.collectionViewLayout;
            CGFloat pageOffset = [layout pageOffsetForIndexPath:actionedIndexPath];
            [self.collectionView setContentOffset:CGPointMake(pageOffset, 0.0) animated:YES];
        }
        
        // Invoked from recipe edit/added block.
        self.bookUpdatedBlock();
        self.bookUpdatedBlock = nil;
        
    } else if ([self isCategoryDeepLinked]) {
        
        [self.collectionView setContentOffset:CGPointMake([self recipeSection] * self.collectionView.bounds.size.width,
                                                          0.0)
                                     animated:YES];
    } else if (self.justOpened) {
        
        // Start on page 1.
        [self.collectionView setContentOffset:CGPointMake([self titleSection] * self.collectionView.bounds.size.width,
                                                          0.0)
                                     animated:NO];
        self.justOpened = NO;
    }
    
    // Update book paging.
    BookNavigationLayout *layout = (BookNavigationLayout *)self.collectionView.collectionViewLayout;
    NSInteger numRecipePages = [layout numberOfPages];
    [self updateBookPagingViewWithNumPages:numRecipePages];
}

#pragma mark - BookIndexViewControllerDelegate methods

- (void)bookIndexSelectedCategory:(NSString *)category {
    
    // Selected a category, run-relayout
    self.selectedCategoryName = category;
    
    // Invalidate the current layout for deep-linking.
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

- (void)bookIndexAddRecipeRequested {
    [self.delegate bookNavigationControllerAddRecipeRequested];
}

- (NSArray *)bookIndexRecipesForCategory:(NSString *)category {
    return [self.categoryRecipes objectForKey:category];
}

#pragma mark - BookTitleViewControllerDelegate methods

- (void)bookTitleViewControllerSelectedRecipe:(CKRecipe *)recipe {
    [self.delegate bookNavigationControllerRecipeRequested:recipe];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateNavTitle];
    [self updateBookPagingViewAndDots:NO];
}

// To detect returning from category deep-linking.
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // Reset category after returning to the contents screen after deep-linking.
    CGFloat contentsPageOffset = [self indexSection] * scrollView.bounds.size.width;
    if (scrollView.contentOffset.x == contentsPageOffset && [self isCategoryDeepLinked]) {
        self.selectedCategoryName = nil;
        
        // Invalidate the current layout for normal book mode.
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView reloadData];
    }
    
    [self updateBookPagingViewAndDots:YES];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    if (indexPath.section >= contentStartSection) {
        
        NSInteger categorySection = indexPath.section - contentStartSection;
        NSString *categoryName = [self selectedCategoryNameOrForSection:categorySection];
        NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
        CKRecipe *recipe = [categoryRecipes objectAtIndex:indexPath.item];
        
        [self.delegate bookNavigationControllerRecipeRequested:recipe];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    if (indexPath.section >= contentStartSection) {
        
        // Clears the image on disappear.
        if ([cell isKindOfClass:[BookRecipeCollectionViewCell class]]) {
            BookRecipeCollectionViewCell *recipeCell = (BookRecipeCollectionViewCell *)cell;
            [recipeCell configureImage:nil];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
      forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    if (indexPath.section >= contentStartSection) {
        
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            // Clears the image on disappear.
            BookCategoryView *recipeCell = (BookCategoryView *)view;
            [recipeCell configureImage:nil];
        }
    }
    
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger numSections = 0;
    
    // Info pages
    numSections += [self bookNavigationContentStartSection];
    
    // Categories
    if ([self isCategoryDeepLinked]) {
        numSections += 1;   // Only selected a category to deep link to.
    } else {
        numSections += [self.categoryNames count];  // All categories.
    }
    
    return numSections;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    
    if (section >= contentStartSection) {
        
        NSInteger categorySection = section - contentStartSection;
        NSString *categoryName = [self selectedCategoryNameOrForSection:categorySection];
        NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
        numItems = [categoryRecipes count];
        
    } else {
        
        // Individual pages for non-recipes sections.
        numItems = 1;
    }
    
    return numItems;
}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = nil;
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    
    if (indexPath.section >= contentStartSection) {
        
        NSInteger categorySection = indexPath.section - contentStartSection;
        
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                            withReuseIdentifier:kCategoryHeaderId
                                                                   forIndexPath:indexPath];
            BookCategoryView *categoryHeaderView = (BookCategoryView *)headerView;
            
            // Configure the category name.
            NSString *categoryName = [self selectedCategoryNameOrForSection:categorySection];
            [categoryHeaderView configureCategoryName:categoryName];
            
            // Populate highlighted recipe
            CKRecipe *highlightRecipe = [self highlightRecipeForCategory:categoryName];
            
            // Configure image.
            [self configureImageForHeaderView:categoryHeaderView recipe:highlightRecipe indexPath:indexPath];
        }
    }
    
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (indexPath.section == [self profileSection]) {
        cell = [self profileCellAtIndexPath:indexPath];
    } else if (indexPath.section == [self titleSection]) {
        cell = [self titleCellAtIndexPath:indexPath];
    } else if (indexPath.section == [self indexSection]) {
        cell = [self indexCellAtIndexPath:indexPath];
    } else if (indexPath.section >= [self recipeSection]) {
        cell = [self recipeCellAtIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark - NewRecipeViewDelegate methods

- (void)closeRequested {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recipeCreated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, kNavTitleOffset.y, 0.0, 0.0)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [Theme bookNavigationTitleFont];
        _titleLabel.textColor = [Theme bookNavigationTitleColour];
        //        _titleLabel.hidden = YES;
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_close_gray.png"]
                                            target:self
                                          selector:@selector(closeTapped:)];
        _closeButton.frame = CGRectMake(kNavTopLeftOffset.x,
                                        kNavTopLeftOffset.y,
                                        _closeButton.frame.size.width,
                                        _closeButton.frame.size.height);
    }
    return _closeButton;
}

- (UIButton *)contentsButton {
    if (!_contentsButton) {
        _contentsButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_contents_gray.png"]
                                               target:self
                                             selector:@selector(contentsTapped:)];
        _contentsButton.frame = CGRectMake(self.closeButton.frame.origin.x + self.closeButton.frame.size.width,
                                           kNavTopLeftOffset.y,
                                           _contentsButton.frame.size.width,
                                           _contentsButton.frame.size.height);
    }
    return _contentsButton;
}

- (UIButton *)addButton {
    if (!_addButton && [self canAddRecipe]) {
        _addButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_btn_addrecipe.png"]
                                   selectedImage:[UIImage imageNamed:@"cook_book_btn_addrecipe_onpress.png"]
                                          target:self
                                        selector:@selector(addRecipeTapped)];
        _addButton.frame = CGRectMake(self.view.bounds.size.width - _addButton.frame.size.width - kNavTopLeftOffset.x,
                                      20.0,
                                      _addButton.frame.size.width,
                                      _addButton.frame.size.height);
        _addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _addButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_cancel.png"]
                                             target:self
                                           selector:@selector(cancelTapped:)];
        _cancelButton.frame = CGRectMake(kNavTopLeftOffset.x,
                                         kNavTopLeftOffset.y,
                                         _cancelButton.frame.size.width,
                                         _cancelButton.frame.size.height);
    }
    return _cancelButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                           target:self
                                         selector:@selector(saveTapped:)];
        _saveButton.frame = CGRectMake(self.view.bounds.size.width - _saveButton.frame.size.width - kNavTopLeftOffset.x,
                                       kNavTopLeftOffset.y,
                                       _saveButton.frame.size.width,
                                       _saveButton.frame.size.height);
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _saveButton;
}

#pragma mark - Private methods

- (void)initBookOutlineView {
    UIImageView *bookOutlineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_edge.png"]];
    bookOutlineView.frame = CGRectMake(-46.0, -26.0, bookOutlineView.frame.size.width, bookOutlineView.frame.size.height);
    [self.view addSubview:bookOutlineView];
    [self.view sendSubviewToBack:bookOutlineView];
}

- (void)updateNavigationButtons {
    if (self.editMode) {
        self.cancelButton.alpha = 0.0;
        self.saveButton.alpha = 0.0;
        [self.view addSubview:self.cancelButton];
        [self.view addSubview:self.saveButton];
    } else {
        self.closeButton.alpha = 0.0;
        self.contentsButton.alpha = 0.0;
        self.titleLabel.alpha = 0.0;
        self.addButton.alpha = 0.0;
        [self.view addSubview:self.titleLabel];
        [self.view addSubview:self.closeButton];
        [self.view addSubview:self.contentsButton];
        [self.view addSubview:self.addButton];
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.closeButton.alpha = self.editMode ? 0.0 : 1.0;
                         self.contentsButton.alpha = self.editMode ? 0.0 : 1.0;
                         self.titleLabel.alpha = self.editMode ? 0.0 : 1.0;
                         self.addButton.alpha = self.editMode ? 0.0 : 1.0;
                         self.cancelButton.alpha = self.editMode ? 1.0 : 0.0;
                         self.saveButton.alpha = self.editMode ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished)  {
                         if (self.editMode) {
                             [self.closeButton removeFromSuperview];
                             [self.contentsButton removeFromSuperview];
                             [self.titleLabel removeFromSuperview];
                             [self.addButton removeFromSuperview];
                         } else {
                             [self.cancelButton removeFromSuperview];
                             [self.saveButton removeFromSuperview];
                         }
                     }];
}

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cook_book_texture_bg.png"]];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    // Profile, Contents, Activity
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kProfileCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kTitleCellId];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityCellId];
    
    // Categories
    [self.collectionView registerClass:[BookCategoryView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCategoryHeaderId];
    [self.collectionView registerClass:[BookRecipeCollectionViewCell class] forCellWithReuseIdentifier:kRecipeCellId];
}

- (void)initBookPagingView {
    [self updateBookPagingViewWithNumPages:0];
}

- (void)updateBookPagingViewWithNumPages:(NSInteger)numPages {
    if (!self.bookPagingView) {
        CKBookPagingView *bookPagingView = [[CKBookPagingView alloc] initWithNumPages:numPages];
        bookPagingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.view addSubview:bookPagingView];
        self.bookPagingView = bookPagingView;
    } else {
        [self.bookPagingView setNumPages:numPages];
    }
    self.bookPagingView.frame = CGRectMake(floor((self.view.bounds.size.width - self.bookPagingView.frame.size.width) / 2.0),
                                           self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 20.0,
                                           self.bookPagingView.frame.size.width,
                                           self.bookPagingView.frame.size.height);
}

- (void)loadData {
    
    // Fetch all recipes for the book and partition them into their categories.
    [self.book fetchRecipesSuccess:^(NSArray *recipes) {
        
        self.recipes = [NSMutableArray arrayWithArray:recipes];
        [self loadRecipes];
        
        // Preload categories for edit/creation if it's my own book.
        if ([self.book isUserBookAuthor:[CKUser currentUser]]) {
            [self.book prefetchCategoriesInBackground];
        }
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (void)closeTapped:(id)sender {
    [self.delegate bookNavigationControllerCloseRequested];
}

- (void)contentsTapped:(id)sender {
    CGFloat contentsPageOffset = [self indexSection] * self.collectionView.bounds.size.width;
    [self.collectionView setContentOffset:CGPointMake(contentsPageOffset, 0.0) animated:YES];
}

- (void)configureImageForHeaderView:(BookCategoryView *)categoryHeaderView recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        
        CGSize imageSize = [categoryHeaderView imageSize];
        [self.photoStore imageForParseFile:[recipe imageFile]
                                      size:imageSize
                                 indexPath:indexPath
                                completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
            
                                    // Check that we have matching indexPaths as cells are re-used.
                                    if ([indexPath isEqual:completedIndexPath]) {
                                        [categoryHeaderView configureImage:image];
                                    }
        }];
        
    } else {
        [categoryHeaderView configureImage:nil];
    }
}

- (void)configureImageForRecipeCell:(BookRecipeCollectionViewCell *)recipeCell recipe:(CKRecipe *)recipe
                          indexPath:(NSIndexPath *)indexPath {
    
    if ([recipe hasPhotos]) {
        
        CGSize imageSize = [recipeCell imageSize];
        [self.photoStore imageForParseFile:[recipe imageFile]
                                      size:imageSize
                                 indexPath:indexPath
                                completion:^(NSIndexPath *completedIndexPath, UIImage *image) {
                                    
                                    // Check that we have matching indexPaths as cells are re-used.
                                    if ([indexPath isEqual:completedIndexPath]) {
                                        [recipeCell configureImage:image];
                                    }
                                }];
    }
}

- (UICollectionViewCell *)recipeCellAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    NSInteger categorySection = indexPath.section - contentStartSection;
    
    BookRecipeCollectionViewCell *recipeCell = (BookRecipeCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kRecipeCellId
                                                                                                                              forIndexPath:indexPath];;
    NSString *categoryName = [self selectedCategoryNameOrForSection:categorySection];
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    
    // Populate recipe.
    CKRecipe *recipe = [categoryRecipes objectAtIndex:indexPath.item];
    [recipeCell configureRecipe:recipe];
    
    // Configure image.
    [self configureImageForRecipeCell:recipeCell recipe:recipe indexPath:indexPath];
    
    return recipeCell;
}

- (UICollectionViewCell *)profileCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *profileCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellId forIndexPath:indexPath];;
    if (!self.profileViewController.view.superview) {
        self.profileViewController.view.frame = profileCell.contentView.bounds;
        [profileCell.contentView addSubview:self.profileViewController.view];
    }
    return profileCell;
}

- (UICollectionViewCell *)titleCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *contentsCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kTitleCellId forIndexPath:indexPath];
    if (!self.titleViewController.view.superview) {
        self.titleViewController.view.frame = contentsCell.contentView.bounds;
        [contentsCell.contentView addSubview:self.titleViewController.view];
    }
    return contentsCell;
}

- (UICollectionViewCell *)indexCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *contentsCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kActivityCellId forIndexPath:indexPath];
    if (!self.indexViewController.view.superview) {
        self.indexViewController.view.frame = contentsCell.contentView.bounds;
        [contentsCell.contentView addSubview:self.indexViewController.view];
    }
    return contentsCell;
}

- (NSArray *)recipesWithPhotosInCategory:(NSString *)categoryName {
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    return [categoryRecipes select:^BOOL(CKRecipe *recipe) {
        return [recipe hasPhotos];
    }];
}

- (NSArray *)recipesWithPhotos {
    NSMutableArray *allRecipes = [NSMutableArray array];
    for (NSArray *categoryRecipes in [self.categoryRecipes allValues]) {
        [allRecipes addObjectsFromArray:categoryRecipes];
    }
    return [allRecipes select:^BOOL(CKRecipe *recipe) {
        return [recipe hasPhotos];
    }];
}

- (CKRecipe *)highlightRecipeForCategory:(NSString *)categoryName {
    NSArray *recipes = [self recipesWithPhotosInCategory:categoryName];
    if ([recipes count] > 0) {
        return [recipes objectAtIndex:arc4random_uniform([recipes count])];
    } else {
        return nil;
    }
}

- (CKRecipe *)highlightRecipeForBook {
    NSArray *recipes = [self recipesWithPhotos];
    if ([recipes count] > 0) {
        return [recipes objectAtIndex:arc4random_uniform([recipes count])];
    } else {
        return nil;
    }
}

- (BOOL)isCategoryDeepLinked {
    return (self.selectedCategoryName != nil);
}

- (NSString *)selectedCategoryNameOrForSection:(NSInteger)section {
    if ([self isCategoryDeepLinked]) {
        return self.selectedCategoryName;
    } else {
        return [self.categoryNames objectAtIndex:section];
    }
}

- (NSInteger)profileSection {
    return 0;
}

- (NSInteger)titleSection {
    return 1;
}

- (NSInteger)indexSection {
    return 2;
}

- (NSInteger)recipeSection {
    return 3;
}

- (void)updateNavTitle {
    CGFloat contentsPageOffset = [self recipeSection] * self.collectionView.bounds.size.width;
    if (self.collectionView.contentOffset.x >= contentsPageOffset) {
        self.titleLabel.hidden = NO;
        
        NSString *categoryName = [self currentCategoryNameFromOffset];
        if (![self.currentCategoryName isEqualToString:categoryName]) {
            NSString *navTitle = [self navigationTitle];
            self.titleLabel.text = navTitle;
            [self.titleLabel sizeToFit];
            self.titleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
                                               self.titleLabel.frame.origin.y,
                                               self.titleLabel.frame.size.width,
                                               self.titleLabel.frame.size.height);
            self.currentCategoryName = navTitle;
        }
        
    } else {
        self.currentCategoryName = nil;
        self.titleLabel.hidden = YES;
    }
}

- (NSString *)navigationTitle {
    NSMutableString *title = [NSMutableString stringWithString:self.book.name];
    NSString *currentCategoryName = [self currentCategoryNameFromOffset];
    if ([currentCategoryName length] > 0) {
        [title appendFormat:@" - %@", [currentCategoryName uppercaseString]];
    }
    return title;
}

- (void)updateBookPagingViewAndDots:(BOOL)updateDots {
    CGFloat contentsPageOffset = [self recipeSection] * self.collectionView.bounds.size.width;
    if (self.collectionView.contentOffset.x >= contentsPageOffset) {
        self.bookPagingView.hidden = NO;
        
        if (updateDots) {
            CGFloat pageSpan = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width - contentsPageOffset;
            NSInteger page = (pageSpan / self.collectionView.bounds.size.width);
            [self.bookPagingView setPage:page];
        }
        
    } else {
        self.bookPagingView.hidden = YES;
    }
}

- (NSString *)currentCategoryNameFromOffset {
    // Start off with the first category name.
    NSString *categoryName = categoryName = [self.categoryNames objectAtIndex:0];
    CGFloat recipePageOffset = [self recipeSection] * self.collectionView.bounds.size.width;
    
    if (self.collectionView.contentOffset.x >= recipePageOffset) {
        BookNavigationLayout *layout = (BookNavigationLayout *)self.collectionView.collectionViewLayout;
        
        NSArray *pageOffsets = [layout pageOffsetsForContentsSections];
        CGFloat currentOffset = self.collectionView.contentOffset.x;
        
        for (NSInteger pageOffsetIndex = 0; pageOffsetIndex < [pageOffsets count]; pageOffsetIndex++) {
            
            NSNumber *pageOffsetNumber = [pageOffsets objectAtIndex:pageOffsetIndex];
            if (currentOffset < [pageOffsetNumber floatValue]) {
                break;
            }
            
            // Update category name.
            categoryName = [self.categoryNames objectAtIndex:pageOffsetIndex];
        }
        
    }
    return categoryName;
}

- (BOOL)canAddRecipe {
    return ([self.book.user isEqual:[CKUser currentUser]]);
}

- (void)addRecipeTapped {
    [self.delegate bookNavigationControllerAddRecipeRequested];
}

- (void)editModeReceived:(NSNotification *)notification {
    self.editMode = [EventHelper editModeForNotification:notification];
    [self updateNavigationButtons];
}

- (void)cancelTapped:(id)sender {
    [EventHelper postEditMode:NO save:NO];
    [self updateNavigationButtons];
}

- (void)saveTapped:(id)sender {
    [EventHelper postEditMode:NO save:YES];
    [self updateNavigationButtons];
}

- (void)loadRecipes {
    self.categoryRecipes = [NSMutableDictionary dictionary];
    self.categoryNames = [NSMutableArray array];
    self.categories = [NSMutableArray array];
    
    for (CKRecipe *recipe in self.recipes) {
        
        CKCategory *category = recipe.category;
        NSString *categoryName = recipe.category.name;
        
        if (![self.categories detect:^BOOL(CKCategory *existingCategory) {
            return [existingCategory.name isEqualToString:categoryName];
            
        }]) {
            
            NSMutableArray *recipes = [NSMutableArray arrayWithObject:recipe];
            [self.categoryRecipes setObject:recipes forKey:categoryName];
            [self.categories addObject:category];
            
        } else {
            
            NSMutableArray *recipes = [self.categoryRecipes objectForKey:categoryName];
            [recipes addObject:recipe];
        }
        
    }
    
    // Sort the categories and extract category name list.
    NSSortDescriptor *categoryOrder = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [self.categories sortUsingDescriptors:@[categoryOrder]];
    self.categoryNames = [NSMutableArray arrayWithArray:[self.categories collect:^id(CKCategory *category) {
        return category.name;
    }]];
    
    // Update the categories for the book if we don't have network loaded categories.
    if ([self.book.currentCategories count] == 0) {
        self.book.currentCategories = self.categories;
    }
    
    // Update the VC's.
    [self.indexViewController configureCategories:self.categoryNames];
    [self.titleViewController configureHeroRecipe:[self highlightRecipeForBook]];
    
    // Now reload the collection.
    [self.collectionView reloadData];

}

@end
