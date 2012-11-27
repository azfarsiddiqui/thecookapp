//
//  StoreViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StoreViewControllerDelegate

- (void)storeViewControllerCloseRequested;
- (void)storeViewControllerDataLoaded:(BOOL)loaded;

@end

@interface StoreViewController : UIViewController

- (id)initWithDelegate:(id<StoreViewControllerDelegate>)delegate;
- (void)enable:(BOOL)enable;
- (void)enable:(BOOL)enable completion:(void (^)())completion;
- (void)loadData;
- (void)unloadData;

@end
