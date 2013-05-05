//
//  CKListCollectionViewLayout.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 2/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKListCollectionViewLayout : UICollectionViewLayout

- (id)initWithItemSize:(CGSize)itemSize;
- (void)enableInsertionDeletionAnimation:(BOOL)enable;

@end
