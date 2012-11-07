//
//  CoverPickerViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 7/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoverPickerViewControllerDelegate

- (void)coverPickerExpanded:(BOOL)expanded;
- (void)coverPickerSelected:(NSString *)cover;

@end

@interface CoverPickerViewController : UICollectionViewController

- (id)initWithCover:(NSString *)cover delegate:(id<CoverPickerViewControllerDelegate>)delegate;

@end
