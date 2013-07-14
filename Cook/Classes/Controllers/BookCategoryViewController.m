//
//  BookCategoryViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCategoryViewController.h"
#import "CKBook.h"
#import "CKCategory.h"
#import "CKRecipe.h"
#import "BookCategoryLayout.h"
#import "ParsePhotoStore.h"
#import "BookRecipeCollectionViewCell.h"
#import "MRCEnumerable.h"

@interface BookCategoryViewController ()

@property (nonatomic, weak) id<BookCategoryViewControllerDelegate> delegate;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKCategory *category;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSMutableArray *recipes;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation BookCategoryViewController

#define kRecipeCellId   @"RecipeCellId"

- (id)initWithBook:(CKBook *)book category:(CKCategory *)category delegate:(id<BookCategoryViewControllerDelegate>)delegate {
    
    if (self = [super initWithCollectionViewLayout:[[BookCategoryLayout alloc] init]]) {
        self.delegate = delegate;
        self.book = book;
        self.category = category;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.imageView belowSubview:self.collectionView];
    
    [self initCollectionView];
    [self loadData];
}

- (void)loadData {
    self.recipes = [NSMutableArray arrayWithArray:[self.delegate
                                                   recipesForBookCategoryViewControllerForCategory:self.category]];
    [self.collectionView reloadData];
    [self loadFeaturedRecipe];
    
//    [self.book fetchRecipesForCategory:self.category
//                               success:^(NSArray *recipes) {
//                                   DLog(@"Loaded [%d] recipes for [%@]", [recipes count], self.category.name);
//                                   self.recipes = [NSMutableArray arrayWithArray:recipes];
//                                   [self.collectionView reloadData];
//                                   [self loadFeaturedRecipe];
//                               }
//                               failure:^(NSError *error) {
//                                   DLog(@"%@", [error localizedDescription]);
//                               }];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    numItems = [self.recipes count];
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BookRecipeCollectionViewCell *recipeCell = (BookRecipeCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kRecipeCellId forIndexPath:indexPath];
    CKRecipe *recipe = [self.recipes objectAtIndex:indexPath.item];
    [recipeCell configureRecipe:recipe book:self.book];
    
    // Configure image.
    [self configureImageForRecipeCell:recipeCell recipe:recipe indexPath:indexPath];
    
    return recipeCell;
}

#pragma mark - Private 

- (void)initCollectionView {
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[BookRecipeCollectionViewCell class] forCellWithReuseIdentifier:kRecipeCellId];
}

- (void)loadFeaturedRecipe {
    CKRecipe *featuredRecipe = [self.delegate featuredRecipeForBookCategoryViewControllerForCategory:self.category];
    [self.photoStore imageForParseFile:[featuredRecipe imageFile]
                                  size:self.imageView.bounds.size
                            completion:^(UIImage *image) {
                                self.imageView.image = image;
                            }];
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

@end
