//
//  BookProfileHeaderView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBookSummaryView;

@interface BookProfileHeaderView : UICollectionReusableView

+ (CGFloat)profileHeaderWidth;
- (void)configureBookSummaryView:(CKBookSummaryView *)summaryView;

@end
