//
//  UIImage+Scale.h
//  Cook
//
//  Created by Gerald Kim on 14/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)

- (UIImage *)scaledCopyOfSize:(CGSize)newSize orientation:(UIImageOrientation)toOrientation;

@end
