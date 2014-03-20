//
//  CKPhotoView.h
//  Cook
//
//  Created by Gerald on 14/02/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKPhotoView : UIView

@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, assign) BOOL isImageLoaded;

- (void)setThumbnailImage:(UIImage *)thumbImage;
- (void)setFullImage:(UIImage *)fullImage;
- (void)setFullImage:(UIImage *)fullImage completion:(void (^)())completion;
- (void)setBlurredImage:(UIImage *)thumbImage;
- (void)cleanImageViews;
- (void)deactivateImage;

@end
