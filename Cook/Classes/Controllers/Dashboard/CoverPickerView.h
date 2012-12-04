//
//  ColourPickerView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 4/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoverPickerViewDelegate

- (void)coverPickerSelected:(NSString *)cover;

@end


@interface CoverPickerView : UIView

@property (nonatomic, strong) NSString *cover;

- (id)initWithCover:(NSString *)cover delegate:(id<CoverPickerViewDelegate>)delegate;

@end
