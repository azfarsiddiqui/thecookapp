//
//  CKDashboardBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"
#import "BookCoverView.h"

@interface BenchtopBookCell : UICollectionViewCell

@property (nonatomic, strong) BookCoverView *bookCoverView;

+ (CGSize)cellSize;

- (BOOL)enabled;
- (void)loadBook:(CKBook *)book;
- (void)loadBook:(CKBook *)book mine:(BOOL)mine;
- (void)loadBook:(CKBook *)book mine:(BOOL)mine force:(BOOL)force;
- (void)openBook:(BOOL)open;
- (void)openBook:(BOOL)open completion:(void (^)(BOOL opened))completion;

// Empty shell placeholder.
- (void)loadAsPlaceholder;

@end
