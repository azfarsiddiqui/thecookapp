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
#define kSize               CGSizeMake(850.0, 650.0)
#define kContentInsets      UIEdgeInsetsMake(68.0, 60.0, 0.0, 60.0)
#define kSectionHeadWidth   20.0
#define kSectionFootWidth   20.0
#define kItemHeight         125
#define kItemWidth          125

@interface TagLayout : UICollectionViewFlowLayout

@end
