//
//  BookCoverView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookCoverView : UIView

@property (nonatomic, strong) NSString *type;

- (void)layoutBookCover;
- (void)updateTitle:(NSString *)title;

@end
