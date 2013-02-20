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
#import "MRCEnumerable.h"
#import "ViewHelper.h"
#import "NewRecipeViewController.h"
#import "ParsePhotoStore.h"
#import "BookProfileCollectionViewCell.h"
#import "BookContentsCollectionViewCell.h"

@interface BookNavigationViewController () <BookNavigationLayoutDataSource, NewRecipeViewDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, assign) id<BookNavigationViewControllerDelegate> delegate;

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSMutableArray *categoryNames;
@property (nonatomic, strong) NSMutableDictionary *categoryRecipes;
@property (nonatomic, strong) ParsePhotoStore *photoStore;

@end

@implementation BookNavigationViewController

#define kProfileSection     0
#define kContentsSection    1
#define kRecipeCellId       @"RecipeCellId"
#define kCategoryHeaderId   @"CategoryHeaderId"
#define kProfileCellId      @"ProfileCellId"
#define kContentsCellId     @"ContentsCellId"

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[BookNavigationLayout alloc] initWithDataSource:self]]) {
        self.delegate = delegate;
        self.book = book;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavButtons];
    [self initCollectionView];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    
    // TODO Clear photo cache?
    
}

#pragma mark - BookNavigationLayoutDataSource methods

- (NSUInteger)bookNavigationContentStartSection {
    return 2;
}

- (NSUInteger)bookNavigationLayoutNumColumns {
    return 3;
}

- (NSUInteger)bookNavigationLayoutColumnWidthForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    if (indexPath.section >= contentStartSection) {
        
        // TODO Launch recipe view.
        DLog();
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    if (indexPath.section >= contentStartSection) {
        
        // Clears the image on disappear.
        BookRecipeCollectionViewCell *recipeCell = (BookRecipeCollectionViewCell *)cell;
        [recipeCell configureImage:nil];
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
    numSections += [self.categoryNames count];
    
    return numSections;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    NSInteger categorySection = section - contentStartSection;
    
    if (section >= contentStartSection) {
        NSString *categoryName = [self.categoryNames objectAtIndex:categorySection];
        NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
        numItems = [categoryRecipes count];
    } else {
        numItems = 1;
    }
    
    DLog(@"Num Items for Section [%d]: %d", section, numItems);
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
            NSString *categoryName = [self.categoryNames objectAtIndex:categorySection];
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
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    
    if (indexPath.section >= contentStartSection) {
        cell = [self recipeCellAtIndexPath:indexPath];
    } else if (indexPath.section == kProfileSection) {
        cell = [self profileCellAtIndexPath:indexPath];
    } else if (indexPath.section == kContentsSection) {
        cell = [self contentsCellAtIndexPath:indexPath];
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

#pragma mark - Private methods

- (void)initNavButtons {
    
    // Close button
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_close_gray.png"]
                                                 target:self
                                               selector:@selector(closeTapped:)];
    closeButton.frame = CGRectMake(20.0,
                                   15.0,
                                   closeButton.frame.size.width,
                                   closeButton.frame.size.height);
    [self.view addSubview:closeButton];
    self.closeButton = closeButton;
    
    // Add button.
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [createButton setTitle:@"Add" forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createTapped:) forControlEvents:UIControlEventTouchUpInside];
    [createButton sizeToFit];
    createButton.frame = CGRectMake(closeButton.frame.origin.x + closeButton.frame.size.width + 10.0,
                                    closeButton.frame.origin.y,
                                    createButton.frame.size.width,
                                    createButton.frame.size.height);
    [self.view addSubview:createButton];
    self.createButton = createButton;
}

- (void)initCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    
    // Profile and Contents
    [self.collectionView registerClass:[BookProfileCollectionViewCell class] forCellWithReuseIdentifier:kProfileCellId];
    [self.collectionView registerClass:[BookContentsCollectionViewCell class] forCellWithReuseIdentifier:kContentsCellId];
    
    // Categories
    [self.collectionView registerClass:[BookCategoryView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCategoryHeaderId];
    [self.collectionView registerClass:[BookRecipeCollectionViewCell class] forCellWithReuseIdentifier:kRecipeCellId];
}

- (void)loadData {
    
    // Fetch all recipes for the book and partition them into their categories.
    [self.book fetchRecipesSuccess:^(NSArray *recipes) {
        
        self.categoryRecipes = [NSMutableDictionary dictionary];
        self.categoryNames = [NSMutableArray array];
        
        for (CKRecipe *recipe in recipes) {
            
            NSString *categoryName = recipe.category.name;
            
            if (![self.categoryNames containsObject:categoryName]) {
                NSMutableArray *recipes = [NSMutableArray arrayWithObject:recipe];
                [self.categoryRecipes setObject:recipes forKey:categoryName];
                [self.categoryNames addObject:categoryName];
            } else {
                NSMutableArray *recipes = [self.categoryRecipes objectForKey:categoryName];
                [recipes addObject:recipe];
            }
        }
        
        // Now reload the collection.
        [self.collectionView reloadData];
        
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
    }];
}

- (CKRecipe *)highlightRecipeForCategory:(NSString *)categoryName {
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    
        // Pick a random recipe with image otherwise return nil.
    if ([categoryRecipes count] > 0) {
        
        // Get first object.
        return [categoryRecipes objectAtIndex:0];
//        return [categoryRecipes objectAtIndex:arc4random() % ([categoryRecipes count])];
        
    } else {
        return nil;
    }
    
}

- (void)closeTapped:(id)sender {
    [self.delegate bookNavigationControllerCloseRequested];
}

- (void)createTapped:(id)sender {
    DLog();
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
    NewRecipeViewController *newRecipeViewVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NewRecipeViewController"];
    newRecipeViewVC.recipeViewDelegate = self;
    newRecipeViewVC.book = self.book;
    [self presentViewController:newRecipeViewVC animated:YES completion:nil];
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

    } else {
        [recipeCell configureImage:nil];
    }
}

- (UICollectionViewCell *)recipeCellAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger contentStartSection = [self bookNavigationContentStartSection];
    NSInteger categorySection = indexPath.section - contentStartSection;
    
    BookRecipeCollectionViewCell *recipeCell = (BookRecipeCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kRecipeCellId
                                                                                                                              forIndexPath:indexPath];;
    
    NSString *categoryName = [self.categoryNames objectAtIndex:categorySection];
    NSArray *categoryRecipes = [self.categoryRecipes objectForKey:categoryName];
    
    // Populate recipe.
    CKRecipe *recipe = [categoryRecipes objectAtIndex:indexPath.item];
    [recipeCell configureRecipe:recipe];
    
    // Configure image.
    [self configureImageForRecipeCell:recipeCell recipe:recipe indexPath:indexPath];
    
    return recipeCell;
}

- (UICollectionViewCell *)profileCellAtIndexPath:(NSIndexPath *)indexPath {
    BookProfileCollectionViewCell *profileCell = (BookProfileCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kProfileCellId
                                                                                                                                 forIndexPath:indexPath];;
    profileCell.contentView.backgroundColor = [UIColor lightGrayColor];
    return profileCell;
}

- (UICollectionViewCell *)contentsCellAtIndexPath:(NSIndexPath *)indexPath {
    BookContentsCollectionViewCell *contentsCell = (BookContentsCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kContentsCellId
                                                                                                                                    forIndexPath:indexPath];
    [contentsCell configureBook:self.book];
    return contentsCell;
}

@end
