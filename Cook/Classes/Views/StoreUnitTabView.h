//
//  StoreUnitTabView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 2/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreUnitTabView;

@interface StoreUnitTabView : UIView

- (id)initWithText:(NSString *)text icon:(UIImage *)icon;
- (void)select:(BOOL)select;

@end
