//
//  CKItemsEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 13/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKItemsEditViewController.h"
#import "CKItemsCollectionViewFlowLayout.h"
#import "CKListCollectionViewLayout.h"
#import "CKItemCollectionViewCell.h"

@interface CKItemsEditViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    CKItemCellDelegate>

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, assign) NSNumber *currentSelectedIndexNumber;
@property (nonatomic, assign) BOOL itemsLoaded;
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) BOOL saveRequired;
@property (nonatomic, assign) NSInteger currentDisplayIndex;
@property (nonatomic, assign) CGPoint restoreContentOffset;

@property (nonatomic, strong) CKItemCollectionViewCell *focusedCell;

@end

@implementation CKItemsEditViewController

#define kCellId             @"ListItemCellId"
#define kHeaderId           @"ListHeaderId"
#define kHeaderHeight       91.0
#define kButtonOffset       CGPointMake(20.0, 15.0)
#define kPlaceholderSize    CGSizeMake(800.0, 50.0)

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
        self.currentDisplayIndex = 0;
        self.scrollEnabled = YES;
        self.allowSelectionState = YES;
        self.addItemsFromTop = YES;
    }
    return self;
}

- (void)loadData {
    [self showItems];
}

- (void)showItems {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self showItems:YES];
    });
}

- (void)showItems:(BOOL)show {
    self.itemsLoaded = show;
    NSInteger numItems = [self.items count] + 1;
    
    // Items to animate is everything below the initial placeholder.
    NSMutableArray *itemsToAnimate = [NSMutableArray arrayWithCapacity:numItems - 1];
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
            if (self.addItemsFromTop) {
                selectedIndex += 1;
            }
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

- (Class)classForCell {
    return [CKItemCollectionViewCell class];
}

- (void)configureCell:(CKItemCollectionViewCell *)itemCell indexPath:(NSIndexPath *)indexPath {
    itemCell.delegate = self;
    itemCell.allowSelectionState = self.allowSelectionState;
    
    BOOL placeholder = (indexPath.item == [self indexForPlaceholder]);
    if (placeholder) {
        itemCell.placeholder = placeholder;
    } else {
        [itemCell configureValue:[self itemValueAtIndex:indexPath.item]];
    }
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selectCellAtIndexPath: %@ selectedIndexNumber [%d]", indexPath, [self.selectedIndexNumber integerValue]);
    CKItemCollectionViewCell *itemCell = (CKItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    // The current item selected index, placeholder-adjusted.
    NSInteger selectedIndex = indexPath.item;
    if (self.addItemsFromTop) {
        selectedIndex -= 1;
    }
    
    // The existing item selected index if any, placeholder-adjusted.
    NSInteger currentCollectionIndex = NSNotFound;
    if (self.selectedIndexNumber) {
        currentCollectionIndex = [self.selectedIndexNumber integerValue];
        if (self.addItemsFromTop) {
            currentCollectionIndex += 1;
        }
    }
    
    NSInteger placeholderIndex = [self indexForPlaceholder];
    
    if (!self.allowSelectionState) {
        
        // Always focus on cell when in non-selection state.
        [self focusCell:itemCell focus:YES];
        
    } else if (indexPath.item == placeholderIndex) {
        
        // Placeholder selection always triggers editing.
        [self focusCell:itemCell focus:YES];
        
    } else if (self.allowSelectionState && indexPath.item == currentCollectionIndex) {
        
        // Second selection of the same selected cell triggers edit.
        [self focusCell:itemCell focus:YES];
        
    } else {
        
        // Unfocus existing cell if any.
        if (self.selectedIndexNumber) {
            NSIndexPath *existingIndexPath = [NSIndexPath indexPathForItem:[self.currentSelectedIndexNumber integerValue] inSection:0];
            CKItemCollectionViewCell *existingFocusCell = (CKItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:existingIndexPath];
            [self focusCell:existingFocusCell focus:NO];
        }
        
        self.selectedIndexNumber = [NSNumber numberWithInteger:selectedIndex];
        [self.collectionView selectItemAtIndexPath:indexPath
                                          animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (BOOL)validateCell:(CKItemCollectionViewCell *)itemCell {
    
    // Subclasses to provide implementation.
    return YES;
}

- (BOOL)readyForInsertionForPlaceholderCell:(CKItemCollectionViewCell *)placeholderCell {
    
    // Subclasses to provide implementation.
    return NO;
}

- (void)resetPlaceholderCell:(CKItemCollectionViewCell *)placeholderCell {
    placeholderCell.placeholder = YES;
}

// Returns the item value from the items by adjusting for the placeholder cell and whethere it's adding from top.
- (id)itemValueAtIndex:(NSInteger)index {
    NSInteger itemIndex = index;
    if (self.addItemsFromTop) {
        itemIndex -= 1;
    }
    return [self.items objectAtIndex:itemIndex];
}

- (NSInteger)itemIndexForCell:(CKItemCollectionViewCell *)itemCell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:itemCell];
    NSInteger itemIndex = indexPath.item;
    if (self.addItemsFromTop) {
        itemIndex -= 1;
    }
    return itemIndex;
}

- (id)updatedValue {
    NSString *value = nil;
    
    NSLog(@"self.selectedIndexNumber: %@", self.selectedIndexNumber);
    if (self.selectedIndexNumber) {
        value = [self.items objectAtIndex:[self.selectedIndexNumber integerValue]];
    }
    
    return value;
}

- (void)itemsDidShow:(BOOL)show {
    
    // Subclasses to implement.
    if (show) {
        
        
        
    } else {
        
        if (self.saveRequired) {
            
            // Calls save on the the textbox view, which in turn triggers update via delegate.
            CKEditingTextBoxView *textBoxView = [self targetEditTextBoxView];
            [textBoxView.delegate editingTextBoxViewSaveTappedForEditingView:self.targetEditView];
            
        }
        
        // Then dismiss.
        [super dismissEditView];
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
    placeholderView.backgroundColor = [UIColor whiteColor];
    return placeholderView;
}

- (void)dismissEditView {
    
    // Cannot dismiss as long as there is a focused cell.
    if (self.focusedCell) {
        return;
    }
    
    // Hide all items then dismiss.
    [self showItems:NO];    
}

- (void)keyboardWillAppear:(BOOL)appear {
    
    // Lock/unlock scrolling according to keyboard.
    self.collectionView.scrollEnabled = !appear;
    
    // Disable buttons accordingly.
    self.cancelButton.enabled = !appear;
    self.saveButton.enabled = !appear;
    
    // Remove focus if keyboard disappears.
    if (!appear) {
        self.focusedCell = nil;
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
        [self.view addSubview:self.collectionView];
        
        // Show buttons.
        [self showButtons:YES animated:YES];
        
        // Load items.
        [self loadData];
        
    } else {
        
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 1;
    if (self.itemsLoaded) {
        numItems = [self.items count];
        numItems += 1;  // Placeholder.
    }
    return numItems;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor clearColor];
    
    if (!self.headerLabel.superview) {
        self.headerLabel.frame = CGRectMake(floorf((headerView.bounds.size.width - self.headerLabel.frame.size.width) / 2.0),
                                            headerView.bounds.size.height - self.headerLabel.frame.size.height - 15.0,
                                            self.headerLabel.frame.size.width,
                                            self.headerLabel.frame.size.height);
        [headerView addSubview:self.headerLabel];
    }
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKItemCollectionViewCell *cell = (CKItemCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Can select cells when no cells are focused.
    return (self.focusedCell == nil);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selectCellAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(self.collectionView.bounds.size.width, kHeaderHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between rows
    return 15.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    return targetTextBoxView.textBoxFrame.size;
}

#pragma mark - CKItemCellDelegate methods

- (BOOL)processedValueForCell:(CKItemCollectionViewCell *)itemCell {
    BOOL validated = NO;
    
    if (itemCell.placeholder) {
        
        // Validated no matter what.
        validated = YES;
        
        BOOL readyForInsertion = [self readyForInsertionForPlaceholderCell:itemCell];
        if (readyForInsertion) {
            
            // Remove focus from the cell.
            [self focusCell:itemCell focus:NO];
            [self insertItemForCell:itemCell];
            
            // Select current cell again.
            [self restoreCellSelection];
            
        } else {
            
            // Reset the placeholder cell.
            [self resetPlaceholderCell:itemCell];
            
            // Select current cell again.
            [self restoreCellSelection];
        }
        
    } else {
        
        // Validate the cell in question.
        validated = [self validateCell:itemCell];
        NSLog(@"Cell validated [%@]", validated ? @"YES" : @"NO");
        
        // Validation may involve placeholder cell.
        if (validated) {
            
            // Remove focus from the cell.
            [self focusCell:itemCell focus:NO];
            [self updateItemForCell:itemCell];
            
        } else {
            
            // Error messages?
            [self focusCell:itemCell focus:YES transition:NO];
            
        }
        
    }
    
    return validated;
}

- (void)returnRequestedForCell:(CKItemCollectionViewCell *)itemCell {
    [self focusCell:itemCell focus:NO];
}

#pragma mark - Lazy getters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
        CGSize itemSize = targetTextBoxView.textBoxFrame.size;
        CKListCollectionViewLayout *layout = [[CKListCollectionViewLayout alloc] initWithItemSize:itemSize];
        
//        CKItemsCollectionViewFlowLayout *layout = [[CKItemsCollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.scrollEnabled = self.scrollEnabled;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [self registerCellsForCollectionView:_collectionView];
        
        if (!self.scrollEnabled) {
            
            UISwipeGestureRecognizer *upSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
            upSwipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
            [_collectionView addGestureRecognizer:upSwipeGesture];
            
            UISwipeGestureRecognizer *downSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
            downSwipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
            [_collectionView addGestureRecognizer:downSwipeGesture];
        }
    }
    return _collectionView;
}

- (UILabel *)headerLabel {
    if (!_headerLabel) {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.text = [self.editTitle uppercaseString];
        headerLabel.font = [UIFont boldSystemFontOfSize:30.0];
        headerLabel.textColor = [self titleColour];
        [headerLabel sizeToFit];
        _headerLabel = headerLabel;
    }
    return _headerLabel;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [self buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"] target:self
                                     action:@selector(saveTapped:)];
        _saveButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _saveButton.frame = CGRectMake(self.view.bounds.size.width - kButtonOffset.x - _saveButton.frame.size.width,
                                       kButtonOffset.y,
                                       _saveButton.frame.size.width,
                                       _saveButton.frame.size.height);
    }
    return _saveButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [self buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_cancel.png"] target:self
                                       action:@selector(cancelTapped:)];
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _cancelButton.frame = CGRectMake(kButtonOffset.x,
                                         kButtonOffset.y,
                                         _cancelButton.frame.size.width,
                                         _cancelButton.frame.size.height);
    }
    return _cancelButton;
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
    [self saveEditView];
}

- (void)cancelTapped:(id)sender {
    [self saveAndDismissItems:NO];
}

- (void)saveEditView {
    [self saveAndDismissItems:YES];
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

- (void)swiped:(UISwipeGestureRecognizer *)swipeGesture {
    UISwipeGestureRecognizerDirection direction = swipeGesture.direction;
    if (direction == UISwipeGestureRecognizerDirectionUp) {
        [self displayNextCell];
    } else if (direction == UISwipeGestureRecognizerDirectionDown) {
        [self displayPreviousCell];
    }
}

- (void)displayPreviousCell {
    
    // Already reached the top.
    if (self.currentDisplayIndex == 0) {
        return;
    }
    
    [self displayCellAtIndex:self.currentDisplayIndex - 1];
}

- (void)displayNextCell {

    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    
    // Already reached the bottom.
    if (self.currentDisplayIndex == (numItems -1 )) {
        return;
    }
    
    [self displayCellAtIndex:self.currentDisplayIndex + 1];
}

- (void)displayCellAtIndex:(NSInteger)displayIndex {
    [self displayCellAtIndex:displayIndex completion:nil];
}

- (void)displayCellAtIndex:(NSInteger)displayIndex completion:(void (^)())completion {
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:displayIndex inSection:0]];
    self.currentDisplayIndex = displayIndex;
    
    // Keep track of current contentOffset to restore afterwards.
    self.restoreContentOffset = self.collectionView.contentOffset;
    
    // Animate to the display position.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x,
                                                                           cell.frame.origin.y - kHeaderHeight)
                                                      animated:NO];
                     }
                     completion:^(BOOL finished) {
                         
                         if (completion != nil) {
                             completion();
                         }
                     }];
}

- (void)restoreAfterDisplayWithCompletion {
    [self restoreAfterDisplayWithCompletion:nil];
}

- (void)restoreAfterDisplayWithCompletion:(void (^)())completion {
    
    // Animate to the stored restoreContentOffset.
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.collectionView setContentOffset:self.restoreContentOffset animated:NO];
                     }
                     completion:^(BOOL finished) {
                         
                         if (completion != nil) {
                             completion();
                         }
                     }];
}

- (NSInteger)indexForPlaceholder {
    return self.addItemsFromTop ? 0 : [self.items count];
}

- (void)registerCellsForCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[self classForCell] forCellWithReuseIdentifier:kCellId];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId];
}

- (void)focusCell:(CKItemCollectionViewCell *)cell focus:(BOOL)focus {
    
    [self focusCell:cell focus:focus transition:YES];
}

- (void)focusCell:(CKItemCollectionViewCell *)cell focus:(BOOL)focus transition:(BOOL)transition {
    
    self.focusedCell = focus ? cell : nil;
    NSIndexPath *focusIndexPath = [self.collectionView indexPathForCell:cell];
    
    if (transition) {
        if (focus) {
            
            // Display the cell first then focus on it.
            [self displayCellAtIndex:focusIndexPath.item
                          completion:^{
                              
                              [cell focusForEditing:YES];
                          }];
        } else {
            
            // TODO What happens to contentOffset when you restore?
            [cell focusForEditing:NO];
            
            // Restore to the stored contentOffset.
            [self restoreAfterDisplayWithCompletion];
            
        }
        
    } else {
        
        // Just focus.
        [cell focusForEditing:focus];
    }
    
}

- (void)insertItemForCell:(CKItemCollectionViewCell *)itemCell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:itemCell];
    NSIndexPath *placeholderIndexPath = nil;
    NSLog(@"insertItemForCell indexPath[%@]", indexPath);
    
    // Get the current value from the cell.
    id currentValue = [itemCell currentValue];
    
    // Are we adding from the top or to the bottom.
    if (self.addItemsFromTop) {
        [self.items insertObject:currentValue atIndex:0];
        placeholderIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    } else {
        [self.items addObject:currentValue];
        placeholderIndexPath = [NSIndexPath indexPathForItem:[self.items count] inSection:0];
    }
    
    // Add new placeholder row.
    CKListCollectionViewLayout *layout = (CKListCollectionViewLayout *)self.collectionView.collectionViewLayout;
    [layout enableInsertionDeletionAnimation:NO];
    [self.collectionView performBatchUpdates:^{
        
        // Reload added cell.
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        // Insert new placeholder.
        [self.collectionView insertItemsAtIndexPaths:@[placeholderIndexPath]];
        
    } completion:^(BOOL finished) {
        
        // Restore default animation.
        [layout enableInsertionDeletionAnimation:YES];
        
    }];
}

- (void)updateItemForCell:(CKItemCollectionViewCell *)itemCell {
    NSIndexPath *changedIndexPath = [self.collectionView indexPathForCell:itemCell];
    NSLog(@"updateItemForCell changedIndexPath[%@]", changedIndexPath);
    
    // Replace value in cell.
    id currentValue = [itemCell currentValue];
    NSInteger changedIndex = changedIndexPath.item;
    if (self.addItemsFromTop) {
        changedIndex -= 1;
    }
    
    // Updates value in model.
    [self.items replaceObjectAtIndex:changedIndex withObject:currentValue];
}

- (void)restoreCellSelection {
    if (self.selectedIndexNumber) {
        NSInteger selectedIndex = [self.selectedIndexNumber integerValue];
        if (self.addItemsFromTop) {
            selectedIndex += 1;
        }
        [self selectCellAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
    }
}

@end
