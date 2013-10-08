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
#import "RecipeCommentCell.h"
#import "CKTextViewEditViewController.h"
#import "CKEditingViewHelper.h"
#import "NSString+Utilities.h"
#import "RecipeSocialLayout.h"
#import "MRCEnumerable.h"
#import "CKActivityIndicatorView.h"
#import "EventHelper.h"
#import "CKSocialManager.h"
#import "OverlayViewController.h"
#import "RecipeCommentBoxFooterView.h"
#import "CKUserProfilePhotoView.h"
#import "RecipeLikeCell.h"
#import "DateHelper.h"
#import "CKLikeView.h"
#import "CKRecipeLike.h"
#import "RecipeSocialLikeLayout.h"
#import "AnalyticsHelper.h"
#import "ProfileViewController.h"

@interface RecipeSocialViewController () <CKEditViewControllerDelegate, RecipeSocialCommentCellDelegate,
    RecipeCommentBoxFooterViewDelegate, RecipeSocialLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) CKNavigationController *cookNavigationController;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionView *likesCollectionView;
@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, weak) id<RecipeSocialViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CKLikeView *likeButton;
@property (nonatomic, strong) NSMutableArray *likeViews;

// Data
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *likes;
@property (nonatomic, assign) BOOL loading;

// Posting comments.
@property (nonatomic, strong) RecipeCommentCell *editingCell;
@property (nonatomic, strong) UIView *editingView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKTextViewEditViewController *editViewController;
@property (nonatomic, assign) BOOL saving;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *emptyCommentsLabel;

// Size caching.
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSMutableDictionary *commentsCachedSizes;
@property (nonatomic, strong) NSMutableDictionary *commentLayoutInfo;
@property (nonatomic, strong) NSMutableDictionary *commentTimeDisplays;

@end

@implementation RecipeSocialViewController

#define kContentInsets      (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kButtonInsets       (UIEdgeInsets){ 26.0, 10.0, 15.0, 12.0 }
#define kUnderlayMaxAlpha   0.7
#define kHeaderCellId       @"HeaderCell"
#define kFooterCellId       @"FooterCell"
#define kCommentCellId      @"CommentCell"
#define kActivityId         @"ActivityCell"
#define kLikeCellId         @"LikeCell"
#define kCommentsSection    0
#define kNameFrame          @"nameFrame"
#define kTimeFrame          @"timeFrame"
#define kCommentFrame       @"commentFrame"

- (void)dealloc {
    [EventHelper unregisterSocialUpdates:self];
}

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeSocialViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.currentUser = [CKUser currentUser];
        self.recipe = recipe;
        self.delegate = delegate;
        self.editingHelper = [[CKEditingViewHelper alloc] init];
        self.commentsCachedSizes = [NSMutableDictionary dictionary];
        self.commentLayoutInfo = [NSMutableDictionary dictionary];
        self.commentTimeDisplays = [NSMutableDictionary dictionary];
        self.currentDate = [NSDate date];
        self.loading = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.likesCollectionView];
    [self.view addSubview:self.collectionView];
    
    // Like button disabled before data is loaded.
    if (![self.recipe isOwner]) {
        if ([self.delegate respondsToSelector:@selector(recipeSocialViewControllerLikeView)]) {
            self.likeButton = [self.delegate recipeSocialViewControllerLikeView];
            
            // Detach it from a shared like view.
            [self.likeButton removeFromSuperview];
            self.likeButton.alpha = 1.0;
            
        } else {
            self.likeButton = [[CKLikeView alloc] initWithRecipe:self.recipe];
            self.likeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        }
        
        // Reposition it.
        self.likeButton.frame = (CGRect){
            self.view.frame.size.width - kButtonInsets.right - self.likeButton.frame.size.width,
            kButtonInsets.top,
            self.likeButton.frame.size.width,
            self.likeButton.frame.size.height};
        
        [self.view addSubview:self.likeButton];
    }
    
    if (self.cookNavigationController) {
        self.collectionView.alpha = 0.0;
        self.likesCollectionView.alpha = 0.0;
        
        if ([self.cookNavigationController isTopViewController:self]) {
            self.closeButton = [ViewHelper addCloseButtonToView:self.view light:NO target:self selector:@selector(closeTapped:)];
        } else {
            self.backButton = [ViewHelper addBackButtonToView:self.view light:NO target:self selector:@selector(backTapped:)];
        }
    } else {
        self.closeButton = [ViewHelper addCloseButtonToView:self.view light:NO target:self selector:@selector(closeTapped:)];
        [self loadData];
    }
    
}

- (NSInteger)currentNumComments {
    return [self.comments count];
}

#pragma mark - CKNavigationControllerSupport methods

- (void)cookNavigationControllerViewWillAppear:(NSNumber *)boolNumber {
    if (![boolNumber boolValue]) {
        [self.activityView stopAnimating];
    }
}

- (void)cookNavigationControllerViewAppearing:(NSNumber *)boolNumber {
    BOOL appear = [boolNumber boolValue];
    self.backButton.alpha = appear ? 1.0 : 0.0;
    self.collectionView.alpha = appear ? 1.0 : 0.0;
    self.likesCollectionView.alpha = appear ? 1.0 : 0.0;
}

- (void)cookNavigationControllerViewDidAppear:(NSNumber *)boolNumber {
    if ([boolNumber boolValue]) {
        [self loadData];
        
        // Only show context if this was nested.
        if (![self.cookNavigationController isTopViewController:self]) {
            [self showContextWithRecipe:self.recipe];
        }
    }
}

#pragma mark - RecipeCommentBoxFooterViewDelegate methods

- (void)recipeCommentBoxFooterViewCommentRequested {
    
    // Only allow commenting after it has finished loading.
    if (!self.loading) {
        [self showCommentBox];
    }
}

#pragma mark - RecipeSocialCommentCellDelegate methods

- (NSValue *)recipeSocialCommentCellNameFrameValueForCommentIndex:(NSUInteger)commentIndex {
    return [[self.commentLayoutInfo objectForKey:@(commentIndex)] objectForKey:kNameFrame];
}

- (NSValue *)recipeSocialCommentCellTimeFrameValueForCommentIndex:(NSUInteger)commentIndex {
    return [[self.commentLayoutInfo objectForKey:@(commentIndex)] objectForKey:kTimeFrame];
}

- (NSValue *)recipeSocialCommentCellCommentFrameValueForCommentIndex:(NSUInteger)commentIndex {
    return [[self.commentLayoutInfo objectForKey:@(commentIndex)] objectForKey:kCommentFrame];
}

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

- (NSString *)recipeSocialCommentCellTimeDisplayForCommentIndex:(NSUInteger)commentIndex {
    CKRecipeComment *comment = [self.comments objectAtIndex:commentIndex];
    NSString *timeDisplay = [self.commentTimeDisplays objectForKey:@(commentIndex)];
    if (!timeDisplay) {
        
        // Handle nil createdDateTime as it could be from a newly created message.
        NSDate *date = comment.createdDateTime ? comment.createdDateTime : [NSDate date];
        timeDisplay = [[[DateHelper sharedInstance] relativeDateTimeDisplayForDate:date fromDate:self.currentDate] uppercaseString];
        [self.commentTimeDisplays setObject:timeDisplay forKey:@(commentIndex)];
    }
    return timeDisplay;
}

- (void)recipeSocialCommentCellProfileRequestedForUser:(CKUser *)user {
    if (self.cookNavigationController && user) {
        [self.cookNavigationController pushViewController:[[ProfileViewController alloc] initWithUser:user] animated:YES];
    }
}

#pragma mark - RecipeSocialLayoutDelegate methods

- (void)recipeSocialLayoutDidFinish {
    DLog();
}

- (CKRecipeComment *)recipeSocialLayoutCommentAtIndex:(NSUInteger)commentIndex {
    return [self.comments objectAtIndex:commentIndex];
}

- (BOOL)recipeSocialLayoutIsLoading {
    return self.loading;
}

- (BOOL)recipeSocialLayoutAllowCommenting {
    return (self.currentUser != nil);
}

- (UIEdgeInsets)recipeSocialLayoutContentInsets {
    return (UIEdgeInsets) { 0.0, (self.view.bounds.size.width - self.likesCollectionView.frame.origin.x), 0.0, 0.0 };
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
        
        // Update current date so that elapsed time can be ahead of it.
        self.currentDate = [NSDate date];
        
        // Create a new comment.
        CKRecipeComment *comment = [CKRecipeComment recipeCommentForUser:self.currentUser recipe:self.recipe text:text];
        [self.comments addObject:comment];
        
        // Cache the comment size.
        CGSize size = [RecipeCommentCell sizeForComment:comment];
        [self.commentsCachedSizes setObject:[NSValue valueWithCGSize:size] forKey:@([self.comments count] - 1)];
        
        // Requires relayout.
        [[self currentLayout] setNeedsRelayout:YES];
        
        if ([self.comments count] == 1) {
            
            [self.collectionView reloadData];
            
        } else {
            
            NSIndexPath *indexPathToInsert = [NSIndexPath indexPathForItem:[self.comments count] - 1 inSection:kCommentsSection];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:@[indexPathToInsert]];
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:indexPathToInsert.item - 1 inSection:kCommentsSection]]];
            } completion:^(BOOL finished) {
                
                // Scroll right to the bottom.
                [self.collectionView setContentOffset:(CGPoint){
                    self.collectionView.bounds.origin.x,
                    self.collectionView.contentSize.height - self.collectionView.bounds.size.height
                } animated:YES];

            }];
            
        }
        
        // Saves the comment in the background.
        self.saving = YES;
        [comment saveInBackground];
        [AnalyticsHelper trackEventName:@"Commented" params:nil];
    }
    
}

- (id)editViewControllerInitialValue {
    return nil;
}

- (BOOL)editViewControllerCanSaveFor:(CKEditViewController *)editViewController {
    
    return YES;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    
    if (collectionView == self.collectionView) {
        if (self.loading) {
            
            // Activity.
            if (section == kCommentsSection) {
                numItems = 1;
            }
            
        } else {
            
            // Comments.
            numItems = [self.comments count];
            
        }
        
    } else {
        
        // Likes
        numItems = [self.likes count];
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    if (collectionView == self.collectionView) {
        cell = [self commentCellAtIndexPath:indexPath];
    } else {
        cell = [self likeCellAtIndexPath:indexPath];
    }
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
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

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [CKUserProfilePhotoView sizeForProfileSize:ProfileViewSizeMini];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    return (UIEdgeInsets) { 0.0, 0.0, 0.0, 0.0 };
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 15.0;
}

#pragma mark - Properties

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
                                             collectionViewLayout:[[RecipeSocialLayout alloc] initWithDelegate:self]];
        _collectionView.bounces = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
        _collectionView.frame = (CGRect){
            self.view.bounds.origin.x,
            self.view.bounds.origin.y,
            self.view.bounds.size.width - (self.view.bounds.size.width - self.likesCollectionView.frame.origin.x),
            self.view.bounds.size.height
        };
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityId];
        [_collectionView registerClass:[RecipeCommentCell class] forCellWithReuseIdentifier:kCommentCellId];
        [_collectionView registerClass:[ModalOverlayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellId];
        [_collectionView registerClass:[RecipeCommentBoxFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterCellId];
    }
    return _collectionView;
}

- (UICollectionView *)likesCollectionView {
    if (!_likesCollectionView) {
        CGSize size = [CKUserProfilePhotoView sizeForProfileSize:ProfileViewSizeMini];
        
        _likesCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                  collectionViewLayout:[[RecipeSocialLikeLayout alloc] init]];
        _likesCollectionView.scrollEnabled = NO;
        _likesCollectionView.backgroundColor = [UIColor clearColor];
        _likesCollectionView.showsVerticalScrollIndicator = NO;
        _likesCollectionView.alwaysBounceVertical = NO;
        _likesCollectionView.delegate = self;
        _likesCollectionView.dataSource = self;
        _likesCollectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
        _likesCollectionView.frame = (CGRect){
            self.view.bounds.size.width - size.width - kContentInsets.right - 7.0,
            80.0,
            size.width,
            self.view.bounds.size.height
        };
        [_likesCollectionView registerClass:[RecipeLikeCell class] forCellWithReuseIdentifier:kLikeCellId];
    }
    return _likesCollectionView;
}

#pragma mark - Private methods

- (void)loadData {
    
    [self.recipe commentsLikesWithCompletion:^(NSArray *comments, NSArray *likes) {
        DLog(@"Loaded [%d] comments", [comments count]);
        
        [[self currentLayout] setNeedsRelayout:YES];
        self.loading = NO;
        self.comments = [NSMutableArray arrayWithArray:comments];
        self.likes = [NSMutableArray arrayWithArray:likes];

        // Pre-cache comment sizes.
        [self cacheCommentSizes];
        
        // Inform listeners of current comments
        [[CKSocialManager sharedInstance] updateRecipe:self.recipe numComments:[comments count]];
        
        // Insert comments.
        NSArray *indexPathsToInsert = [comments collectWithIndex:^id(CKRecipeComment *comment, NSUInteger commentIndex) {
            return [NSIndexPath indexPathForItem:commentIndex inSection:kCommentsSection];
        }];
        if ([indexPathsToInsert count] > 0) {
            
            // Remove spinner and add the comment cells.
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kCommentsSection]]];
                [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
            } completion:^(BOOL finished) {
                
            }];
            
        } else {
            [self.collectionView reloadData];
        }
        
        // Insert likes.
        NSArray *likesIndexPathsToInsert = [likes collectWithIndex:^id(CKRecipeLike *like, NSUInteger likeIndex) {
            return [NSIndexPath indexPathForItem:likeIndex inSection:0];
        }];
        if ([likesIndexPathsToInsert count] > 0) {
            [self.likesCollectionView performBatchUpdates:^{
                [self.likesCollectionView insertItemsAtIndexPaths:likesIndexPathsToInsert];
            } completion:^(BOOL finished) {
            }];
        }
        
    } failure:^(NSError *error) {
        
        // No comments.
        [self.activityView stopAnimating];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        self.emptyCommentsLabel.center = cell.contentView.center;
        [cell.contentView addSubview:self.emptyCommentsLabel];

    }];
    
    // Listen for like events.
    [EventHelper registerSocialUpdates:self selector:@selector(socialUpdates:)];

}

- (void)backTapped:(id)sender {
    [self.cookNavigationController popViewControllerAnimated:YES];
}

- (void)closeTapped:(id)sender {
    
    // Inform listeners of current comments
    [[CKSocialManager sharedInstance] updateRecipe:self.recipe numComments:[self.comments count]];
    
    [self.delegate recipeSocialViewControllerCloseRequested];
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

- (void)cacheCommentSizes {
    [self.comments eachWithIndex:^(CKRecipeComment *comment, NSUInteger commentIndex) {
        CGSize size = [RecipeCommentCell sizeForComment:comment];
        [self.commentsCachedSizes setObject:[NSValue valueWithCGSize:size] forKey:@(commentIndex)];
    }];
}

- (RecipeSocialLayout *)currentLayout {
    return (RecipeSocialLayout *)self.collectionView.collectionViewLayout;
}

- (void)showLikes:(BOOL)show {
    
    CGFloat yOffset = 90.0;
    CGFloat rowGap = 20.0;
    CGFloat minScale = 0.8;
    
    self.likeViews = [NSMutableArray arrayWithCapacity:[self.likes count]];
    for (CKRecipeLike *like in self.likes) {
        
        // Like photo.
        CKUserProfilePhotoView *likePhoto = [[CKUserProfilePhotoView alloc] initWithProfileSize:ProfileViewSizeMini];
        CGRect frame = likePhoto.frame;
        frame.origin = (CGPoint){
            self.view.bounds.size.width - kContentInsets.right - frame.size.width - 7.0,
            yOffset
        };
        likePhoto.frame = frame;
        [likePhoto loadProfilePhotoForUser:like.user];
        
        // Prep for transition.
        likePhoto.alpha = 0.0;
        likePhoto.transform = CGAffineTransformMakeScale(minScale, minScale);
        [self.view addSubview:likePhoto];
        
        [self.likeViews addObject:likePhoto];
        yOffset += likePhoto.frame.size.height + rowGap;
    }

    // Fade it in with some animation.
    [self.likeViews eachWithIndex:^(CKUserProfilePhotoView *likePhotoView, NSUInteger photoIndex) {
        [UIView animateWithDuration:0.2
                              delay:photoIndex * 0.08    // Each popping in at descending rate.
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             likePhotoView.alpha = 1.0;
                             likePhotoView.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                         }];
    }];
    
}

- (UICollectionViewCell *)likeCellAtIndexPath:(NSIndexPath *)indexPath {
    RecipeLikeCell *likeCell = (RecipeLikeCell *)[self.likesCollectionView dequeueReusableCellWithReuseIdentifier:kLikeCellId
                                                                                                     forIndexPath:indexPath];
    CKRecipeLike *like = [self.likes objectAtIndex:indexPath.item];
    [likeCell configureLike:like];
    return likeCell;
}

- (UICollectionViewCell *)commentCellAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    
    if (self.loading) {
        
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kActivityId forIndexPath:indexPath];
        if (!self.activityView.superview) {
            self.activityView.center = cell.contentView.center;
            [cell.contentView addSubview:self.activityView];
            [self.activityView startAnimating];
        }
        
    } else {
        
        if ([self.comments count] > 0) {
            
            RecipeCommentCell *commentCell = (RecipeCommentCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCommentCellId
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
        
    }
    return cell;
}

- (void)socialUpdates:(NSNotification *)notification {
    CKRecipe *recipe = [EventHelper socialUpdatesRecipeForNotification:notification];
    
    // Ignore unrelated recipe.
    if (![recipe.objectId isEqualToString:recipe.objectId]) {
        return;
    }
    
    // Likes updated?
    if ([EventHelper socialUpdatesHasNumLikes:notification]) {
        BOOL liked = [EventHelper socialUpdatesLiked:notification];
        if (liked) {
            
            // Create a recipe like object for UI updates.
            CKRecipeLike *like = [CKRecipeLike recipeLikeForUser:self.currentUser recipe:self.recipe];
            [self.likes insertObject:like atIndex:0];
            
            [self.likesCollectionView performBatchUpdates:^{
                [self.likesCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            } completion:^(BOOL finished) {
            }];
            
        } else {
            
            // Search for existing like.
            NSInteger likeIndex = [self.likes findIndexWithBlock:^BOOL(CKRecipeLike *like) {
                return [like.user.objectId isEqualToString:self.currentUser.objectId];
            }];
            
            if (likeIndex != -1) {
                
                [self.likes removeObjectAtIndex:likeIndex];
                [self.likesCollectionView performBatchUpdates:^{
                    [self.likesCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:likeIndex inSection:0]]];
                } completion:^(BOOL finished) {
                }];
                
            }
            
            
        }
    }
    
}

@end
