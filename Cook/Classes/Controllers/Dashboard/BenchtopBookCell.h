//
//  CKDashboardBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"
#import "CKBookCoverView.h"

@protocol BenchtopBookCellDelegate

@optional
- (void)benchtopBookCellEditRequestedForIndexPath:(NSIndexPath *)indexPath;

@end

@interface BenchtopBookCell : UICollectionViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) id<BenchtopBookCellDelegate> delegate;
@property (nonatomic, strong) CKBookCoverView *bookCoverView;

+ (CGSize)cellSize;
+ (CGFloat)storeScale;

- (void)enableEditMode:(BOOL)editMode;
- (BOOL)enabled;
- (void)loadBook:(CKBook *)book;
- (void)loadBook:(CKBook *)book mine:(BOOL)mine;
- (void)loadBook:(CKBook *)book mine:(BOOL)mine force:(BOOL)force;
- (void)openBook:(BOOL)open;
- (void)openBook:(BOOL)open completion:(void (^)(BOOL opened))completion;

// Empty shell placeholder.
- (void)loadAsPlaceholder;

@end
