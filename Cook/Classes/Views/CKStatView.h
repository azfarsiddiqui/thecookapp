//
//  CKStatView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 3/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKStatView : UIView

- (id)initWithNumber:(NSUInteger)number unit:(NSString *)unit;
- (void)updateNumber:(NSUInteger)number;

@end
