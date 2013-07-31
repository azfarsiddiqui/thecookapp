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

@interface CKListEditViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource_Draggable, CKListCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UILabel *topAddLabel;
@property (nonatomic, strong) UILabel *botAddLabel;
@property (nonatomic, strong) CKListCell *editingCell;
@property (nonatomic, strong) CKListCell *panningCell;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic, assign) BOOL itemsLoaded;
@property (nonatomic, assign) BOOL saveRequired;
@property (nonatomic, assign) BOOL topAddActivated;
@property (nonatomic, assign) BOOL botAddActivated;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL addingMode;

@end

@implementation CKListEditViewController

#define kButtonOffset                   CGPointMake(15.0, 15.0)
#define kCellId                         @"ListItemCellId"
#define kPlaceholderSize                CGSizeMake(750.0, 50.0)
#define kPullActivatedOffset            200.0
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
        self.items = [NSMutableArray arrayWithArray:items];
        self.selectedIndexNumber = selectedIndexNumber;
        self.canReorderItems = YES;
        self.canAddItems = YES;
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
        cell.allowSelection = YES;
        [cell configureValue:[self.items objectAtIndex:indexPath.item]
                    selected:([self.selectedIndexNumber integerValue] == indexPath.item)];
    } else {
        cell.allowSelection = NO;
        [cell configureValue:@"" selected:NO];
    }
}

- (void)itemsDidShow:(BOOL)show {
    
    // Subclasses to implement.
    if (show) {
        
        // Update pull labels.
        [self updateAddState];
        
    } else {
        
        if (self.saveRequired) {
            
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


#pragma mark - Lifecycle events.

- (void)keyboardWillAppear:(BOOL)appear {
    DLog(@"appear[%@]", appear ? @"YES" : @"NO");
    self.collectionView.scrollEnabled = !appear;
    
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
    CGSize size = kPlaceholderSize;
    
    UIView *placeholderView = [[UIView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                                                       contentInsets.top,
                                                                       size.width,
                                                                       size.height)];
    placeholderView.backgroundColor = [UIColor clearColor];
    return placeholderView;
}

- (UIEdgeInsets)contentInsets {
    return UIEdgeInsetsMake(60.0, 20.0, 0.0, 20.0);
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
    [self.items exchangeObjectAtIndex:fromIndexPath.item withObjectAtIndex:toIndexPath.item];
}


#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    UIEdgeInsets contentInsets = [self contentInsets];
    return (UIEdgeInsets) { contentInsets.top - targetTextBoxView.contentInsets.top, 90.0, 20.0, 90.0 };
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 20.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 5.0;
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
    NSInteger numItems = 1;
    if (self.itemsLoaded) {
        numItems = [self.items count];
    }
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKListCell *cell = (CKListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.allowSelection = YES;
    cell.delegate = self;
    
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
        
        // Check for top activation.
        BOOL topActivated = (scrollView.contentOffset.y <= -kPullActivatedOffset);
        if (topActivated != self.topAddActivated) {
            self.topAddActivated = topActivated;
            [self updateAddState];
        }
        
        // Check for bottom activation.
        BOOL botActivated = (scrollView.contentOffset.y >= MAX(self.collectionView.contentSize.height, self.collectionView.bounds.size.height) - self.collectionView.bounds.size.height + kPullActivatedOffset);
        if (botActivated != self.botAddActivated) {
            self.botAddActivated = botActivated;
            [self updateAddState];
        }
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!self.canAddItems) {
        return;
    }
    
    if (self.topAddActivated) {
        self.collectionView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0.0, 0.0, 0.0);
        [self addCellFromTop];
    } else if (self.botAddActivated) {
        [self addCellFromBot];
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
    self.selectedIndexNumber = @(indexPath.item);
    
    for (NSIndexPath *visibleIndexPath in [self.collectionView indexPathsForVisibleItems]) {
        
        // Skip the current one, cos that will be selected by the system.
        if ([visibleIndexPath isEqual:indexPath]) {
            continue;
        }
        
        CKListCell *cell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:visibleIndexPath];
        [cell setSelected:NO];
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
            [self.collectionView addSubview:self.botAddLabel];
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

- (void)listItemChangedForCell:(CKListCell *)cell {
    NSString *text = [cell currentValue];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self.items replaceObjectAtIndex:indexPath.item withObject:text];
    [self setEditing:NO cell:cell];
}

- (BOOL)listItemCanCancelForCell:(CKListCell *)cell {
    NSString *text = [cell currentValue];
    
    // Can cancel if adding mode and length is zero.
    BOOL canCancel = (self.addingMode && [text length] == 0);
    
    return canCancel;
}

- (void)listItemProcessCancelForCell:(CKListCell *)cell {
    
    // Mark as adding mode cancelled.
    self.addingMode = NO;
    
    [self setEditing:NO];
    
    // Delete the rows in questioni in next runloop to wait for keyboard to be resigned.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSIndexPath *cancelledIndexPath = [self.collectionView indexPathForCell:cell];
        [self.items removeObjectAtIndex:cancelledIndexPath.item];
        [self.collectionView deleteItemsAtIndexPaths:@[cancelledIndexPath]];
        [self updateAddState];
    });
}

- (BOOL)listItemValidatedForCell:(CKListCell *)cell {
    NSString *text = [cell currentValue];
    return ([text length] > 0);
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
        
        // Register double tap to detect cell.
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
        doubleTap.numberOfTapsRequired = 2;
        [_collectionView addGestureRecognizer:doubleTap];
        
        // Register pan to delete for cells.
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        panGesture.delegate = self;
        [_collectionView addGestureRecognizer:panGesture];
        
    }
    return _collectionView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [self buttonWithImage:[UIImage imageNamed:@"cook_btns_cancel.png"] target:self
                                       action:@selector(cancelTapped:)];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _cancelButton.frame = CGRectMake(kButtonOffset.x,
                                         kButtonOffset.y,
                                         _cancelButton.frame.size.width,
                                         _cancelButton.frame.size.height);
    }
    return _cancelButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [self buttonWithImage:[UIImage imageNamed:@"cook_btns_okay.png"] target:self
                                     action:@selector(saveTapped:)];
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _saveButton.frame = CGRectMake(self.view.bounds.size.width - kButtonOffset.x - _saveButton.frame.size.width,
                                       kButtonOffset.y,
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

- (UILabel *)botAddLabel {
    if (!_botAddLabel) {
        _botAddLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _botAddLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _botAddLabel.backgroundColor = [UIColor clearColor];
        _botAddLabel.textColor = [UIColor whiteColor];
    }
    return _botAddLabel;
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
            [self.collectionView insertItemsAtIndexPaths:itemsToAnimate];
        } else {
            [self.collectionView deleteItemsAtIndexPaths:itemsToAnimate];
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

- (void)saveAndDismissItems:(BOOL)save {
    self.saveRequired = save;
    
    // Hide items, which will trigger itemsDidShow.
    [self showItems:NO];
}

- (CKListLayout *)currentLayout {
    return (CKListLayout *)self.collectionView.collectionViewLayout;
}

- (void)updateAddState {
    if (!self.canAddItems) {
        return;
    }
    
    // Top add
    self.topAddLabel.hidden = self.editMode;
    self.topAddLabel.text = [self displayForActivated:self.topAddActivated];
    [self.topAddLabel sizeToFit];
    self.topAddLabel.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - self.topAddLabel.frame.size.width) / 2.0),
        -self.topAddLabel.frame.size.height - kLabelOffset,
        self.topAddLabel.frame.size.width,
        self.topAddLabel.frame.size.height
    };
    
    // Bottom add
    self.botAddLabel.hidden = self.editMode;
    self.botAddLabel.text = [self displayForActivated:self.botAddActivated];
    [self.botAddLabel sizeToFit];
    self.botAddLabel.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - self.botAddLabel.frame.size.width) / 2.0),
        MAX(self.collectionView.contentSize.height, self.collectionView.bounds.size.height) + kLabelOffset,
        self.botAddLabel.frame.size.width,
        self.botAddLabel.frame.size.height
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
    self.addingMode = YES;
    self.topAddActivated = NO;
    
    // Insert an empty item at front.
    [self.items insertObject:@"" atIndex:0];
    
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

- (void)addCellFromBot {
    if (!self.canAddItems) {
        return;
    }
    
    // Mark as adding mode and turn off activation mode.
    self.addingMode = YES;
    self.botAddActivated = NO;
    
    // Add an empty item at end.
    [self.items addObject:@""];
    
    // Index path of new item at end.
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:([self.items count] - 1) inSection:0];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        
        [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
        [self.collectionView setContentOffset:(CGPoint){
            self.collectionView.contentOffset.x,
            MAX(self.collectionView.contentSize.height, self.collectionView.bounds.size.height) - self.collectionView.bounds.size.height
        } animated:YES];
        
        [self updateAddState];
        
        // Set editing on the new cell.
        CKListCell *cell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self setEditing:YES cell:cell];
        
    }];
}

- (NSInteger)integerForIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:kLabelTag];
    return [label.text integerValue];
}

- (void)doubleTapped:(UITapGestureRecognizer *)doubleTap {
    CGPoint location = [doubleTap locationInView:self.collectionView];
    NSIndexPath *indexPath =  [self.collectionView indexPathForItemAtPoint:location];
    if (indexPath) {
        
        CKListCell *cell = (CKListCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            [self setEditing:YES cell:cell];
        }
        
    }
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
    self.canAddItems = !editing;
    self.canDeleteItems = !editing;
    self.canReorderItems = !editing;
    [self updateAddState];
}

- (void)setEditing:(BOOL)editing cell:(CKListCell *)cell {
    [self setEditing:editing];
    if (editing) {
        self.editingCell = cell;
        self.editingIndexPath = [self.collectionView indexPathForCell:cell];
    } else {
        self.editingCell = nil;
        self.editingIndexPath = nil;
    }
    [cell setEditing:editing];
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
