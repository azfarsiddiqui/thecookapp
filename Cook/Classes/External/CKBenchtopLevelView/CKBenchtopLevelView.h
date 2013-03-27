//
//  CKBenchtopLevelView.h
//  CKBenchtopLevelView
//
//  Created by Jeff Tan-Ang on 27/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBenchtopLevelView : UIView

@property (nonatomic, assign) NSInteger currentLevel;

- (id)initWithLevels:(NSInteger)numLevels;
- (void)setLevel:(NSInteger)level;

@end
