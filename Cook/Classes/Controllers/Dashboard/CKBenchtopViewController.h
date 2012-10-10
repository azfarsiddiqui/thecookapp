//
//  CKBenchtopViewController.h
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 9/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBenchtopDelegate.h"

@interface CKBenchtopViewController : UICollectionViewController <CKBenchtopDelegate>

- (void)reveal:(BOOL)reveal;

@end
