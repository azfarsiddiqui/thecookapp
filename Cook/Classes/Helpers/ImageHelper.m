//
//  ImageHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 21/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ImageHelper.h"

@implementation ImageHelper

+ (void)configureImageView:(UIImageView *)imageView image:(UIImage *)image {
    if (!imageView) {
        return;
    }
    
    if (image) {
        imageView.hidden = NO;
        
        // Fade image in if there were no prior images.
        if (!imageView.image) {
            imageView.alpha = 0.0;
            imageView.image = image;
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 imageView.alpha = 1.0;
                             }
                             completion:^(BOOL finished)  {
                             }];
            
        } else {
            
            // Otherwise change image straight away.
            imageView.image = image;
        }
    } else {
        imageView.image = nil;
        imageView.hidden = YES;
    }
    
}
@end
