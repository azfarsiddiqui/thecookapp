//
//  CKListEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 30/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListEditViewController.h"
#import "CKEditingTextBoxView.h"
#import "CKListCell.h"
#import "CKListLayout.h"
#import "UICollectionView+Draggable.h"
#import "MRCEnumerable.h"
#import "LSCollectionViewHelper.h"
#import "UIColor+Expanded.h"
#import "CKListHeaderView.h"

@interface CKListEditViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource_Draggable, CKListCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIView *pullToAddView;
@property (nonatomic, strong) UIImageView *pullToAddArrowView;
@property (nonatomic, strong) UILabel *topAddLabel;
@property (nonatomic, strong) UIView *swipeToDeleteView;
@property (nonatomic, strong) UIImageView *swipeToDeleteArrowView;
@property (nonatomic, strong) UILabel *swipeDeleteLabel;
@property (nonatomic, strong) CKListCell *panningCell;
@property (nonatomic, assign) BOOL saveRequired;
@property (nonatomic, assign) BOOL topAddActivated;
@property (nonatomic, assign) BOOL swipeDeleteActivated;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL processing;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic, assign) BOOL isAutoDeleting;

@end

@implementation CKListEditViewController

#define kEditButtonInsets               UIEdgeInsetsMake(20.0, 5.0, 0.0, 5.0)
#define kCellId                         @"ListItemCellId"
#define kHeaderId                       @"ListItemHeaderId"
#define kPlaceholderSize                CGSizeMake(750.0, 70.0)
#define kPullActivatedOffset            150.0
#define kLabelOffset                    10.0
#define kLabelTag                       270
#define kHiddenFieldScrollUpOffset      40.0
#define kHiddenFieldScrollDownOffset    20.0
#define kDeleteOffset                   120.0
#define kInactiveCellFade               0.7
#define kArrowLabelGap                  10.0
#define kLabelArrowGap                  10.0
#define kPullToAddFont                  [UIFont fontWithName:@"BrandonGrotesque-Regular" size:28.0]
#define kSwipeToDeleteFont              [UIFont fontWithName:@"BrandonGrotesque-Regular" size:25.0]
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define kSwipeAlpha                     0.7

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white
                 title:(NSString *)title {
    
    return [self initWithEditView:editView delegate:delegate items:items selectedIndex:nil editingHelper:editingHelper
                            white:white title:title];
}

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
                 items:(NSArray *)items selectedIndex:(NSNumber *)selectedIndexNumber
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title {
    
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title]) {
        if ([items count] > 0) {
            self.items = [NSMutableArray arrayWithArray:items];
        } else {
            self.items = [NSMutableArray arrayWithObject:[self createNewItem]];    // One empty cell if given none
        }
        self.selectedIndexNumber = selectedIndexNumber;
        self.canReorderItems = YES;
        self.canAddItems = YES;
        self.canDeleteItems = YES;
        self.allowSelection = YES;
        self.addItemAfterEach = YES;
        self.allowMultipleSelection = NO;
        self.isAutoDeleting = NO;
    }
    return self;
}

- (void)loadData {
    [self showItems];
}

- (Class)classForListCell {
    return [CKListCell class];
}

- (void)configureCell:(CKListCell *)cell indexPath:(NSIndexPath *)indexPath {
    if (self.itemsLoaded) {
        
        // Allow selection only if the governing EditVC allows it.
        cell.allowSelection = self.allowSelection;
        
        if ([self.items count] > 0) {
            
            // Loading actual item cells.
            [cell configureValue:[self.items objectAtIndex:indexPath.item]
                      selected:([self.selectedIndexNumber integerValue] == indexPath.item)];
            
        } else {
            
            [self setEditing:YES cell:cell];
        }
        
    } else {
        
        // This is the placeholder cell just prior to animating actual cells.
        cell.allowSelection = NO;
        [cell configureValue:nil selected:NO];
        
    }
}

- (id)createNewItem {
    
    // String implementation.
    return @"";
}

- (void)itemsDidShow:(BOOL)show {
    
    // Subclasses to implement.
    if (show) {
        
        DLog(@"show: items[%@] selected[%@]", self.items, self.selectedIndexNumber);
        
        // Update pull labels.
        [self updateAddState];
        
        // Focus on first cell if it was the only empty single cell.
        if ([self.items count] == 1) {
            CKListCell *cell = [self listCellAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            if ([cell isEmpty]) {
                [cell setEditing:YES];
            }
        }
        
    } else {
        
        if (self.saveRequired) {
            
            // Trim items of empty cells.
            self.items = [NSMutableArray arrayWithArray:[self.items select:^BOOL(id currentValue) {
                return ![self isEmptyForValue:currentValue];
            }]];
            
            DLog(@"hide: items[%@] selected[%@]", self.items, self.selectedIndexNumber);
            
            // Calls save on the the textbox view, which in turn triggers update via delegate.
            CKEditingTextBoxView *textBoxView = [self targetEditTextBoxView];
            [textBoxView.delegate editingTextBoxViewSaveTappedForEditingView:self.targetEditView];

        }
        
        // Then dismiss via the parent, be careful not to call self which has been overriden.
        [super dismissEditView];
    }
}

- (void)showItems {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self showItems:YES];
    });
}

- (void)hideItems {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self showItems:NO];
    });
}

- (CGSize)cellSize {
    return kPlaceholderSize;
}

- (NSString *)pullToReleaseTextForActivated:(BOOL)activated {

    return activated ? @"Release to add" : @"Pull to add";
}

- (NSString *)swipeToDeleteTextActivated:(BOOL)activated {
    return activated ? @"Release to delete" : @"Swipe to delete";
}

- (void)addCellToBottom {
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:[self.items count] inSection:0];
    
    [self createNewCellAtIndexPath:nextIndexPath];
//    if ([self.items count] > 1) {
//        [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
//    }
}

- (BOOL)allowedToAdd {
    return YES;
}

#pragma mark - Lifecycle events.

- (void)keyboardWillAppear:(BOOL)appear {
    DLog(@"appear[%@]", appear ? @"YES" : @"NO");
//    self.collectionView.scrollEnabled = !appear;
    
    if (appear) {
        
        CGRect cellFrame = self.editingCell.frame;
        CGRect visibleFrame = (CGRect){
            self.collectionView.contentOffset.x,
            self.collectionView.contentOffset.y,
            self.collectionView.bounds.size.width,
            self.collectionView.bounds.size.height
        };
        visibleFrame.size.height -= self.keyboardFrame.size.height;
        
        // Add the contentInset of the keyboard at the bottom.
        self.collectionView.contentInset = (UIEdgeInsets){ 0.0, 0.0, self.keyboardFrame.size.height + 20, 0.0 };
        
        if (!CGRectContainsPoint(visibleFrame, (CGPoint){ cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height })) {
        
            // Scroll the bottom obscured item up so that the cell sits just above the keyboard
            CGFloat requiredOffset = (self.editingCell.frame.origin.y  + self.editingCell.frame.size.height) - (self.view.frame.size.height - self.keyboardFrame.size.height - kHiddenFieldScrollUpOffset);
            [self.collectionView setContentOffset:(CGPoint){
                self.collectionView.contentOffset.x,
                requiredOffset
            } animated:YES];
            
        } else if (!CGRectContainsPoint(visibleFrame, cellFrame.origin)) {
            
            // Scroll the top obscured item down a bit.
            CGFloat requiredOffset = cellFrame.origin.y - kHiddenFieldScrollDownOffset;
            [self.collectionView setContentOffset:(CGPoint){
                self.collectionView.contentOffset.x,
                requiredOffset
            } animated:YES];
            
        }
        
    } else {
        
        // Restore visibility.
        self.editingCell = nil;
        self.editingIndexPath = nil;
        [self updateCellsState];
        [self setEditing:NO];
        
        // Restore and animate the contentInset.
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.collectionView.contentInset = UIEdgeInsetsZero;
                         }
                         completion:^(BOOL finished) {
                         }];
        
    }
    
}

#pragma mark - CKEditViewController methods

- (UIView *)createTargetEditView {
    UIEdgeInsets contentInsets = [self contentInsets];
    CGSize size = [self cellSize];
    
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                                                       contentInsets.top,
                                                                       size.width,
                                                                       size.height)];
    placeholderView.backgroundColor = [UIColor clearColor];
    return placeholderView;
}

- (UIEdgeInsets)contentInsets {
    return UIEdgeInsetsMake(29.0, 20.0, 0.0, 20.0);
}

- (void)wrapTargetEditView:(UIView *)targetEditView delegate:(id<CKEditingTextBoxViewDelegate>)delegate {
    [self wrapTargetEditView:targetEditView editMode:NO delegate:delegate];
}

- (BOOL)showTitleLabel {
    return YES;
}

- (BOOL)showSaveIcon {
    return NO;
}

- (void)dismissEditView {
    
    // Hide all items then dismiss.
    [self showItems:NO];
}

- (id)updatedValue {
    NSString *value = nil;
    
    if (self.selectedIndexNumber) {
        value = [self.items objectAtIndex:[self.selectedIndexNumber integerValue]];
    }
    
    return value;
}

#pragma mark - UICollectionViewDataSource_Draggable methods

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    CKListCell *listCell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [listCell resignFirstResponder];
    [self currentLayout].dragging = YES;
    return self.canReorderItems;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    [self currentLayout].dragging = YES;
    return self.canReorderItems;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    [self currentLayout].dragging = NO;
    
    id item = [self.items objectAtIndex:fromIndexPath.item];
    [self.items removeObjectAtIndex:fromIndexPath.item];
    [self.items insertObject:item atIndex:toIndexPath.item];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    UIEdgeInsets contentInsets = [self contentInsets];
    UIEdgeInsets sectionInsets = {
        contentInsets.top - targetTextBoxView.contentInsets.top,
        90.0 + 10,
        20.0,
        90.0
    };
    return sectionInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 20.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    return targetTextBoxView.frame.size;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.itemsLoaded) {
        return [self.items count];
    } else {
        return 1;   // Placeholder cell.
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKListCell *cell = (CKListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.allowSelection = self.allowSelection;
    cell.allowReorder = self.canReorderItems;
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    
//    if (self.editingIndexPath) {
//        cell.backgroundView.alpha = ([self.editingIndexPath isEqual:indexPath]) ? 1.0 : kInactiveCellFade;
//    } else {
    cell.backgroundView.alpha = 1.0;
//    }
    
    [self configureCell:cell indexPath:indexPath];
    
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    CKListHeaderView *headerView = (CKListHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId forIndexPath:indexPath];
//    self.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:36.0];
//    self.titleLabel.frame = CGRectMake(0, 10, headerView.frame.size.width, self.titleLabel.frame.size.height);
//    [self.titleLabel sizeToFit];
//    return headerView;
//}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.canAddItems || ![self allowedToAdd]) {
        return;
    }
    
    // Check for top activation.
    if (scrollView.isDragging) {
        
        // Check for add activation.
        BOOL topActivated = (scrollView.contentOffset.y <= -kPullActivatedOffset);
        [self updateAddStateWithActivation:topActivated];
        
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!self.canAddItems || ![self allowedToAdd]) {
        return;
    }
    
    if (self.topAddActivated) {
        self.collectionView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0.0, 0.0, 0.0);
        [self addCellFromTop];
    }
    
}


#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldSelect = !self.editMode;
    shouldSelect = YES;
    
    if (self.editMode) {
        [self.editingCell setEditing:NO];
    }
    
    DLog(@"shouldSelect [%d][%@]", indexPath.item, shouldSelect ? @"YES" : @"NO");
    
    return shouldSelect;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"selectedItem [%d]", indexPath.item);
    
    if (self.allowSelection) {
        
        // Remeber the selected index, and go and unselect all other cells.
        self.selectedIndexNumber = @(indexPath.item);
        for (NSIndexPath *visibleIndexPath in [self.collectionView indexPathsForVisibleItems]) {
            
            // Unselect all others.
            CKListCell *cell = [self listCellAtIndexPath:visibleIndexPath];
            
            // Make sure the current one is selected.
            if ([visibleIndexPath isEqual:indexPath]) {
                if (!cell.selected) {
                    [cell setSelected:YES];
                }
            } else {
                [cell setSelected:NO];
            }
            
        }
        
    }
    
}

#pragma mark - Lifecycle events.

- (void)targetTextEditingViewWillAppear:(BOOL)appear {
    [super targetTextEditingViewWillAppear:appear];
    
    if (appear) {
        
    } else {
        
        [self showButtons:NO animated:NO];
        
        // Remove the real tableView.
        [self.collectionView resignFirstResponder];
        [self.collectionView removeFromSuperview];
        
        // Show placeholders.
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
        self.targetEditView.hidden = NO;
        targetTextBoxView.hidden = NO;
        
    }
}

- (void)targetTextEditingViewDidAppear:(BOOL)appear {
    [super targetTextEditingViewDidAppear:appear];
    
    if (appear) {
        
        // Hide placeholders.
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
        self.targetEditView.hidden = YES;
        targetTextBoxView.hidden = YES;
        
        // Show the real collectionView.
        if (self.canAddItems && [self allowedToAdd]) {
            [self.collectionView addSubview:self.pullToAddView];
            [self updateAddState];
        }
        [self.view addSubview:self.collectionView];
        
        // Show buttons.
        [self showButtons:YES animated:YES];
        
        // Load items.
        [self loadData];
        
    } else {
        
    }
}

#pragma mark - CKListCellDelegate methods

- (BOOL)listItemEmptyForCell:(CKListCell *)cell {
    
    return [self isEmptyForValue:[cell currentValue]];
}

- (void)listItemReturnedForCell:(CKListCell *)cell {
    
    // Cell returned from Done, and start processing.
    [self processCell:cell];
}

- (void)listItemFocused:(BOOL)focused cell:(CKListCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];

    if (focused) {
        self.editingIndexPath = indexPath;
        self.editingCell = cell;
    }
    
    if (self.swipeDeleteActivated) {
        return;
    }
    
    // Mark as not top add activation.
    [self updateAddStateWithActivation:NO];
    
    // Save value if it was not empty.
    if (!focused) {
        
        if (![cell isEmpty]) {
            cell.allowReorder = self.canReorderItems;
            if (!indexPath) {
                indexPath = self.editingIndexPath;
                cell = self.editingCell;
            }
            
            if (indexPath.item < [self.items count] && [self.items objectAtIndex:indexPath.item]) {
                // Save current value if it was not empty.
                [self.items replaceObjectAtIndex:indexPath.item withObject:[cell currentValue]];
            }
        } else {
            //Remove resigning cell if it's blank
            if ([self.items count] > 1 && !self.processing && !self.isAutoDeleting) {
                self.isAutoDeleting = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                    [self deleteCellAtIndexPath:indexPath];
                    self.isAutoDeleting = NO;
                    self.editingIndexPath = nil;
                    [self updateCellsState];
                });
            }
            
        }
        
    } else {
        cell.allowReorder = NO;
        //Clear out any blank cells other than the current one
        if ([self.collectionView numberOfItemsInSection:0] > 1) {
            for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
                CKListCell *listCell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                if ([listCell isEmpty] && indexPath.item != i && !self.isAutoDeleting) {
                    self.isAutoDeleting = YES;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                        [self deleteCellAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                        self.isAutoDeleting = NO;
                        self.editingIndexPath = nil;
                        [self updateCellsState];
                    });
                }
            }
        }
        [self updateCellsState];
        
    }
    
    // Mark as finished processing the current cell.
    if (!focused) {
        self.processing = NO;
    }
    
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        if (!self.canDeleteItems) {
            return NO;
        } else {
            UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gesture;
            CGPoint velocity = [panGesture velocityInView:self.collectionView];
            CGFloat horizontalVelocity = ABS(velocity.x);
            CGFloat verticalVelocity = ABS(velocity.y);
            return (horizontalVelocity > 0 && horizontalVelocity > verticalVelocity);
        }
        
    }
    
    return YES;
}

#pragma mark - Properties

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[CKListLayout alloc] init];
//        [layout setHeaderReferenceSize:CGSizeMake(self.view.bounds.size.width,40)];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.draggable = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.allowsMultipleSelection = self.allowMultipleSelection;
        [_collectionView registerClass:[self classForListCell] forCellWithReuseIdentifier:kCellId];
//        [_collectionView registerClass:[CKListHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId];
        
        // Register pan to delete for cells.
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        panGesture.delegate = self;
        [_collectionView addGestureRecognizer:panGesture];
        
    }
    return _collectionView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [CKEditingViewHelper cancelButtonWithTarget:self selector:@selector(cancelTapped:)];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _cancelButton.frame = CGRectMake(kEditButtonInsets.left,
                                         kEditButtonInsets.top,
                                         _cancelButton.frame.size.width,
                                         _cancelButton.frame.size.height);
    }
    return _cancelButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [CKEditingViewHelper okayButtonWithTarget:self selector:@selector(saveTapped:)];
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _saveButton.frame = CGRectMake(self.view.bounds.size.width - kEditButtonInsets.left - _saveButton.frame.size.width,
                                       kEditButtonInsets.top,
                                       _saveButton.frame.size.width,
                                       _saveButton.frame.size.height);
    }
    return _saveButton;
}

- (UIView *)pullToAddView {
    if (!_pullToAddView) {
        
        // Calculate the required frame.
        CGRect arrowFrame = self.pullToAddArrowView.frame;
        CGRect labelFrame = self.topAddLabel.frame;
        labelFrame.origin.x = self.pullToAddArrowView.frame.origin.x + self.pullToAddArrowView.frame.size.width + kArrowLabelGap;
        CGRect combinedFrame = CGRectUnion(arrowFrame, labelFrame);
        
        // Reposition elements.
        arrowFrame.origin.y = floorf((combinedFrame.size.height - arrowFrame.size.height) / 2.0);
        labelFrame.origin.y = floorf((combinedFrame.size.height - labelFrame.size.height) / 2.0);
        self.pullToAddArrowView.frame = arrowFrame;
        self.topAddLabel.frame = labelFrame;
        
        // Combined container.
        _pullToAddView = [[UIView alloc] initWithFrame:combinedFrame];
        _pullToAddView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _pullToAddView.backgroundColor = [UIColor clearColor];
        [_pullToAddView addSubview:self.pullToAddArrowView];
        [_pullToAddView addSubview:self.topAddLabel];
        
    }
    return _pullToAddView;
}

- (UIImageView *)pullToAddArrowView {
    if (!_pullToAddArrowView) {
        _pullToAddArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_customise_textbox_icon_pulladd.png"]];
    }
    return _pullToAddArrowView;
}

- (UILabel *)topAddLabel {
    if (!_topAddLabel) {
        _topAddLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topAddLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _topAddLabel.backgroundColor = [UIColor clearColor];
        _topAddLabel.textColor = [UIColor whiteColor];
        _topAddLabel.font = kPullToAddFont;
        _topAddLabel.text = [self pullToReleaseTextForActivated:NO];
        [_topAddLabel sizeToFit];
    }
    return _topAddLabel;
}

- (UIView *)swipeToDeleteView {
    if (!_swipeToDeleteView) {
        
        // Calculate the required frame.
        CGRect arrowFrame = self.swipeToDeleteArrowView.frame;
        CGRect labelFrame = self.swipeDeleteLabel.frame;
        arrowFrame.origin.x = labelFrame.origin.x + labelFrame.size.width + kLabelArrowGap;
        CGRect combinedFrame = CGRectUnion(labelFrame, arrowFrame);
        
        // Reposition elements.
        labelFrame.origin.y = floorf((combinedFrame.size.height - labelFrame.size.height) / 2.0);
        arrowFrame.origin.y = floorf((combinedFrame.size.height - arrowFrame.size.height) / 2.0) + 2.0;
        self.swipeToDeleteArrowView.frame = arrowFrame;
        self.swipeDeleteLabel.frame = labelFrame;
        
        // Combined container.
        _swipeToDeleteView = [[UIView alloc] initWithFrame:combinedFrame];
        _swipeToDeleteView.backgroundColor = [UIColor clearColor];
        [_swipeToDeleteView addSubview:self.swipeDeleteLabel];
        [_swipeToDeleteView addSubview:self.swipeToDeleteArrowView];
    }
    return _swipeToDeleteView;
}

- (UIImageView *)swipeToDeleteArrowView {
    if (!_swipeToDeleteArrowView) {
        _swipeToDeleteArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_customise_textbox_icon_swipedelete.png"]];
    }
    return _swipeToDeleteArrowView;
}

- (UILabel *)swipeDeleteLabel {
    if (!_swipeDeleteLabel) {
        _swipeDeleteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _swipeDeleteLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _swipeDeleteLabel.backgroundColor = [UIColor clearColor];
        _swipeDeleteLabel.textColor = [UIColor colorWithHexString:@"FA4E6F"];
        _swipeDeleteLabel.text = [self swipeToDeleteTextActivated:NO];
        _swipeDeleteLabel.font = kPullToAddFont;
        [_swipeDeleteLabel sizeToFit];
    }
    return _swipeDeleteLabel;
}

#pragma mark - Private methods

- (UIButton *)buttonWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    return button;
}

- (void)saveTapped:(id)sender {
    [self saveAndDismissItems:YES];
}

- (void)cancelTapped:(id)sender {
    
    // Turn of delegate callbacks.
    if (self.editingCell) {
        self.editingCell.delegate = nil;
    }
    
    [self saveAndDismissItems:NO];
}

- (void)saveAndDismissItems:(BOOL)save {
    self.saveRequired = save;
    
    // Hide items, which will trigger itemsDidShow.
    [self hideItems];
}

- (void)showButtons:(BOOL)show animated:(BOOL)animated {
    
    if (animated) {
        
        if (show) {
            self.saveButton.alpha = 0.0;
            self.cancelButton.alpha = 0.0;
            [self.view addSubview:self.saveButton];
            [self.view addSubview:self.cancelButton];
        }
        
        // Fade them in.
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.saveButton.alpha = show ? 1.0 : 0.0;
                             self.cancelButton.alpha = show ? 1.0 : 0.0;
                         }
                         completion:^(BOOL finished) {
                             if (!show) {
                                 [self.saveButton removeFromSuperview];
                                 [self.cancelButton removeFromSuperview];
                             }
                         }];
        
    } else {
        if (show) {
            [self.view addSubview:self.saveButton];
            [self.view addSubview:self.cancelButton];
        } else {
            [self.saveButton removeFromSuperview];
            [self.cancelButton removeFromSuperview];
        }
    }
    
}

- (void)showItems:(BOOL)show {
    
    // If hiding, make sure we hide it from the zero contentOffset to match up with the placeholder.
    if (!show && self.collectionView.contentOffset.y != 0) {
        [self.collectionView setContentOffset:CGPointZero animated:YES];
    }
    self.itemsLoaded = show;
    
    // There is at least one item - the empty cell.
    NSInteger numItems = [self.items count];
    
    // Items to animate is everything below the initial placeholder.
    __block NSMutableArray *itemsToAnimate = [NSMutableArray arrayWithCapacity:numItems];
    for (NSInteger itemIndex = 1; itemIndex < numItems; itemIndex++) {
        if (itemIndex > 0 && itemIndex < [self.items count])
            [itemsToAnimate addObject:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
    }
    //If delete, just reload. Workaround for http://openradar.appspot.com/12954582 on UICollectionViews
    if (!show)
    {
        [self.collectionView reloadData];
        [self itemsDidShow:show];
    }
    else
    {
        // Perform the insert animation
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            if ([itemsToAnimate count] > 0) {
                [self.collectionView insertItemsAtIndexPaths:itemsToAnimate];
            }
        } completion:^(BOOL finished) {
            
            if (show && self.selectedIndexNumber) {
                
                NSInteger selectedIndex = [self.selectedIndexNumber integerValue];
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]
                                                  animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }
            
            // Lifecycle events.
            [self itemsDidShow:show];
        }];
    }
}

- (CKListLayout *)currentLayout {
    return (CKListLayout *)self.collectionView.collectionViewLayout;
}

- (void)updateAddStateWithActivation:(BOOL)activated {
    if (self.topAddActivated == activated) {
        return;
    }
    self.topAddActivated = activated;
    [self updateAddState];
}

- (void)updateAddState {
    if (!self.canAddItems || ![self allowedToAdd]) {
        self.topAddLabel.text = @"";
        return;
    }
    
    // Top add
    self.topAddLabel.text = [self pullToReleaseTextForActivated:self.topAddActivated];
    [self.topAddLabel sizeToFit];
    self.pullToAddView.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - self.topAddLabel.frame.size.width) / 2.0) - self.pullToAddArrowView.frame.size.width - kArrowLabelGap,
        -self.pullToAddView.frame.size.height - kLabelOffset,
        self.pullToAddView.frame.size.width,
        self.pullToAddView.frame.size.height
    };
    
    // Arrow update.
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.4];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    self.pullToAddArrowView.layer.transform = self.topAddActivated ? CATransform3DMakeRotation(RADIANS(180), 1.0, 0.0, 0.0) : CATransform3DIdentity;
    [CATransaction commit];
    
}

- (NSInteger)integerForIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:kLabelTag];
    return [label.text integerValue];
}

- (void)panned:(UIPanGestureRecognizer *)panGesture {
    CGPoint location = [panGesture locationInView:self.collectionView];
    
    // Attempt to get any panning cell.
    if (!self.panningCell) {
        NSIndexPath *indexPath =  [self.collectionView indexPathForItemAtPoint:location];
        if (indexPath) {
            CKListCell *cell = [self listCellAtIndexPath:indexPath];
            self.panningCell = cell;
        }
    }
    
    // Ignore if no panning cell was detected.
    if (!self.panningCell) {
        return;
    }
    
    // Process the panning.
    CGFloat dragRatio = 0.5;
    CGPoint translation = [panGesture translationInView:self.collectionView];
    CGFloat panOffset = ceilf(translation.x * dragRatio);
//    DLog(@"translation %@", NSStringFromCGPoint(translation));
//    DLog(@"panOffset %f", panOffset);
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        // Add the arrow.
        CGRect arrowFrame = self.swipeToDeleteView.frame;
        arrowFrame.origin.x = self.panningCell.frame.origin.x - arrowFrame.size.width;
        arrowFrame.origin.y = self.panningCell.frame.origin.y + floorf((self.panningCell.frame.size.height - arrowFrame.size.height) / 2.0);
        self.swipeToDeleteView.frame = arrowFrame;
        self.swipeToDeleteView.alpha = 0.0;
        [self.collectionView addSubview:self.swipeToDeleteView];
        
        // Fade it in.
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.swipeToDeleteView.alpha =1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
        
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        // Drag the cell around.
        self.swipeToDeleteView.transform = CGAffineTransformMakeTranslation(panOffset, 0.0);
        self.panningCell.transform = CGAffineTransformMakeTranslation(panOffset, 0.0);
        
        // Fade the cell if it was delete detected.
        if (panOffset > kDeleteOffset) {
            
            // Activate swipe delete.
            if (!self.swipeDeleteActivated) {
                
                // Mark as swipe delete activated.
                self.swipeDeleteActivated = YES;
                
                // Update text.
                [self updateSwipeToDeleteLabel];
                
                // Arrow update.
                if (CATransform3DEqualToTransform(self.swipeToDeleteArrowView.layer.transform, CATransform3DIdentity)) {
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:0.2];
                    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
                    self.swipeToDeleteArrowView.layer.transform = CATransform3DMakeRotation(RADIANS(180), 0.0, 1.0, 0.0);
                    [CATransaction commit];
                }
                
                self.panningCell.alpha = kSwipeAlpha;
            }
            
            
        } else {
            
            // Deactive swipe delete.
            if (self.swipeDeleteActivated) {
                
                self.swipeDeleteActivated = NO;
                
                // Update text.
                [self updateSwipeToDeleteLabel];
                
                // Arrow update.
                if (!CATransform3DEqualToTransform(self.swipeToDeleteArrowView.layer.transform, CATransform3DIdentity)) {
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:0.2];
                    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
                    self.swipeToDeleteArrowView.layer.transform = CATransform3DIdentity;
                    [CATransaction commit];
                }
                
                self.panningCell.alpha = 1.0;
            }
        }
        
    } else  {
        
        // Have we exceed offset to delete.
        if (self.swipeDeleteActivated) {
            
            // Add a new item after this last cell has been deleted.
            BOOL addNew = ([self.items count] == 1);
            
            // Delete the cell, and optionally create a new one.
            [self deleteCell:self.panningCell addNew:addNew];
            
        } else {
            
            // Else snap right back.
            [self restoreTransformForCell:self.panningCell];
        }
    }

}

- (void)deleteCell:(CKListCell *)cell addNew:(BOOL)addNew {
    if (!self.canDeleteItems || !cell) {
        return;
    }
    
    NSIndexPath *deleteIndexPath = [self.collectionView indexPathForCell:cell];
    
    // Delete from model.
    [self.items removeObjectAtIndex:deleteIndexPath.item];
    
    // Fade arrow out.
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.swipeToDeleteView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         // Remove the arrow.
                         [self.swipeToDeleteView removeFromSuperview];
                         
                         [self.collectionView performBatchUpdates:^{
                             // Delete the cell.
                             [self.collectionView deleteItemsAtIndexPaths:@[deleteIndexPath]];
                             
                         } completion:^(BOOL finished) {
                             
                             // Restore state of swipes.
                             self.swipeToDeleteView.transform = CGAffineTransformIdentity;
                             self.swipeToDeleteArrowView.layer.transform = CATransform3DIdentity;
                             self.swipeDeleteActivated = NO;
                             [self updateSwipeToDeleteLabel];
                             
                             self.panningCell = nil;
                             
                             if (addNew) {
                                 [self createNewCellAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                             }
                             if ([self.items count] > 1 && self.editingIndexPath > 0) {
                                 self.editingIndexPath = [NSIndexPath indexPathForItem:self.editingIndexPath.item - 1 inSection:0];
                             }

                         }];
                         
                     }];
    
}

- (void)restoreTransformForCell:(CKListCell *)cell {
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.swipeToDeleteView.transform = CGAffineTransformIdentity;
                         self.swipeToDeleteView.alpha = 0.0;
                         cell.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         // Restore state of swipes.
                         self.swipeToDeleteView.transform = CGAffineTransformIdentity;
                         self.swipeToDeleteArrowView.layer.transform = CATransform3DIdentity;
                         self.swipeDeleteActivated = NO;
                         [self updateSwipeToDeleteLabel];
                         
                         self.panningCell = nil;
                     }];
    
}

- (void)setEditing:(BOOL)editing {
    self.editMode = editing;
    [self updateAddState];
}

- (void)setEditing:(BOOL)editing cell:(CKListCell *)cell {
    [self setEditing:editing];
    [cell setEditing:editing];
}

- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"Deleting item [%ld] items %@", indexPath.item, self.items);
    
    if (!self.swipeDeleteActivated && indexPath && !self.saveRequired) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [self.items removeObjectAtIndex:indexPath.item];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            } completion:^(BOOL finished) {
                //If only cell just got deleted and adding a new one, manually set editing index to it
                if ([self.items count] <=1) {
                    self.editingIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                }
                [self updateCellsState];
            }];
        });
    }
}

- (void)addCellFromTop {
    if (!self.canAddItems || ![self allowedToAdd]) {
        return;
    }
    
    // Mark as adding mode and turn off activation mode.
    self.topAddActivated = NO;
    
    if (self.editingIndexPath && ![self.editingCell isEmpty] && self.editingIndexPath.item < [self.items count] && [self.items objectAtIndex:self.editingIndexPath.item]) {
        [self.items replaceObjectAtIndex:self.editingIndexPath.item withObject:[self.editingCell currentValue]];
    }
    
    // Insert an empty item at front.
    [self.items insertObject:[self createNewItem] atIndex:0];
    
    // Index path of new item at top.
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    self.editingIndexPath = indexPath;
    [self.collectionView performBatchUpdates:^{
        
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.collectionView.contentInset = UIEdgeInsetsZero;
                             }
                             completion:^(BOOL finished) {
                                 
                                 // Set editing on the new cell.
                                 CKListCell *cell = [self listCellAtIndexPath:indexPath];
                                 [self setEditing:YES cell:cell];
                                 
                             }];
        });
    }];
}


- (void)createNewCellAtIndexPath:(NSIndexPath *)indexPath {
    
    // Insert an empty item at the requested position.
    DLog(@"Inserting item at index: %i", indexPath.item);
    [self.items insertObject:[self createNewItem] atIndex:indexPath.item];
    
    [self.collectionView performBatchUpdates:^{
        
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        
        CKListCell *cell = [self listCellAtIndexPath:indexPath];
        self.editingCell = cell;
        [self setEditing:YES cell:cell];
        self.editingIndexPath = indexPath;
        [self updateAddState];
        
    }];

}

- (void)processCell:(CKListCell *)cell {
    
    // Mark as processing cell.
    self.processing = YES;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DLog(@"processCell item[%d]", indexPath.item);
    
    // Empty cell?
//    if ([cell isEmpty]) {
//        
//        if ([self.items count] < 2) {
//            // Last empty cell, just unfocus.
//            [cell setEditing:NO];
//            [self updateCellsState];
//        }
//        
//    } else {
    
        // Get the current value and update the items array.
        id currentValue = [cell currentValue];
        [self.items replaceObjectAtIndex:indexPath.item withObject:currentValue];
        
        // Grab the next indexpath, be it to create or focus on.
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
        
        // Add item after every resign?
        if (self.addItemAfterEach) {
            
            // Check if the insertion point already contains an empty slot.
            if (nextIndexPath.item < [self.items count]) {
                
                CKListCell *currentCell = [self listCellAtIndexPath:nextIndexPath];
                
                // Only add if the cell after next is not empty.
                if (currentCell && ![currentCell isEmpty]) {
                    //[self createNewCellAtIndexPath:nextIndexPath];
                    CKListCell *nextCell = [self listCellAtIndexPath:nextIndexPath];
                    [nextCell setEditing:YES];
                }
                
            } else {
                [self addCellToBottom];
            }
            
        } else {
            
            if (indexPath.item == [self.items count] - 1) {
                [self addCellToBottom];
                
            } else {
                
                // Move to next cell.
                CKListCell *nextCell = [self listCellAtIndexPath:nextIndexPath];
                [nextCell setEditing:YES];
            }
            
        }
        
//    }
}

- (BOOL)isEmptyForValue:(id)currentValue {
    
    // NSString comparison implementation.
    NSString *text = [currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ([text length] == 0);

}

- (void)updateCellsState {
    
    // Fade out all other cells.
//    NSArray *visibleCells = [self.collectionView visibleCells];
//    for (UICollectionViewCell *cell in visibleCells) {
//        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
//        
//        if (self.editingIndexPath) {
//            cell.backgroundView.alpha = ([self.editingIndexPath isEqual:indexPath]) ? 1.0 : kInactiveCellFade;
//        } else {
//            cell.backgroundView.alpha = [((CKListCell *)cell) isFirstResponder] ? 1.0 : kInactiveCellFade;
//        }
//    }
}

- (void)updateSwipeToDeleteLabel {
    CGRect beforeFrame = self.swipeDeleteLabel.frame;
    self.swipeDeleteLabel.text = [self swipeToDeleteTextActivated:self.swipeDeleteActivated];
    [self.swipeDeleteLabel sizeToFit];
    CGRect frame = self.swipeDeleteLabel.frame;
    CGFloat xOffset = beforeFrame.size.width - frame.size.width;
    frame.origin.x += xOffset;
    self.swipeDeleteLabel.frame = frame;
}

- (CKListCell *)listCellAtIndexPath:(NSIndexPath *)indexPath {
    return (CKListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

// Fixes the missing action method when the keyboard is visible
#import <objc/runtime.h>
#import <objc/message.h>
__attribute__((constructor)) static void PSPDFFixCollectionViewUpdateItemWhenKeyboardIsDisplayed(void) {
    @autoreleasepool {
        if ([UICollectionViewUpdateItem class] == nil) return; // pre-iOS6.
        if (![UICollectionViewUpdateItem instancesRespondToSelector:@selector(action)]) {
            IMP updateIMP = imp_implementationWithBlock(^(id _self) {});
            Method method = class_getInstanceMethod([UICollectionViewUpdateItem class], @selector(action));
            const char *encoding = method_getTypeEncoding(method);
            if (!class_addMethod([UICollectionViewUpdateItem class], @selector(action), updateIMP, encoding)) {
                NSLog(@"Failed to add action: workaround");
            }
        }
    }
}

@end
