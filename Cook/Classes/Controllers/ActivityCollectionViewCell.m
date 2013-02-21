//
//  ActivityCollectionViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ActivityCollectionViewCell.h"
#import "ImageHelper.h"

@interface ActivityCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *infoView;

@end

@implementation ActivityCollectionViewCell

+ (CGSize)cellSize {
    return CGSizeMake(276.0, 256.0);
}

+ (CGSize)imageSize {
    return [self cellSize];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.frame = self.bounds;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                    floorf(frame.size.height / 2.0),
                                                                    frame.size.width,
                                                                    floorf(frame.size.height / 2.0))];
        infoView.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:infoView];
        self.infoView = infoView;

    }
    return self;
}

- (void)configureActivity:(CKActivity *)activity {
    self.contentView.backgroundColor = [UIColor lightGrayColor];
}

- (void)configureImage:(UIImage *)image {
    [ImageHelper configureImageView:self.imageView image:image];
}

@end
