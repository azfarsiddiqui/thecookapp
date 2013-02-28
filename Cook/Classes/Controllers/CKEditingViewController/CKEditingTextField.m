//
//  CKEditingTextField.m
//  CKEditingViewControllerDemo
//
//  Created by Jeff Tan-Ang on 10/12/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKEditingTextField.h"

@implementation CKEditingTextField

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 0.0, 8.0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 0.0, 0.0);
}

#pragma mark - Private methods

- (UIImage *)clearImage {
    return [self clearImageOfSize:CGSizeMake(1.0, 1.0)];
}

- (UIImage *)clearImageOfSize:(CGSize)imageSize {
    CGRect rect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
