//
//  BookContentTitleView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookContentTitleView : UIView

- (id)initWithTitle:(NSString *)title;
- (void)updateWithTitle:(NSString *)title;
- (void)enableEditMode:(BOOL)editMode;
- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated;

@end
