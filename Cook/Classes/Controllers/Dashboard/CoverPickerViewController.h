//
//  CoverPickerViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 7/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoverPickerViewControllerDelegate

- (void)coverPickerCancelRequested;
- (void)coverPickerDoneRequested;
- (void)coverPickerSelected:(NSString *)cover;

@end

@interface CoverPickerViewController : UIViewController

@property (nonatomic, copy) NSString *cover;

- (id)initWithCover:(NSString *)cover delegate:(id<CoverPickerViewControllerDelegate>)delegate;
- (void)enable:(BOOL)enable;

@end
