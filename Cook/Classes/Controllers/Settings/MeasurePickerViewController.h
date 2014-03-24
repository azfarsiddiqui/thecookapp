//
//  MeasurePickerViewController.h
//  Cook
//
//  Created by Gerald on 24/03/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "OverlayViewController.h"

@protocol MeasurePickerControllerDelegate <NSObject>

- (void)measurePickerControllerCloseRequested;

@end

@interface MeasurePickerViewController : OverlayViewController

@property (nonatomic, weak) id<MeasurePickerControllerDelegate> delegate;

@end
