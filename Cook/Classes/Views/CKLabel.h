//
//  CKLabel.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKLabel : UILabel

@property (nonatomic, strong) UIFont *placeholderFont;
@property (nonatomic, assign) UIColor *placeholderColour;

- (id)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholderText minSize:(CGSize)minSize;

@end
