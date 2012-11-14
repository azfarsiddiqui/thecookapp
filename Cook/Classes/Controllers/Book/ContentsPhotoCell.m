//
//  ContentsPhotoCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ContentsPhotoCell.h"
#import "UIImage+ProportionalFill.h"

@interface ContentsPhotoCell ()

@property (strong, nonatomic) PFImageView *imageView;

@end

@implementation ContentsPhotoCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.imageView = [[PFImageView alloc] initWithImage:nil];
        self.imageView.frame = self.contentView.bounds;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)loadRecipe:(CKRecipe *)recipe {
    [CKRecipe imagesForRecipe:recipe success:^{
        if ([recipe imageFile]) {
            self.imageView.file = [recipe imageFile];
            [self.imageView loadInBackground:^(UIImage *image, NSError *error) {
                if (!error) {
                    self.imageView.image = [image imageCroppedToFitSize:CGSizeMake(image.size.height, image.size.height)];
                    self.imageView.hidden = NO;
                } else {
                    DLog(@"Error loading image in background: %@", [error description]);
                }
            }];
        }
    } failure:^(NSError *error) {
        DLog(@"Error loading image: %@", [error description]);
    }];
}

+ (CGSize)cellSize {
    return CGSizeMake(175.0, 175.0);
}

+ (CGSize)minSize {
    return [self cellSize];
}

+ (CGSize)midSize {
    return CGSizeMake([self minSize].width * 2.0, [self minSize].height * 2.0);
}

+ (CGSize)maxSize {
    return CGSizeMake([self midSize].width, [self midSize].height * 2.0);
}

@end
