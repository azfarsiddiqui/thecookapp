//
//  CKListEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 29/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTableEditViewController.h"
#import "CKEditingViewHelper.h"
#import "CKTableViewCell.h"

@interface CKTableEditViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<CKTableEditViewControllerDataSource> dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, strong) UIView *titleHeaderView;
@property (nonatomic, assign) BOOL loadItems;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, assign) BOOL canAddItems;

@end

@implementation CKTableEditViewController

#define kCellId             @"ListItemCellId"
#define kPlaceholderSize    CGSizeMake(800.0, 50.0)
#define kRowSpacing         15.0

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
            dataSource:(id<CKTableEditViewControllerDataSource>)dataSource
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title {
    
    if (self = [super initWithEditView:editView delegate:delegate editingHelper:editingHelper white:white title:title]) {
        self.dataSource = dataSource;
        self.canAddItems = YES;
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

- (void)dismissEditView {
    [self showItems:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.delegate editViewControllerDismissRequested];
    });
}

- (void)keyboardWillAppear:(BOOL)appear {
    
    // Adjust height of table to make way for the keyboard.
    CGRect keyboardFrame = [self currentKeyboardFrame];
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.bounds.size.height - keyboardFrame.size.height;
    self.tableView.frame = tableFrame;
}

#pragma mark - UITableViewDataSource methods.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = 0;
    if (self.loadItems) {
        numRows = [self.dataSource tableEditViewControllerNumberOfItems];
        if (self.canAddItems) {
            numRows += 1;
        }
    } else {
        
        // Placeholder row before expanding.
        numRows = 1;
    }

    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numItems = [self.dataSource tableEditViewControllerNumberOfItems];
    
    CKTableViewCell *cell = (CKTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[CKTableViewCell alloc] initWithReuseIdentifier:kCellId borderHeight:kRowSpacing
                                                               font:[UIFont boldSystemFontOfSize:50]
                                                      contentInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    }

    // List item view.
    if (self.loadItems) {
        
        // Can add items.
        if (self.canAddItems && indexPath.item == numItems) {
            
            // Add item text.
            [cell setItemText:[self addItemText] editable:NO];
            
        } else {
            
            // Actual item text.
            [cell setItemText:[self.dataSource tableEditViewControllerTextItemAtIndex:indexPath.item]];
            
        }
        
    } else {
        
        [cell setItemText:nil editable:NO];

    }
    
    return cell;
}

- (UIEdgeInsets)listItemContentInsets {
    return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
}

- (NSString *)addItemText {
    return @"ADD ITEM";
}

- (void)selectedItemAtIndex:(NSInteger)index {
    NSLog(@"selectedItemAtIndex %d", index);
}

#pragma mark - UITableViewDelegate methods.

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CGRect targetImageTextBoxFrame = [targetTextBoxView textBoxFrame];
    return targetImageTextBoxFrame.size.height + kRowSpacing;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self selectedItemAtIndex:indexPath.item];
}

#pragma mark - Lifecycle events.

- (void)targetTextEditingViewWillAppear:(BOOL)appear {
    [super targetTextEditingViewWillAppear:appear];
    
    if (appear) {
        
    } else {
        
        // Remove the real tableView.
        [self.tableView removeFromSuperview];
        
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
        
        // Show the real tableView.
        self.tableView.tableHeaderView = self.titleHeaderView;
        [self.view addSubview:self.tableView];
        
        // Load items.
        [self performSelector:@selector(showItems) withObject:nil afterDelay:0.1];
        
    } else {
        
    }
}

#pragma mark - Lazy getters

- (UITableView *)tableView {
    if (!_tableView) {
        CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
        CGRect targetImageTextBoxFrame = [targetTextBoxView textBoxFrame];
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(targetTextBoxView.frame.origin.x,
                                                                               self.view.bounds.origin.y,
                                                                               targetImageTextBoxFrame.size.width,
                                                                               self.view.bounds.size.height)
                                                              style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.scrollEnabled = NO;
        tableView.autoresizingMask = UIViewAutoresizingNone;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.scrollEnabled = YES;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.separatorColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView = tableView;
    }
    return _tableView;
}

- (UIView *)titleHeaderView {
    if (!_titleHeaderView) {
        
        CGFloat headerHeight = [self headerHeight];
        UIView *titleHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, headerHeight)];
        titleHeaderView.backgroundColor = [UIColor clearColor];
        self.headerLabel.frame = CGRectMake(floorf((titleHeaderView.bounds.size.width - self.headerLabel.frame.size.width) / 2.0),
                                       titleHeaderView.bounds.size.height - self.headerLabel.frame.size.height - 20.0,
                                       self.headerLabel.frame.size.width,
                                       self.headerLabel.frame.size.height);
        [titleHeaderView addSubview:self.headerLabel];
        self.titleHeaderView = titleHeaderView;
    }
    return _titleHeaderView;
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

#pragma mark - Private methods

- (CGRect)initialAndFinalTableFrame {
    UIEdgeInsets contentInsets = [self contentInsets];
    CGSize size = kPlaceholderSize;
    
    return CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                      contentInsets.top,
                      size.width,
                      size.height);
}

- (CGFloat)headerHeight {
    UIEdgeInsets contentInsets = [super contentInsets];
    CKEditingTextBoxView *targetTextBoxView = [self targetEditTextBoxView];
    CGRect targetImageTextBoxFrame = [targetTextBoxView textBoxFrame];
    return contentInsets.top - targetTextBoxView.contentInsets.top + targetImageTextBoxFrame.origin.y;
}

- (void)showItems {
    [self showItems:!self.loadItems];
}

- (void)showItems:(BOOL)show {
    self.loadItems = show;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

@end
