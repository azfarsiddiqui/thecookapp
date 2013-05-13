//
//  CKListEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 30/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListEditViewController.h"
#import "CKEditingTextBoxView.h"
#import "CKListCollectionViewCell.h"
#import "CKListCollectionViewFlowLayout.h"
#import "CKListCollectionViewLayout.h"

@interface CKListEditViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    CKListCollectionViewCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, strong) UIView *titleHeaderView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) CKListCollectionViewCell *focusedCell;
@property (nonatomic, assign) BOOL loadItems;
@property (nonatomic, assign) CGPoint currentContentOffset;

@end

@implementation CKListEditViewController

#define kButtonOffset       CGPointMake(20.0, 15.0)
#define kCellId             @"ListItemCellId"
#define kHeaderId           @"ListHeaderId"
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
        self.listItems = [NSMutableArray arrayWithArray:items];
        self.selectedIndexNumber = selectedIndexNumber;
        self.canAddItems = YES;
        self.editable = YES;
        self.loadItems = NO;
    }
    return self;
}

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

- (UIEdgeInsets)contentInsets {
    UIEdgeInsets contentInsets = [super contentInsets];
    return contentInsets;
}

- (void)wrapTargetEditView:(UIView *)targetEditView delegate:(id<CKEditingTextBoxViewDelegate>)delegate {
    [super wrapTargetEditView:targetEditView delegate:delegate];
}

- (BOOL)showTitleLabel {
    return NO;
}

- (BOOL)showSaveIcon {
    return NO;
}

- (NSString *)addItemText {
    return self.canAddItemText ? self.canAddItemText : @"";
}

- (id)valueAtIndex:(NSInteger)index {
    return [[self textForItemAtIndex:index] uppercaseString];
}

- (NSString *)textForItemAtIndex:(NSInteger)itemIndex {
    itemIndex = self.addItemsFromTop ? itemIndex - 1 : itemIndex;
    return [self.listItems objectAtIndex:itemIndex];
}

- (void)selectedItemAtIndex:(NSInteger)index {
    NSLog(@"selectedItemAtIndex %d", index);
}

- (void)dismissEditView {
    
    // Unfocus if it was focussed.
    if (self.focusedCell) {
        [self.focusedCell focus:NO];
    }
    
    // Hide all items then dismiss.
    [self showItems:NO completion:^{
        [super dismissEditView];
    }];
    
}

- (void)keyboardWillAppear:(BOOL)appear {
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
    [self showItems:show completion:^{}];
}

- (void)showItems:(BOOL)show completion:(void (^)())completion {
    self.loadItems = show;
    
    // Gather items to insert/delete.
    NSInteger numItems = [self numListItems];
    if (self.canAddItems) {
        numItems += 1;
    }
    NSLog(@"showItems[%@] numItems[%d]", show ? @"YES" : @"NO", numItems);
    
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
                                              animated:YES
                                        scrollPosition:UICollectionViewScrollPositionNone];
        }
        
        completion();
    }];
    
}

- (id)updatedValue {
    NSString *value = nil;
    
    if (self.selectedIndexNumber) {
        value = [self.listItems objectAtIndex:[self.selectedIndexNumber integerValue]];
    }
    
    return value;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    if (self.loadItems) {
        numItems = [self numListItems];
        
        // Extra add item if requested.
        if (self.canAddItems) {
            numItems += 1;
        }
        
    } else {
        numItems = 1;
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
    NSInteger numItems = [self numListItems];
    CKListCollectionViewCell *cell = (CKListCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                           forIndexPath:indexPath];
    cell.delegate = self;
    
    if (self.canAddItems && ((!self.addItemsFromTop && indexPath.item == numItems)
                             || (self.addItemsFromTop && indexPath.item == 0))) {
        
        // Add item placeholder is editable.
        [cell configurePlaceholder:[self addItemText] editable:YES];
        
        // Add item placeholder is not selectable.
        [cell allowSelection:NO];
        
    } else {
        
        // Normal items are not editable normally.
        [cell configureValue:[self valueAtIndex:indexPath.item] editable:NO];
        
        // Is this selection mode.
        [cell allowSelection:self.allowSelection];
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self editableAtIndexPath:indexPath]) {
        
        [self transitionAndFocusCellAtIndexPath:indexPath];
        
    } else if (self.allowSelection) {
        
        [self unfocusCellIfApplicable];
        
        // Update selected index number.
        NSInteger selectedIndex = indexPath.item;
        if (self.addItemsFromTop) {
            selectedIndex -= 1;
        }
        self.selectedIndexNumber = [NSNumber numberWithInteger:selectedIndex];

    }
    
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

#pragma mark - CKListCollectionViewCellDelegate methods

- (void)listItemAddedForCell:(CKListCollectionViewCell *)cell {
    id currentValue = [cell currentValue];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSIndexPath *placeholderIndexPath = nil;
    
    // Are we adding from the top or to the bottom.
    if (self.addItemsFromTop) {
        [self.listItems insertObject:currentValue atIndex:0];
        placeholderIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    } else {
        [self.listItems addObject:currentValue];
        placeholderIndexPath = [NSIndexPath indexPathForItem:[self.listItems count] inSection:0];
    }
    
    // Unfocus current cell.
    [cell focus:NO];
    
    // Add new placeholder row.
    CKListCollectionViewLayout *layout = [self currentLayout];
    [layout enableInsertionDeletionAnimation:NO];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        [self.collectionView insertItemsAtIndexPaths:@[placeholderIndexPath]];
    } completion:^(BOOL finished) {

        [layout enableInsertionDeletionAnimation:YES];
        
        // Focus on next placeholder cell.
        if (self.incrementalAdd) {
            [self transitionAndFocusCellAtIndexPath:placeholderIndexPath];
        }
        
    }];
    
}

- (void)listItemChangedForCell:(CKListCollectionViewCell *)cell {
    NSIndexPath *changedIndexPath = [self.collectionView indexPathForCell:cell];
    NSIndexPath *placeholderIndexPath = nil;
    
    // Replace value in cell.
    id currentValue = [cell currentValue];
    NSInteger changedIndex = changedIndexPath.item;
    if (self.addItemsFromTop) {
        changedIndex += 1;
    }
    
    // Focus on next placeholder cell.
    if (self.incrementalAdd) {
        placeholderIndexPath = [NSIndexPath indexPathForItem:changedIndexPath.item + 1 inSection:changedIndexPath.section];
    }
    
    // Update value in model and focus to next cell if needed.
    [self.listItems replaceObjectAtIndex:changedIndex withObject:currentValue];
    if (placeholderIndexPath) {
        [self transitionAndFocusCellAtIndexPath:placeholderIndexPath];
    }
}

- (void)listItemCancelledForCell:(CKListCollectionViewCell *)cell {
    [self focus:NO cell:cell];
}

- (BOOL)listItemValidatedForCell:(CKListCollectionViewCell *)cell {
    NSString *cellText = [cell currentValue];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSInteger itemIndex = self.addItemsFromTop ? indexPath.item + 1 : indexPath.item;
    NSUInteger foundIndex = [self.listItems indexOfObject:cellText];
    
    return ([cellText length] > 0 && (foundIndex == NSNotFound || foundIndex == itemIndex));
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

#pragma mark - Lazy getters

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
        CGSize itemSize = targetTextBoxView.textBoxFrame.size;

        // UICollectionViewFlowLayout *layout = [[CKListCollectionViewFlowLayout alloc] init];
        CKListCollectionViewLayout *layout = [[CKListCollectionViewLayout alloc] initWithItemSize:itemSize];
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                              collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.alwaysBounceVertical = YES;
        collectionView.alwaysBounceHorizontal = NO;
        
        [collectionView registerClass:[CKListCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        [collectionView registerClass:[UICollectionReusableView class]
           forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderId];
        _collectionView = collectionView;
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

- (CGFloat)headerHeight {
    UIEdgeInsets contentInsets = [super contentInsets];
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CGRect targetImageTextBoxFrame = [targetTextBoxView textBoxFrame];
    return contentInsets.top - targetTextBoxView.contentInsets.top + targetImageTextBoxFrame.origin.y;
}

- (CGFloat)footerHeight {
    return [self headerHeight];
}

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
    [self dismissEditView];
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

- (CKListCollectionViewCell *)cellForIndexPath:(NSIndexPath *)indexPath {
    return (CKListCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

- (NSInteger)numListItems {
    return [self.listItems count];
}

- (BOOL)selectedForIndexPath:(NSIndexPath *)indexPath {
    return (self.selectedIndexNumber && ([self.selectedIndexNumber integerValue] == indexPath.item));
}

- (BOOL)editableAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    BOOL editable = self.addItemsFromTop ? (indexPath.item == 0) : (indexPath.item == numItems - 1);
    
    // Non selection are all editable.
    if (!editable) {
        editable = !self.allowSelection;
    }
    
    return editable;
}

- (void)transitionAndFocusCellAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"focusCellAtIndexPath: %@", indexPath);
    
    CKListCollectionViewCell *cell = (CKListCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    CGRect keyboardFrame = [self defaultKeyboardFrame];
    
    if (self.addItemsFromTop) {
        
        [self focus:YES cell:cell];
        
    } else {
        
        // Remember position.
        self.currentContentOffset = self.collectionView.contentOffset;
        
        // Transition up and focus.
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x,
                                                                               cell.frame.origin.y - floorf((keyboardFrame.origin.y - cell.frame.size.height) / 2.0))
                                                          animated:YES];
                         }
                         completion:^(BOOL finished) {
                             
                             [self focus:YES cell:cell];
                             
                         }];
    }
    
}

- (void)focus:(BOOL)focus cell:(CKListCollectionViewCell *)cell {
    
    // Focus on the cell.
    [cell focus:YES];
    
    // Remember the focused cell.
    self.focusedCell = focus ? cell : nil;
    
    // Focus locks scrolling.
    self.collectionView.scrollEnabled = !focus;
}

- (void)unfocusCellIfApplicable {
    NSLog(@"unfocusCellIfApplicable");
    
    [self focus:NO cell:self.focusedCell];

    // Restore position.
    [self.collectionView setContentOffset:self.currentContentOffset animated:YES];
}

- (CKListCollectionViewLayout *)currentLayout {
    return (CKListCollectionViewLayout *)self.collectionView.collectionViewLayout;
}

- (void)saveEditView {
    
    // Unfocus if it was focussed.
    if (self.focusedCell) {
        [self.focusedCell focus:NO];
    }
    
    // Hide all items then dismiss.
    [self showItems:NO completion:^{
        
        // Calls save on the the textbox view, which in turn triggers update via delegate.
        CKEditingTextBoxView *textBoxView = [self targetEditTextBoxView];
        [textBoxView.delegate editingTextBoxViewSaveTappedForEditingView:self.targetEditView];
        
    }];
    
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
