//
//  CKDashboardBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBenchtopBookCell : UICollectionViewCell

+ (CGSize)cellSize;
- (void)setText:(NSString *)text;
- (void)setBookImageWithName:(NSString *)bookImageName;

@end
