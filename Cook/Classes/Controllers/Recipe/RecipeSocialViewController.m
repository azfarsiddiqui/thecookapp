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
#import "CKUser.h"
#import "CKRecipeComment.h"
#import "RecipeSocialHeaderView.h"
#import "RecipeSocialCommentCell.h"
#import "CKTextViewEditViewController.h"
#import "CKEditingViewHelper.h"
#import "NSString+Utilities.h"
#import "RecipeSocialViewLayout.h"
#import "MRCEnumerable.h"

@interface RecipeSocialViewController () <RecipeSocialCommentCellDelegate, CKEditViewControllerDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, weak) id<RecipeSocialViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;

// Data
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) BOOL loading;

// Posting comments.
@property (nonatomic, strong) RecipeSocialCommentCell *editingCell;
@property (nonatomic, strong) UIView *editingView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKTextViewEditViewController *editViewController;
@property (nonatomic, assign) BOOL saving;

@end

@implementation RecipeSocialViewController

#define kContentInsets      (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }
#define kUnderlayMaxAlpha   0.7
#define kCommentsSection    0
#define kHeaderHeight       100.0
#define kHeaderCellId       @"HeaderCell"
#define kCommentCellId      @"CommentCell"

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeSocialViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[RecipeSocialViewLayout alloc] init]]) {
        self.currentUser = [CKUser currentUser];
        self.recipe = recipe;
        self.delegate = delegate;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
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

#pragma mark - RecipeSocialCommentCellDelegate methods

- (void)recipeSocialCommentCellEditForCell:(RecipeSocialCommentCell *)commentCell editingView:(UIView *)editingView {
    
    // No posting if it was loading.
    if (self.loading) {
        return;
    }
    
    // Remember the editing cell.
    self.editingCell = commentCell;
    
    // Configure a text view for editing.
    CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:editingView
                                                                                                     delegate:self
                                                                                                editingHelper:self.editingHelper
                                                                                                        white:YES
                                                                                                        title:@"Comment"
                                                                                               characterLimit:500];
    editViewController.clearOnFocus = YES;
    editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
    [editViewController performEditing:YES];
    self.editViewController = editViewController;
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
}

- (void)editViewControllerDidAppear:(BOOL)appear {
    
    if (!appear) {
        
        // Remove the editVC.
        [self.editViewController.view removeFromSuperview];
        self.editViewController = nil;
        
        // Now unwrap it.
        [self.editingHelper unwrapEditingView:self.editingView animated:YES];
        
        // Then insert another empty row below it.
        if (self.saving) {
            self.saving = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self insertAddCommentCell];
            });
        }
    }
}

- (void)editViewControllerDismissRequested {
    [self.editViewController performEditing:NO];
}

- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value {
    
    NSString *text = (NSString *)value;
    if ([text CK_containsText]) {
        
        // Create a new comment.
        CKRecipeComment *comment = [CKRecipeComment recipeCommentForUser:self.currentUser recipe:self.recipe text:text];
        [self.comments addObject:comment];
        
        // Saves the comment in the background.
        self.saving = YES;
        [comment saveInBackground];
        
        // Configure the editingCell to display the created comment.
        [self.editingCell configureWithComment:comment];
        
        // Remember the editingView for us to unwrap it later.
        self.editingView = editingView;
        
        // Update editing box.
        [self.editingHelper updateEditingView:editingView];
        
    }
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
    cell.editingHelper = self.editingHelper;
    cell.delegate = self;
    
    if (indexPath.item < [self.comments count]) {
        
        CKRecipeComment *comment = [self.comments objectAtIndex:indexPath.item];
        [cell configureWithComment:comment];
        
    } else {
        
        // Add cell for the current user.
        [cell configureAsPostCommentCellForUser:self.currentUser loading:self.loading];
        
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
    self.comments = [NSMutableArray array];
    self.loading = YES;
    
    [self.recipe commentsWithCompletion:^(NSArray *comments){
        DLog(@"Loaded [%d] comments", [comments count]);
        
        self.loading = NO;
        [self.comments addObjectsFromArray:comments];
        
        NSArray *indexPathsToInsert = [comments collectWithIndex:^id(CKRecipeComment *comment, NSUInteger commentIndex) {
            return [NSIndexPath indexPathForItem:commentIndex inSection:kCommentsSection];
        }];
        [self.collectionView performBatchUpdates:^{
            
            // Insert comments.
            [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
            
        } completion:^(BOOL finished) {
            
            // Reload the comments post field.
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[comments count] inSection:kCommentsSection]]];
            
        }];
        
    } failure:^(NSError *error) {
    }];
}

- (void)closeTapped:(id)sender {
    [self.delegate recipeSocialViewControllerCloseRequested];
}

- (void)insertAddCommentCell {
    NSIndexPath *addIndexPath = [NSIndexPath indexPathForItem:[self.comments count] inSection:kCommentsSection];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[addIndexPath]];
    } completion:^(BOOL finished) {
    }];
}

@end
