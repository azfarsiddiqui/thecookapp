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

@interface CKListEditViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource_Draggable, CKListCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UILabel *topAddLabel;
@property (nonatomic, strong) CKListCell *panningCell;
@property (nonatomic, assign) BOOL itemsLoaded;
@property (nonatomic, assign) BOOL saveRequired;
@property (nonatomic, assign) BOOL topAddActivated;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL processing;

@end

@implementation CKListEditViewController

#define kEditButtonInsets               UIEdgeInsetsMake(20.0, 5.0, 0.0, 5.0)
#define kCellId                         @"ListItemCellId"
#define kPlaceholderSize                CGSizeMake(750.0, 70.0)
#define kPullActivatedOffset            150.0
#define kLabelOffset                    10.0
#define kLabelTag                       270
#define kHiddenFieldScrollUpOffset      40.0
#define kHiddenFieldScrollDownOffset    20.0
#define kDeleteOffset                   100.0

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
            CKListCell *cell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
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
        self.collectionView.contentInset = (UIEdgeInsets){ 0.0, 0.0, self.keyboardFrame.size.height, 0.0 };
        
        if (!CGRectContainsPoint(visibleFrame, (CGPoint){ cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height })) {
        
            // Scroll the bottom obscured item up a bit.
            CGFloat requiredOffset = cellFrame.origin.y - self.keyboardFrame.size.height + kHiddenFieldScrollUpOffset;
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
    return UIEdgeInsetsMake(35.0, 20.0, 0.0, 20.0);
}

- (void)wrapTargetEditView:(UIView *)targetEditView delegate:(id<CKEditingTextBoxViewDelegate>)delegate {
    [self wrapTargetEditView:targetEditView editMode:NO delegate:delegate];
}

- (BOOL)showTitleLabel {
    return NO;
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
    [self currentLayout].dragging = YES;
    return self.canReorderItems;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    [self currentLayout].dragging = YES;
    return self.canReorderItems;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
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
    UIEdgeInsets sectionInsets = { contentInsets.top - targetTextBoxView.contentInsets.top, 90.0 + 10, 20.0, 90.0 };
//    UIEdgeInsets sectionInsets = (UIEdgeInsets){
//        contentInsets.top - targetTextBoxView.contentInsets.top,
//        targetTextBoxView.frame.origin.x,
//        targetTextBoxView.frame.size.width,
//        targetTextBoxView.frame.size.height
//    };
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
    
    [self configureCell:cell indexPath:indexPath];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.canAddItems) {
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
    
    if (!self.canAddItems) {
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
            CKListCell *cell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:visibleIndexPath];
            
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
        if (self.canAddItems) {
            [self.collectionView addSubview:self.topAddLabel];
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
    DLog(@"focus[%@] item[%d]", focused ? @"YES" : @"NO", indexPath.item);
    
    self.editingCell = focused ? cell : nil;
    
    // Disable/enable drag/drop according to focus mode.
    [self.collectionView getHelper].enabled = !focused;
    
    // Mark as not top add activation.
    [self updateAddStateWithActivation:NO];
    
    // Save value if it was not empty.
    if (!focused) {
        
        if (![cell isEmpty]) {
            
            // Save current value if it was not empty.
            [self.items replaceObjectAtIndex:indexPath.item withObject:[cell currentValue]];
            
        } else {
            
            if ([self.items count] > 1 && !self.processing) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self deleteCellAtIndexPath:indexPath];
                });
            }
            
        }
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
        [_collectionView registerClass:[self classForListCell] forCellWithReuseIdentifier:kCellId];
        
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

- (UILabel *)topAddLabel {
    if (!_topAddLabel) {
        _topAddLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topAddLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _topAddLabel.backgroundColor = [UIColor clearColor];
        _topAddLabel.textColor = [UIColor whiteColor];
    }
    return _topAddLabel;
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
    NSMutableArray *itemsToAnimate = [NSMutableArray arrayWithCapacity:numItems];
    for (NSInteger itemIndex = 1; itemIndex < numItems; itemIndex++) {
        [itemsToAnimate addObject:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
    }
    
    // Perform the insert/delete animation
    [self.collectionView performBatchUpdates:^{
        if (show) {
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            if ([itemsToAnimate count] > 0) {
                [self.collectionView insertItemsAtIndexPaths:itemsToAnimate];
            }
        } else {
            if ([itemsToAnimate count] > 0) {
                [self.collectionView deleteItemsAtIndexPaths:itemsToAnimate];
            }
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

- (CKListLayout *)currentLayout {
    return (CKListLayout *)self.collectionView.collectionViewLayout;
}

- (void)updateAddStateWithActivation:(BOOL)activated {
    self.topAddActivated = activated;
    [self updateAddState];
}

- (void)updateAddState {
    if (!self.canAddItems) {
        return;
    }
    
    // Top add
    self.topAddLabel.text = [self displayForActivated:self.topAddActivated];
    [self.topAddLabel sizeToFit];
    self.topAddLabel.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - self.topAddLabel.frame.size.width) / 2.0),
        -self.topAddLabel.frame.size.height - kLabelOffset,
        self.topAddLabel.frame.size.width,
        self.topAddLabel.frame.size.height
    };
    
}

- (NSString *)displayForActivated:(BOOL)activated {
    return activated ? @"Release to Add" : @"Pull to Add";
}

- (void)addCellFromTop {
    if (!self.canAddItems) {
        return;
    }
    
    // Mark as adding mode and turn off activation mode.
    self.topAddActivated = NO;
    
    // Insert an empty item at front.
    [self.items insertObject:[self createNewItem] atIndex:0];
    
    // Index path of new item at top.
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    [self.collectionView performBatchUpdates:^{
        
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.collectionView.contentInset = UIEdgeInsetsZero;
                         }
                         completion:^(BOOL finished) {
                             
                             // Set editing on the new cell.
                             CKListCell *cell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                             [self setEditing:YES cell:cell];
                             
                         }];
    }];
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
            CKListCell *cell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            self.panningCell = cell;
        }
    }
    
    // Ignore if no panning cell was detected.
    if (!self.panningCell) {
        return;
    }
    
    // Process the panning.
    CGFloat dragRatio = 0.3;
    CGPoint translation = [panGesture translationInView:self.collectionView];
    CGFloat panOffset = ceilf(translation.x * dragRatio);
//    DLog(@"translation %@", NSStringFromCGPoint(translation));
//    DLog(@"panOffset %f", panOffset);
    
    if (panGesture.state == UIGestureRecognizerStateBegan
        || panGesture.state == UIGestureRecognizerStateChanged) {
        
        // Drag the cell around.
        self.panningCell.transform = CGAffineTransformMakeTranslation(panOffset, 0.0);
        
    } else  {
        
        // Have we exceed offset to delete.
        if (panOffset > kDeleteOffset) {
            
            [self deleteCell:self.panningCell];
            
        } else {
            
            // Else snap right back.
            [self restoreTransformForCell:self.panningCell];
        }
    }

}

- (void)deleteCell:(CKListCell *)cell {
    if (!self.canDeleteItems || !cell) {
        return;
    }
    
    NSIndexPath *deleteIndexPath = [self.collectionView indexPathForCell:cell];
    [self.items removeObjectAtIndex:deleteIndexPath.item];
    [self.collectionView deleteItemsAtIndexPaths:@[deleteIndexPath]];
    self.panningCell = nil;
}

- (void)restoreTransformForCell:(CKListCell *)cell {
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         cell.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
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
    DLog(@"Deleting item [%d] items %@", indexPath.item, self.items);
    [self.items removeObjectAtIndex:indexPath.item];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
    }];
}

- (void)createNewCellAtIndexPath:(NSIndexPath *)indexPath {
    
    // Insert an empty item at the requested position.
    [self.items insertObject:[self createNewItem] atIndex:indexPath.item];
    
    [self.collectionView performBatchUpdates:^{
        
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        
        CKListCell *cell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell setEditing:YES];
        
    }];

}

- (void)processCell:(CKListCell *)cell {
    
    // Mark as processing cell.
    self.processing = YES;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DLog(@"processCell item[%d]", indexPath.item);
    
    // Empty cell?
    if ([cell isEmpty]) {
        
        if ([self.items count] > 1) {
            
            // Delete an empty cell.
            [self deleteCellAtIndexPath:indexPath];
            
        } else {
            
            // Last empty cell, just unfocus.
            [cell setEditing:NO];
            
        }
        
    } else {
        
        // Get the current value and update the items array.
        id currentValue = [cell currentValue];
        [self.items replaceObjectAtIndex:indexPath.item withObject:currentValue];
        
        // Grab the next indexpath, be it to create or focus on.
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
        
        // Add item after every resign?
        if (self.addItemAfterEach) {
            
            // Add new cell if at last cell.
            [self createNewCellAtIndexPath:nextIndexPath];
            
        } else {
            
            if (indexPath.item == [self.items count] - 1) {
                
                // Add new cell if at last cell.
                [self createNewCellAtIndexPath:nextIndexPath];
                
            } else {
                
                // Move to next cell.
                CKListCell *nextCell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:nextIndexPath];
                [nextCell setEditing:YES];
            }
            
        }
        
    }
}

- (BOOL)isEmptyForValue:(id)currentValue {
    
    // NSString comparison implementation.
    NSString *text = [currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ([text length] == 0);

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
