//
//  ActivityHeaderViewCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 22/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@interface BookContentsHeaderView : UICollectionReusableView

- (void)configureBook:(CKBook *)book;

@end
