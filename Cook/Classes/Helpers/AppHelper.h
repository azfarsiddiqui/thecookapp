//
//  CKAppHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppHelper : NSObject

+ (AppHelper *)sharedInstance;

- (BOOL)newInstall;
- (UIView *)rootView;

// Provides a landscape frame which can be tricky to obtain in pre-rotation situations.
- (CGRect)fullScreenFrame;
- (CGFloat)screenScale;

// Returns the keyboard ingredients items.
- (NSArray *)keyboardIngredients;

@end
