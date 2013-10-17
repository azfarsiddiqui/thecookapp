//
//  AddRecipeLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddRecipeLayoutDelegate <NSObject>

- (void)addRecipeLayoutDidFinish;

@end

@interface AddRecipeLayout : UICollectionViewLayout

- (id)initWithDelegate:(id<AddRecipeLayoutDelegate>)delegate;
- (void)setNeedsRelayout:(BOOL)relayout;

@end
