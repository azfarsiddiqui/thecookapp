//
//  CKDashboardBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"

@interface BenchtopBookCell : UICollectionViewCell

+ (CGSize)cellSize;

- (BOOL)enabled;
- (void)loadBook:(CKBook *)book;
- (void)openBook:(BOOL)open;
- (void)openBook:(BOOL)open completion:(void (^)(BOOL opened))completion;

// Empty shell placeholder.
- (void)loadAsPlaceholder;

@end
