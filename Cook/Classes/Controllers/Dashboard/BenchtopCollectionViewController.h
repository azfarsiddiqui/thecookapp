//
//  CKViewController.h
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BenchtopViewControllerDelegate.h"

@interface BenchtopCollectionViewController : UICollectionViewController

@property (nonatomic, assign) id<BenchtopViewControllerDelegate> delegate;

- (void)enable:(BOOL)enable;

@end
