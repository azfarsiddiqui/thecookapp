//
//  BookCommentsHeaderView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookSocialHeaderView : UICollectionReusableView

+ (NSString *)bookSocialHeaderKind;
- (void)configureTitle:(NSString *)title;

@end
