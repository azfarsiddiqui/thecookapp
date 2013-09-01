//
//  RecipeSocialHeaderView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalOverlayHeaderView : UICollectionReusableView

+ (CGSize)unitSize;
- (void)configureTitle:(NSString *)title;

@end
