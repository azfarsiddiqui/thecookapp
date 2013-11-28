//
//  TagLayout.h
//  Cook
//
//  Created by Gerald Kim on 18/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTagCellID          @"TagCell"
#define kTagSectionHeadID   @"TagSectionHeader"
#define kTagSectionFootID   @"TagSectionFooter"
#define kSize               CGSizeMake(884.0, 678.0)
#define kContentInsets      UIEdgeInsetsMake(45.0, 0.0, 40.0, 0.0)
#define kSectionHeadWidth   75.0
#define kSectionFootWidth   75.0
#define kItemHeight 115
#define kItemWidth 90

@interface TagLayout : UICollectionViewFlowLayout

@end
