//
//  CKBookTitleIndexView.h
//  CKBookTitleIndexView
//
//  Created by Jeff Tan-Ang on 3/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBookTitleIndexView : UIView

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL expanded;

- (id)initWithName:(NSString *)name title:(NSString *)title;
- (void)setWidthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio labelRatio:(CGFloat)labelRatio;

@end
