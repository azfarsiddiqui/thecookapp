//
//  BookSocialLikeView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookSocialLikeView : UICollectionReusableView

+ (NSString *)bookSocialLikeKind;

- (void)configureContentView:(UIView *)contentView;

@end
