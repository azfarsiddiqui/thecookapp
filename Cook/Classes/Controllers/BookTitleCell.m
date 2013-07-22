//
//  BookTitleCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleCell.h"
#import "CKCategory.h"
#import "ImageHelper.h"
#import "Theme.h"

@interface BookTitleCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BookTitleCell

+ (CGSize)cellSize {
    return (CGSize) { 256.0, 192.0 };
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.7];
        
        // Background image.
        self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:self.imageView];
        
        
    }
    return self;
}

- (void)configureCategory:(CKCategory *)category {
}

- (void)configureImage:(UIImage *)image {
    [ImageHelper configureImageView:self.imageView image:image];
}

@end
