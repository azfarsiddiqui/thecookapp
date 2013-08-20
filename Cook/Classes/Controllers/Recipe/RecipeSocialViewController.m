//
//  RecipeSocialViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeSocialViewController.h"
#import "ViewHelper.h"
#import "CKRecipe.h"
#import "CKRecipeComment.h"
#import "RecipeSocialHeaderView.h"
#import "RecipeSocialCommentCell.h"

@interface RecipeSocialViewController ()

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, weak) id<RecipeSocialViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSMutableArray *comments;

@end

@implementation RecipeSocialViewController

#define kContentInsets      (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }
#define kUnderlayMaxAlpha   0.7
#define kCommentsSection    0
#define kHeaderHeight       100.0
#define kHeaderCellId       @"HeaderCell"
#define kCommentCellId      @"CommentCell"

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeSocialViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]]) {
        self.recipe = recipe;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:kUnderlayMaxAlpha];
    self.collectionView.bounces = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[RecipeSocialCommentCell class] forCellWithReuseIdentifier:kCommentCellId];
    [self.collectionView registerClass:[RecipeSocialHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellId];
    
    [self.view addSubview:self.closeButton];
    
    [self loadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    CGSize unitSize = [RecipeSocialCommentCell unitSize];
    CGFloat sideGap = floorf((self.collectionView.bounds.size.width - unitSize.width) / 2.0);
    
    return (UIEdgeInsets) { kContentInsets.top, sideGap, kContentInsets.bottom, sideGap };
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between columns in the same row.
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between rows in the same column.
    return 20.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize headerSize = (CGSize) {
        self.collectionView.bounds.size.width,
        kHeaderHeight
    };
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize cellSize = CGSizeZero;
    if (indexPath.section == kCommentsSection) {
        
        if (indexPath.item < [self.comments count]) {
            
            // Comment cell.
            CKRecipeComment *comment = [self.comments objectAtIndex:indexPath.item];
            cellSize = [RecipeSocialCommentCell sizeForComment:comment];
            
        } else {
            
            // Add cell.
            cellSize = [RecipeSocialCommentCell unitSize];
            
        }
    }
    
    return cellSize;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    
    if (section == kCommentsSection) {
        numItems = [self.comments count];
        numItems += 1;  // Post comment.
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RecipeSocialCommentCell *cell = (RecipeSocialCommentCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCommentCellId forIndexPath:indexPath];
    
    if (indexPath.item < [self.comments count]) {
        
        CKRecipeComment *comment = [self.comments objectAtIndex:indexPath.item];
        [cell configureWithComment:comment];
        
    } else {
        
        // Add cell.
        [cell configureAsPostCommentCell];
    }
    
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *supplementaryView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        RecipeSocialHeaderView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                     withReuseIdentifier:kHeaderCellId forIndexPath:indexPath];
        supplementaryView = headerView;
    }
    
    return supplementaryView;
}

#pragma mark - Properties

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_close_dark.png"]
                                            target:self
                                          selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            kContentInsets.top,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

#pragma mark - Private methods

- (void)loadData {
    [self.recipe commentsWithCompletion:^(NSArray *comments){
        DLog(@"Loaded [%d] comments", [comments count]);
        self.comments = [NSMutableArray arrayWithArray:comments];
    } failure:^(NSError *error) {
        [self.collectionView reloadData];
    }];
}

- (void)closeTapped:(id)sender {
    [self.delegate recipeSocialViewControllerCloseRequested];
}

@end
