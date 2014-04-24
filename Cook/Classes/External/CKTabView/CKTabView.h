//
//  CKTabView.h
//  Cook
//
//  Created by Gerald on 23/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKTabView : UIView

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSArray *options;

- (id)initWithOptions:(NSArray *)options buttonFont:(UIFont *)font buttonWidth:(CGFloat)width;
- (void)selectOptionAtIndex:(NSInteger)optionIndex;

//Intended to be subclassed
- (void)reset;
- (UIImage *)backgroundImage;
- (UIImage *)selectedImageForOptionIndex:(NSInteger)optionIndex;
- (void)didSelectOptionAtIndex:(NSInteger)optionIndex;
- (void)updateTitle:(NSAttributedString *)title forButtonIndex:(NSInteger)index;

@end
