//
//  CKViewController.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "BenchtopCollectionViewController.h"
#import "BenchtopCollectionFlowLayout.h"
#import "BenchtopBookCoverViewCell.h"
#import "CKUser.h"
#import "CKBook.h"
#import "EventHelper.h"
#import "CoverPickerViewController.h"
#import "IllustrationPickerViewController.h"
#import "ViewHelper.h"

@interface BenchtopCollectionViewController () <UIActionSheetDelegate, BenchtopBookCoverViewCellDelegate,
    CoverPickerViewControllerDelegate, IllustrationPickerViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) CKBook *myBook;
@property (nonatomic, strong) NSMutableArray *followBooks;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) CoverPickerViewController *coverViewController;
@property (nonatomic, strong) IllustrationPickerViewController *illustrationViewController;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL deleteMode;
@property (nonatomic, strong) UIImageView *overlayView;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation BenchtopCollectionViewController

#define kCellId         @"BenchtopCellId"
#define kMySection      0
#define kFollowSection  1

- (void)dealloc {
    [EventHelper unregisterFollowUpdated:self];
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
}

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[BenchtopCollectionFlowLayout alloc] init]]) {
        [EventHelper registerFollowUpdated:self selector:@selector(followUpdated:)];
        [EventHelper registerLoginSucessful:self selector:@selector(loginPerformed:)];
        [EventHelper registerLogout:self selector:@selector(loggedOut:)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBackground];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[BenchtopBookCoverViewCell class] forCellWithReuseIdentifier:kCellId];
    
    // Register longpress.
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(longPressed:)];
    [self.collectionView addGestureRecognizer:longPressGesture];
    
    // Register tap to dismiss.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)enable:(BOOL)enable {
    
    // Enable scrolling as appropriate.
    self.collectionView.userInteractionEnabled = enable;
    
    if (enable) {
        
        // Start loading my book if not there already.
        NSInteger numMyBooks = [self.collectionView numberOfItemsInSection:kMySection];
        if (numMyBooks == 0) {
            [self loadMyBook];
        }
        
        // Load following books if not there already.
        if ([self.followBooks count] == 0) {
            [self loadFollowBooks];
        }
        
    }
}

- (void)bookWillOpen:(BOOL)open {
    
    // Hide the bookCover.
    if (open) {
        BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:self.selectedIndexPath];
        cell.bookCoverView.hidden = YES;
    }
}

- (void)bookDidOpen:(BOOL)open {
    
    // Restore the bookCover.
    if (!open) {
        BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:self.selectedIndexPath];
        cell.bookCoverView.hidden = NO;
    }
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // No book opening in edit mode.
    if (self.editMode) {
        return;
    }
    
    // Only open book if book was in the center.
    if ([self isCenterBookAtIndexPath:indexPath]) {
        
        self.selectedIndexPath = indexPath;
        [self openBookAtIndexPath:indexPath];

    } else {
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:YES];
    }
    
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [BenchtopBookCoverViewCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == kMySection) {
        
        // Shift my book up when in edit mode.
        return self.editMode ? UIEdgeInsetsMake(155.0, 362.0, 230.0, 0.0) : UIEdgeInsetsMake(155.0, 362.0, 155.0, 0.0);
        
    } else if (section == kFollowSection) {
        
        // Part the follow books away if in edit mode.
        return self.editMode ? UIEdgeInsetsMake(155.0, 362.0, 155.0, 362.0) : UIEdgeInsetsMake(155.0, 300.0, 155.0, 362.0);
        
    } else {
        return UIEdgeInsetsZero;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self.followBooks count] == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    switch (section) {
        case kMySection:
            numItems = self.myBook ? 1 : 0;
            break;
        case kFollowSection:
            numItems = [self.followBooks count];
            break;
        default:
            break;
    }
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCoverViewCell *cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                               forIndexPath:indexPath];
    cell.delegate = self;
    
    if (indexPath.section == kMySection) {
        [cell loadBook:self.myBook];
        
    } else if (indexPath.section == kFollowSection) {
        CKBook *book = [self.followBooks objectAtIndex:indexPath.item];
        [cell loadBook:book];
    }
    
    return cell;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"Item %d", buttonIndex);
    switch (buttonIndex) {
        case 0:
            [self unfollowBookAtIndexPath:self.selectedIndexPath];
            break;
        case 1:
            [self openBookAtIndexPath:self.selectedIndexPath];
            break;
        default:
            break;
    }
}

#pragma mark - BenchtopBookCoverViewCellDelegate methods

- (void)benchtopBookEditTappedForCell:(UICollectionViewCell *)cell {
    [self enableEditMode:YES];
}

#pragma mark - CoverPickerViewControllerDelegate methods

- (void)coverPickerCancelRequested {

    // Revert to previous illustration/cover.
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.illustration = self.illustrationViewController.illustration;
    self.myBook.cover = self.coverViewController.cover;
    [cell loadBook:self.myBook];
    
    // Reload the illustration cover.
    [self.illustrationViewController changeCover:self.coverViewController.cover];
    
    [self enableEditMode:NO];
}

- (void)coverPickerDoneRequested {
    
    // TODO save author and title.
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.caption = [cell.bookCoverView currentCaptionThenResign];
    [self.myBook saveInBackground];
    
    [cell loadBook:self.myBook];
    [self enableEditMode:NO];
}

- (void)coverPickerSelected:(NSString *)cover {
    
    // Force reload my book with the selected illustration.
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.cover = cover;
    [cell loadBook:self.myBook];
    
    // Reload the illustration covers.
    [self.illustrationViewController changeCover:cover];
}

#pragma mark - IllustrationPickerViewControllerDelegate methods

- (void)illustrationSelected:(NSString *)illustration {
    
    // Force reload my book with the selected illustration.
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.illustration = illustration;
    [cell loadBook:self.myBook];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        
        // Recognise taps only when collectionView is disabled.
        return (!self.collectionView.userInteractionEnabled);
        
    }
    return NO;
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"] && [object isKindOfClass:[UICollectionView class]]) {
        
        // Delete button follows the book.
        BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:self.selectedIndexPath];
        CGRect frame = [self.collectionView convertRect:cell.frame toView:self.overlayView];
        self.deleteButton.frame = CGRectMake(frame.origin.x - floorf(self.deleteButton.frame.size.width / 2.0) + 5.0,
                                        frame.origin.y - floorf(self.deleteButton.frame.size.height / 2.0) + 5.0,
                                        self.deleteButton.frame.size.width,
                                        self.deleteButton.frame.size.height);

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private methods

- (void)initBackground {
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_whole.png"]];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, backgroundView.frame.size.width, backgroundView.frame.size.height);
    self.view.clipsToBounds = NO;
    [self.view insertSubview:backgroundView belowSubview:self.collectionView];
    self.backgroundView = backgroundView;
}

- (void)loadMyBook {
    CKUser *currentUser = [CKUser currentUser];
    [CKBook fetchBookForUser:currentUser
                success:^(CKBook *book) {
                    
                    if (self.myBook) {
                        
                        // Reload the book.
                        self.myBook = book;
                        BenchtopBookCoverViewCell *myBookCell = [self myBookCell];
                        [myBookCell loadBook:book];
                        
                        
                    } else {
                        self.myBook = book;
                        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:kMySection]]];
                    }
                    
                }
                failure:^(NSError *error) {
                    DLog(@"Error: %@", [error localizedDescription]);
                }];
}

- (void)loadFollowBooks {
    
    CKUser *currentUser = [CKUser currentUser];
    
    if ([currentUser isSignedIn]) {
        [CKBook followBooksForUser:currentUser
                           success:^(NSArray *books) {
                               self.followBooks = [NSMutableArray arrayWithArray:books];
                               if ([books count] > 0) {
                                   NSInteger numSections = [self.collectionView numberOfSections];
                                   if (numSections > 1) {
                                       [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
                                   } else {
                                       [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
                                   }
                               }
                           }
                           failure:^(NSError *error) {
                               DLog(@"Error: %@", [error localizedDescription]);
                           }];
    } else {
        
        [self.followBooks removeAllObjects];
        NSInteger numSections = [self.collectionView numberOfSections];
        if (numSections > 1) {
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
        }
    }
}

- (void)loginPerformed:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    if (success) {
        [self loadMyBook];
    }
}

- (void)loggedOut:(NSNotification *)notification {
    
    // Reload book.
    [self loadMyBook];
    
    // Reload follows books
    [self loadFollowBooks];
}

- (void)openBookAtIndexPath:(NSIndexPath *)indexPath {
    CKBook *book = (indexPath.section == kMySection) ? self.myBook : [self.followBooks objectAtIndex:indexPath.item];
    [self.delegate openBookRequestedForBook:book];
}

- (void)unfollowBookAtIndexPath:(NSIndexPath *)indexPath {
    
    CKBook *book = [self.followBooks objectAtIndex:indexPath.item];
    CKUser *currentUser = [CKUser currentUser];
    
    // Kick off the immediate removal of the book onscreen.
    [self.followBooks removeObjectAtIndex:indexPath.item];
    [self.collectionView performBatchUpdates:^{
        if ([self.followBooks count] == 0) {
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
        } else {
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
        }
    } completion:^(BOOL finished) {
    }];
    
    // Unfollow in the background, then inform listeners of the update.
    BOOL isFriendsBook = [book isFriendsBook];
    [book removeFollower:currentUser
                 success:^{
                     [EventHelper postFollow:NO friends:isFriendsBook];
                 } failure:^(NSError *error) {
                     DLog(@"Unable to unfollow.");
                 }];
    
}

- (void)followUpdated:(NSNotification *)notification {
    BOOL follow = [EventHelper followForNotification:notification];
    if (follow) {
        [self loadFollowBooks];
    }
}

- (void)enableEditMode:(BOOL)enable {
    
    // Ignore if we're already animating.
    if (self.animating) {
        return;
    }
    
    // Ignore if we're already in editMode.
    if (self.editMode && enable) {
        return;
    }
    
    self.animating = YES;
    self.editMode = enable;
    self.collectionView.scrollEnabled = !enable;
    
    if (enable) {
        
        // Edit overlay
        UIImageView *editOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_overlay.png"]];
        editOverlayView.alpha = 0.0;
        [self.view addSubview:editOverlayView];
        self.overlayView = editOverlayView;
        
        // Cover
        CoverPickerViewController *coverViewController = [[CoverPickerViewController alloc] initWithCover:self.myBook.cover delegate:self];
        coverViewController.view.frame = CGRectMake(0.0,
                                                    -coverViewController.view.frame.size.height,
                                                    self.view.bounds.size.width,
                                                    coverViewController.view.frame.size.height);
        [self.view addSubview:coverViewController.view];
        self.coverViewController = coverViewController;
        
        // Illustration.
        IllustrationPickerViewController *illustrationViewController = [[IllustrationPickerViewController alloc] initWithIllustration:self.myBook.illustration cover:self.myBook.cover delegate:self];
        illustrationViewController.view.frame = CGRectMake(0.0,
                                                           self.view.bounds.size.height,
                                                           self.view.bounds.size.width,
                                                           illustrationViewController.view.frame.size.height);
        [self.view addSubview:illustrationViewController.view];
        self.illustrationViewController = illustrationViewController;
    }
    
    CGFloat bounceOffset = 20.0;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Tell the layout to go into edit mode.
                         BenchtopCollectionFlowLayout *layout = (BenchtopCollectionFlowLayout *)self.collectionView.collectionViewLayout;
                         [layout invalidateLayout];
                         
                         // Inform delegate
                         [self.delegate editBookRequested:enable];
                         
                         // Fade the edit overlay.
                         self.overlayView.alpha = enable ? 1.0 : 0.0;

                         // Slide down the cover picker.
                         self.coverViewController.view.transform = enable ? CGAffineTransformMakeTranslation(0.0, self.coverViewController.view.frame.size.height) : CGAffineTransformIdentity;
                         
                         // Slide up illustration picker with bounce.
                         self.illustrationViewController.view.transform = enable ? CGAffineTransformMakeTranslation(0.0, -self.illustrationViewController.view.frame.size.height - bounceOffset) : CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         
                         if (enable) {
                             [UIView animateWithDuration:0.3
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  
                                                  // Restore illustration picker after bounce.
                                                  self.illustrationViewController.view.transform = CGAffineTransformTranslate(self.illustrationViewController.view.transform, 0.0, bounceOffset);
                                              } completion:^(BOOL finished) {
                                                  self.animating = NO;
                                              }];
                         } else {
                             self.animating = NO;
                             [self.overlayView removeFromSuperview];
                             [self.coverViewController.view removeFromSuperview];
                             [self.illustrationViewController.view removeFromSuperview];
                             self.overlayView = nil;
                             self.coverViewController = nil;
                             self.illustrationViewController = nil;
                         }
                     }];
}

- (BenchtopBookCoverViewCell *)myBookCell {
    return [self bookCellAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kMySection]];
}

- (BenchtopBookCoverViewCell *)bookCellAtIndexPath:(NSIndexPath *)indexPath {
    return (BenchtopBookCoverViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)longPressed:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPressGesture locationInView:self.collectionView]];
        
        if (indexPath != nil) {
            
            // Delete mode when in Follow section.
            if (indexPath.section == kFollowSection) {
                
                // Scroll to center, then enable delete mode.
                [self.collectionView scrollToItemAtIndexPath:indexPath
                                            atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                    animated:YES];
                [self setDeleteMode:YES indexPath:indexPath];
            }
        }
    }
}

- (BOOL)isCenterBookAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    return (CGRectContainsPoint(attributes.frame,
                                CGPointMake(self.collectionView.contentOffset.x + (self.collectionView.bounds.size.width / 2.0),
                                            self.collectionView.center.y)));
}

- (void)setDeleteMode:(BOOL)enable indexPath:(NSIndexPath *)indexPath {
    
    BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:indexPath];
    [cell enableDeleteMode:enable];
    
    if (enable) {
        
        // Tell root VC to disable panning.
        [self.delegate panEnabledRequested:NO];
        
        // Dim overlay view.
        UIImageView *overlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_overlay.png"]];
        overlayView.alpha = 0.0;
        overlayView.userInteractionEnabled = YES;
        [self.view addSubview:overlayView];
        self.overlayView = overlayView;
        
        // Register gestures to dimiss.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteDismissedByTap:)];
        [overlayView addGestureRecognizer:tapGesture];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(deleteDismissedByPan:)];
        [overlayView addGestureRecognizer:panGesture];
        
        // Remember the cell to be deleted.
        self.selectedIndexPath = indexPath;
        
        // Position the delete button.
        CGRect frame = [self.collectionView convertRect:cell.frame toView:overlayView];
        UIButton *deleteButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_cancel.png"]
                                                      target:self
                                                    selector:@selector(deleteTapped:)];
        deleteButton.frame = CGRectMake(frame.origin.x - floorf(deleteButton.frame.size.width / 2.0) + 5.0,
                                        frame.origin.y - floorf(deleteButton.frame.size.height / 2.0) + 5.0,
                                        deleteButton.frame.size.width,
                                        deleteButton.frame.size.height);
        [overlayView addSubview:deleteButton];
        deleteButton.alpha = 0.0;
        self.deleteButton = deleteButton;
        
        // Watch the cell frame.
        [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
    } else {
        
        // Remove observer.
        [self.collectionView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Fade the edit overlay.
                         self.overlayView.alpha = enable ? 1.0 : 0.0;
                         
                         // Fade the delete button.
                         self.deleteButton.alpha = enable ? 1.0 : 0.0;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         // Remember delete mode.
                         self.deleteMode = enable;
                         
                         if (!enable) {
                             [self.overlayView removeFromSuperview];
                             [self.deleteButton removeFromSuperview];
                             self.overlayView = nil;
                             self.deleteButton = nil;
                             self.selectedIndexPath = nil;
                             
                             // Tell root VC to re-enable panning.
                             [self.delegate panEnabledRequested:YES];
                             
                         }
                         
                     }];
}

- (void)deleteDismissedByTap:(UITapGestureRecognizer *)tapGesture {
    [self setDeleteMode:NO indexPath:self.selectedIndexPath];
}

- (void)deleteDismissedByPan:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self setDeleteMode:NO indexPath:self.selectedIndexPath];
    }
}

- (void)deleteTapped:(id)sender {
    [self unfollowBookAtIndexPath:self.selectedIndexPath];
    [self setDeleteMode:NO indexPath:self.selectedIndexPath];
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    [self.delegate panToBenchtopForSelf:self];
}

@end
