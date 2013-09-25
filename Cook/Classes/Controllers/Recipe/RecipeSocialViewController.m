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
#import "ModalOverlayHeaderView.h"
#import "RecipeSocialCommentCell.h"
#import "CKTextViewEditViewController.h"
#import "CKEditingViewHelper.h"
#import "NSString+Utilities.h"
#import "RecipeSocialViewLayout.h"
#import "MRCEnumerable.h"
#import "CKActivityIndicatorView.h"
#import "EventHelper.h"
#import "CKSocialManager.h"
#import "OverlayViewController.h"
#import "RecipeCommentBoxFooterView.h"

@interface RecipeSocialViewController () <CKEditViewControllerDelegate, RecipeSocialCommentCellDelegate,
    RecipeCommentBoxFooterViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, weak) id<RecipeSocialViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *likeButton;

// Data
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) BOOL loading;

// Posting comments.
@property (nonatomic, strong) RecipeSocialCommentCell *editingCell;
@property (nonatomic, strong) UIView *editingView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKTextViewEditViewController *editViewController;
@property (nonatomic, assign) BOOL saving;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *emptyCommentsLabel;

// Size caching.
@property (nonatomic, strong) NSMutableDictionary *commentsCachedSizes;
@property (nonatomic, strong) NSMutableDictionary *commentLayoutInfo;

@end

@implementation RecipeSocialViewController

#define kContentInsets      (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kUnderlayMaxAlpha   0.7
#define kHeaderCellId       @"HeaderCell"
#define kFooterCellId       @"FooterCell"
#define kCommentCellId      @"CommentCell"
#define kActivityId         @"ActivityCell"
#define kCommentsSection    0
#define kNameFrame          @"nameFrame"
#define kTimeFrame          @"timeFrame"
#define kCommentFrame       @"commentFrame"

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeSocialViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.currentUser = [CKUser currentUser];
        self.recipe = recipe;
        self.delegate = delegate;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        self.commentsCachedSizes = [NSMutableDictionary dictionary];
        self.commentLayoutInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.closeButton];
    
    // Like button disabled before data is loaded.
    self.likeButton.enabled = NO;
    [self.view addSubview:self.likeButton];
    
    [self loadData];
}

- (NSInteger)currentNumComments {
    return [self.comments count];
}

#pragma mark - RecipeCommentBoxFooterViewDelegate methods

- (void)recipeCommentBoxFooterViewCommentRequested {
    [self showCommentBox];
}

#pragma mark - RecipeSocialCommentCellDelegate methods

- (void)recipeSocialCommentCellCacheNameFrame:(CGRect)nameFrame commentIndex:(NSUInteger)commentIndex {
    if ([self.commentLayoutInfo objectForKey:@(commentIndex)]) {
        
        NSMutableDictionary *info = [self.commentLayoutInfo objectForKey:@(commentIndex)];
        [info setObject:[NSValue valueWithCGRect:nameFrame] forKey:kNameFrame];
        
    } else {
        
        NSMutableDictionary *info = [@{ kNameFrame : [NSValue valueWithCGRect:nameFrame]} mutableCopy];
        [self.commentLayoutInfo setObject:info forKey:@(commentIndex)];
    }
}

- (void)recipeSocialCommentCellCacheTimeFrame:(CGRect)timeFrame commentIndex:(NSUInteger)commentIndex {
    if ([self.commentLayoutInfo objectForKey:@(commentIndex)]) {
        
        NSMutableDictionary *info = [self.commentLayoutInfo objectForKey:@(commentIndex)];
        [info setObject:[NSValue valueWithCGRect:timeFrame] forKey:kTimeFrame];
        
    } else {
        
        NSMutableDictionary *info = [@{ kTimeFrame : [NSValue valueWithCGRect:timeFrame]} mutableCopy];
        [self.commentLayoutInfo setObject:info forKey:@(commentIndex)];
    }
}

- (void)recipeSocialCommentCellCacheCommentFrame:(CGRect)commentFrame commentIndex:(NSUInteger)commentIndex {
    if ([self.commentLayoutInfo objectForKey:@(commentIndex)]) {
        
        NSMutableDictionary *info = [self.commentLayoutInfo objectForKey:@(commentIndex)];
        [info setObject:[NSValue valueWithCGRect:commentFrame] forKey:kCommentFrame];
        
    } else {
        
        NSMutableDictionary *info = [@{ kCommentFrame : [NSValue valueWithCGRect:commentFrame]} mutableCopy];
        [self.commentLayoutInfo setObject:info forKey:@(commentIndex)];
    }
}

- (CGRect)recipeSocialCommentCellCachedNameFrameForCommentIndex:(NSUInteger)commentIndex {
    if ([self.commentLayoutInfo objectForKey:@(commentIndex)]) {
        return [[[self.commentLayoutInfo objectForKey:@(commentIndex)] objectForKey:kNameFrame] CGRectValue];
    } else {
        return CGRectZero;
    }
}

- (CGRect)recipeSocialCommentCellCachedTimeFrameForCommentIndex:(NSUInteger)commentIndex {
    if ([self.commentLayoutInfo objectForKey:@(commentIndex)]) {
        return [[[self.commentLayoutInfo objectForKey:@(commentIndex)] objectForKey:kTimeFrame] CGRectValue];
    } else {
        return CGRectZero;
    }
}

- (CGRect)recipeSocialCommentCellCachedCommentFrameForCommentIndex:(NSUInteger)commentIndex {
    if ([self.commentLayoutInfo objectForKey:@(commentIndex)]) {
        return [[[self.commentLayoutInfo objectForKey:@(commentIndex)] objectForKey:kCommentFrame] CGRectValue];
    } else {
        return CGRectZero;
    }
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
}

- (void)editViewControllerDidAppear:(BOOL)appear {
    
    if (!appear) {
        
        // Remove the editVC.
        [self.editViewController.view removeFromSuperview];
        self.editViewController = nil;
        
    }
}

- (void)editViewControllerDismissRequested {
    [self.editViewController performEditing:NO];
}

- (void)editViewControllerEditRequested {
}

- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value {
}

- (void)editViewControllerHeadlessUpdatedWithValue:(id)value {
    
    NSString *text = value;
    if ([text CK_containsText]) {
        
        // Create a new comment.
        CKRecipeComment *comment = [CKRecipeComment recipeCommentForUser:self.currentUser recipe:self.recipe text:text];
        [self.comments addObject:comment];
        
        if ([self.comments count] == 1) {
            
            [self.collectionView reloadData];
            
        } else {
            
            NSIndexPath *indexPathToInsert = [NSIndexPath indexPathForItem:[self.comments count] - 1 inSection:kCommentsSection];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:@[indexPathToInsert]];
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:indexPathToInsert.item - 1 inSection:kCommentsSection]]];
            } completion:^(BOOL finished) {
            }];
            
        }
        
        // Saves the comment in the background.
        self.saving = YES;
        [comment saveInBackground];
        
    }
    
}

- (id)editViewControllerInitialValue {
    return nil;
}

- (BOOL)editViewControllerCanSaveFor:(CKEditViewController *)editViewController {
    
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    CGSize unitSize = [RecipeSocialCommentCell unitSize];
    CGFloat sideGap = floorf((self.collectionView.bounds.size.width - unitSize.width) / 2.0);
    
    return (UIEdgeInsets) {
        kContentInsets.top,
        sideGap,
        kContentInsets.bottom,
        sideGap
    };
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
    
    return [ModalOverlayHeaderView unitSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    
    return [RecipeCommentBoxFooterView unitSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.comments) {
        
        if ([self.comments count] > 0) {
            
            // Comment cell.
            CKRecipeComment *comment = [self.comments objectAtIndex:indexPath.item];
            
            // Get cached size if available, and only if they have been persisted.
            CGSize commentSize = CGSizeZero;
            
            if ([self.commentsCachedSizes objectForKey:@(indexPath.item)]) {
                commentSize = [[self.commentsCachedSizes objectForKey:@(indexPath.item)] CGSizeValue];
            } else {
                
                // Calculate the size.
                commentSize = [RecipeSocialCommentCell sizeForComment:comment];
                [self.commentsCachedSizes setObject:[NSValue valueWithCGSize:commentSize] forKey:@(indexPath.item)];
            }
                
            return commentSize;
            
        } else {
            
            return (CGSize){
                self.collectionView.bounds.size.width,
                515.0
            };
        }
        
    } else {
        
        return (CGSize){
            self.collectionView.bounds.size.width,
            515.0
        };
    }
    
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
    
    if (self.comments) {
        
        if ([self.comments count] > 0) {
            numItems = [self.comments count];
        } else {
            numItems = 1;
        }
        
    } else {
        
        // Activity.
        numItems = 1;
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (self.comments) {
        
        if ([self.comments count] > 0) {
            
            RecipeSocialCommentCell *commentCell = (RecipeSocialCommentCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCommentCellId
                                                                                                                             forIndexPath:indexPath];
            commentCell.delegate = self;
            CKRecipeComment *comment = [self.comments objectAtIndex:indexPath.item];
            [commentCell configureWithComment:comment commentIndex:indexPath.item numComments:[self.comments count]];
            
            cell = commentCell;
            
        } else {
            
            // No comments.
            [self.activityView stopAnimating];
            [self.activityView removeFromSuperview];
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kActivityId forIndexPath:indexPath];
            self.emptyCommentsLabel.center = cell.contentView.center;
            [cell.contentView addSubview:self.emptyCommentsLabel];
            
        }
        
    } else {
        
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kActivityId forIndexPath:indexPath];
        self.activityView.center = cell.contentView.center;
        [cell.contentView addSubview:self.activityView];
        [self.activityView startAnimating];
        
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *supplementaryView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        ModalOverlayHeaderView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                     withReuseIdentifier:kHeaderCellId forIndexPath:indexPath];
        [headerView configureTitle:@"COMMENTS"];
        supplementaryView = headerView;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        RecipeCommentBoxFooterView *footerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterCellId forIndexPath:indexPath];
        footerView.delegate = self;
        [footerView configureUser:self.currentUser];
        supplementaryView = footerView;
        
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

- (UIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [ViewHelper buttonWithImage:[self likeButtonImageForOn:NO dark:YES]
                                            target:self
                                          selector:@selector(likeTapped:)];
        _likeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _likeButton.frame = (CGRect){
            self.collectionView.bounds.size.width - _likeButton.frame.size.width - kContentInsets.right,
            kContentInsets.top,
            _likeButton.frame.size.width,
            _likeButton.frame.size.height
        };
    }
    return _likeButton;
}

- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
    }
    return _activityView;
}

- (UILabel *)emptyCommentsLabel {
    if (!_emptyCommentsLabel) {
        _emptyCommentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emptyCommentsLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        _emptyCommentsLabel.textColor = [UIColor whiteColor];
        _emptyCommentsLabel.text = @"NO COMMENTS";
        [_emptyCommentsLabel sizeToFit];
    }
    return _emptyCommentsLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:[[RecipeSocialViewLayout alloc] init]];
        _collectionView.bounces = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityId];
        [_collectionView registerClass:[RecipeSocialCommentCell class] forCellWithReuseIdentifier:kCommentCellId];
        [_collectionView registerClass:[ModalOverlayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellId];
        [_collectionView registerClass:[RecipeCommentBoxFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterCellId];
    }
    return _collectionView;
}

#pragma mark - Private methods

- (void)loadData {
    self.loading = YES;
    
    [self.recipe commentsWithCompletion:^(NSArray *comments){
        DLog(@"Loaded [%d] comments", [comments count]);
        
        self.loading = NO;
        self.comments = [NSMutableArray arrayWithArray:comments];
        
        // Inform listeners of current comments
        [[CKSocialManager sharedInstance] updateRecipe:self.recipe numComments:[comments count]];
        
        NSArray *indexPathsToInsert = [comments collectWithIndex:^id(CKRecipeComment *comment, NSUInteger commentIndex) {
            return [NSIndexPath indexPathForItem:commentIndex inSection:kCommentsSection];
        }];
        
        if ([indexPathsToInsert count] > 0) {
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kCommentsSection]]];
                [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
            } completion:^(BOOL finished) {
            }];
        } else {
            [self.collectionView reloadData];
        }
        
        // Enable the like button.
        self.likeButton.enabled = YES;
        
    } failure:^(NSError *error) {
        DLog(@"Unable to load comments");
    }];
}

- (void)closeTapped:(id)sender {
    
    // Inform listeners of current comments
    [[CKSocialManager sharedInstance] updateRecipe:self.recipe numComments:[self.comments count]];
    
    [self.delegate recipeSocialViewControllerCloseRequested];
}

- (void)likeTapped:(id)sender {
    DLog();
}

- (void)showCommentBox {
    CKTextViewEditViewController *editViewController = [[CKTextViewEditViewController alloc] initWithEditView:nil
                                                                                                     delegate:self
                                                                                                editingHelper:self.editingHelper
                                                                                                        white:YES
                                                                                                        title:@"Comment"
                                                                                               characterLimit:500];
    editViewController.clearOnFocus = YES;
    editViewController.textViewFont = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
    [editViewController performEditing:YES headless:YES transformOffset:(UIOffset){ 0.0, 20.0 }];
    self.editViewController = editViewController;
}

- (UIImage *)likeButtonImageForOn:(BOOL)on dark:(BOOL)dark {
    NSMutableString *imageName = [NSMutableString stringWithFormat:@"cook_book_inner_icon_like_%@", dark ? @"dark" : @"light"];
    if (on) {
        [imageName appendString:@"_on"];
    }
    [imageName appendString:@".png"];
    return [UIImage imageNamed:imageName];
}

@end
