//
//  EditBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "IllustrationBookCell.h"
#import "CKBookCover.h"
#import "BenchtopBookCoverViewCell.h"
#import "ImageHelper.h"

@interface IllustrationBookCell ()

@property (nonatomic, strong) UIImageView *colourImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;

@end

@implementation IllustrationBookCell

+ (CGSize)cellSize {
    return [BenchtopBookCoverViewCell illustrationPickerCellSize];
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self initBackground];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
}

- (void)setSelected:(BOOL)selected {
}

- (void)setCover:(NSString *)cover {
    self.colourImageView.image = [ImageHelper scaledImage:[CKBookCover imageForCover:cover]
                                                     size:[CKBookCover smallCoverImageSize]];
}

- (void)setIllustration:(NSString *)illustration {
    self.illustrationImageView.image = [ImageHelper scaledImage:[CKBookCover imageForIllustration:illustration]
                                                           size:[CKBookCover smallCoverImageSize]];
}

#pragma mark - Private methods

+ (UIImage *)bookShadowUnderlayImage {
    return [ImageHelper scaledImage:[CKBookCover storeOverlayImage] size:[CKBookCover smallCoverShadowSize]];
}

- (void)initBackground {
    
    // Underlay.
    UIImageView *underlayImageView = [[UIImageView alloc] initWithImage:[IllustrationBookCell bookShadowUnderlayImage]];
    underlayImageView.frame = (CGRect) {
        floorf((self.contentView.bounds.size.width - underlayImageView.frame.size.width) / 2.0),
        floorf((self.contentView.bounds.size.height - underlayImageView.frame.size.height) / 2.0) + 5.0,
        underlayImageView.frame.size.width,
        underlayImageView.frame.size.height
    };
    [self.contentView addSubview:underlayImageView];
    
    // Cover
    UIImageView *colourImageView = [[UIImageView alloc] initWithImage:nil];
    colourImageView.frame = self.contentView.bounds;
    [self.contentView addSubview:colourImageView];
    self.colourImageView = colourImageView;
    
    // Illustration.
    UIImageView *illustrationImageView = [[UIImageView alloc] initWithImage:nil];
    illustrationImageView.frame = colourImageView.frame;
    [self.contentView addSubview:illustrationImageView];
    self.illustrationImageView = illustrationImageView;
}

@end
