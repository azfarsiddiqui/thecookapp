//
//  CKDashboardBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"

@interface CKBenchtopBookCell : UICollectionViewCell

+ (CGSize)cellSize;

- (void)loadBook:(CKBook *)book;

// Empty shell placeholder.
- (void)loadAsPlaceholder;

@end
