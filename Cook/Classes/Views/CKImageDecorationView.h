//
//  CKImageReusableView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 29/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKImageDecorationView : UICollectionReusableView

+ (NSString *)decorationKind;
+ (CGSize)imageSize;
+ (UIImage *)image;

@end
