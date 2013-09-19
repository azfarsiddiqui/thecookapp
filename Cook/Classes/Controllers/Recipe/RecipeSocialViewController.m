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

@interface RecipeSocialViewController () <RecipeSocialCommentCellDelegate, CKEditViewControllerDelegate>

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, weak) id<RecipeSocialViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *composeButton;

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

// Height caching.
@property (nonatomic, strong) NSMutableDictionary *commentsCachedSizes;

@end

@implementation RecipeSocialViewController

#define kContentInsets      (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kUnderlayMaxAlpha   0.7
#define kHeaderCellId       @"HeaderCell"
#define kCommentCellId      @"CommentCell"
#define kActivityId         @"ActivityCell"
#define kCommentsSection    0

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeSocialViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[RecipeSocialViewLayout alloc] init]]) {
        self.currentUser = [CKUser currentUser];
        self.recipe = recipe;
        self.delegate = delegate;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        self.commentsCachedSizes = [NSMutableDictionary dictionary];
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
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityId];
    [self.collectionView registerClass:[RecipeSocialCommentCell class] forCellWithReuseIdentifier:kCommentCellId];
    [self.collectionView registerClass:[ModalOverlayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellId];
    
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.composeButton];
    
    [self loadData];
}

- (NSInteger)currentNumComments {
    return [self.comments count];
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
            
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[self.comments count] - 1 inSection:0]]];
            
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.comments) {
        
        if ([self.comments count] > 0) {
            
            // Comment cell.
            CKRecipeComment *comment = [self.comments objectAtIndex:indexPath.item];
            
            // Get cached size if available, and only if they have been persisted.
            CGSize commentSize = CGSizeZero;
            if ([comment persisted]) {
                if ([self.commentsCachedSizes objectForKey:comment.objectId]) {
                    commentSize = [[self.commentsCachedSizes objectForKey:comment.objectId] CGSizeValue];
                } else {
                    commentSize = [RecipeSocialCommentCell sizeForComment:comment];
                    [self.commentsCachedSizes setObject:[NSValue valueWithCGSize:commentSize] forKey:comment.objectId];
                }
            } else {
                
                // Newly added comment, just recalculate the height, won't impact overall performance I hope.
                commentSize = [RecipeSocialCommentCell sizeForComment:comment];
                
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
            CKRecipeComment *comment = [self.comments objectAtIndex:indexPath.item];
            [commentCell configureWithComment:comment];
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

- (UIButton *)composeButton {
    if (!_composeButton) {
        _composeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_edit_light.png"]
                                              target:self
                                            selector:@selector(composeTapped:)];
        _composeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _composeButton.frame = (CGRect){
            self.view.bounds.size.width - _composeButton.frame.size.width - kContentInsets.right,
            kContentInsets.top,
            _composeButton.frame.size.width,
            _composeButton.frame.size.height
        };
    }
    return _composeButton;
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
        
    } failure:^(NSError *error) {
        DLog(@"Unable to load comments");
    }];
}

- (void)closeTapped:(id)sender {
    
    // Inform listeners of current comments
    [[CKSocialManager sharedInstance] updateRecipe:self.recipe numComments:[self.comments count]];
    
    [self.delegate recipeSocialViewControllerCloseRequested];
}

- (void)composeTapped:(id)sender {
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

- (void)insertAddCommentCell {
    NSIndexPath *addIndexPath = [NSIndexPath indexPathForItem:[self.comments count] inSection:kCommentsSection];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[addIndexPath]];
    } completion:^(BOOL finished) {
    }];
}

@end
