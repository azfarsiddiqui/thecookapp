//
//  CKTextItemsEditViewController.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 14/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextItemsEditViewController.h"
#import "CKTextItemCollectionViewCell.h"

@interface CKTextItemsEditViewController ()

@end

@implementation CKTextItemsEditViewController

- (Class)classForCell {
    return [CKTextItemCollectionViewCell class];
}

- (BOOL)validateCell:(UICollectionViewCell *)cell {
    CKTextItemCollectionViewCell *textCell = (CKTextItemCollectionViewCell *)cell;
    NSString *text = [textCell currentValue];
    
    // Not blank no existing value exists.
    return (![self blankForText:text] && [self valueValidForCell:textCell]);
}

- (BOOL)readyForInsertionForPlaceholderCell:(CKItemCollectionViewCell *)placeholderCell {
    CKTextItemCollectionViewCell *textCell = (CKTextItemCollectionViewCell *)placeholderCell;
    BOOL ready = NO;
    NSString *text = [textCell currentValue];
    if (![self blankForText:text] && [self valueValidForCell:textCell]) {
        ready = YES;
    }
    return ready;
}

#pragma mark - Private methods

- (NSString *)whitespaceTrimmedForText:(NSString *)text {
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)blankForText:(NSString *)text {
    return ([[self whitespaceTrimmedForText:text] length] == 0);
}

- (BOOL)existsForText:(NSString *)text {
    return [self.items containsObject:text];
}

- (NSString *)textValueAtIndex:(NSInteger)itemIndex {
    return [self.items objectAtIndex:itemIndex];
}

- (BOOL)valueValidForCell:(CKTextItemCollectionViewCell *)textItemCell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:textItemCell];
    NSString *currentText = [textItemCell currentValue];
    
    NSLog(@"Validating currentText [%@]", currentText);
    
    NSInteger anyExistingIndex = [self.items indexOfObject:currentText];
    BOOL valid = (anyExistingIndex == NSNotFound);
    
    // If not placeholder, then check that we do not take into account the current value.
    if (!textItemCell.placeholder && !valid) {
        
        valid = (indexPath.item == anyExistingIndex + 1);
    }
    
    NSLog(@"valid %@ anyExistingIndex: %d indexPath %d", valid ? @"YES" : @"NO", anyExistingIndex, indexPath.item);
    return valid;
}

@end
