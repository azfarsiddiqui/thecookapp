//
//  StoreCollectionViewLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 24/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StoreCollectionViewLayoutDelegate <NSObject>

- (void)storeCollectionViewLayoutDidFinish;

@end

@interface StoreCollectionViewLayout : UICollectionViewLayout

- (id)initWithDelegate:(id<StoreCollectionViewLayoutDelegate>)delegate;
- (void)setNeedsRelayout:(BOOL)relayout;

@end
