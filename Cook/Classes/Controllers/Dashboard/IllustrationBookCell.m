//
//  EditBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "IllustrationBookCell.h"
#import "CKBookCover.h"
#import "BenchtopBookCell.h"

@interface IllustrationBookCell ()

@property (nonatomic, strong) UIImageView *colourImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;

@end

@implementation IllustrationBookCell

#define kDivideScaleFactor  3.0

+ (CGSize)cellSize {
    CGSize fullSize = [BenchtopBookCell cellSize];
    return CGSizeMake(fullSize.width / kDivideScaleFactor, fullSize.height / kDivideScaleFactor);
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
    self.colourImageView.image = [CKBookCover imageForCover:cover];
}

- (void)setIllustration:(NSString *)illustration {
    self.illustrationImageView.image = [CKBookCover imageForIllustration:illustration];
}

#pragma mark - Private methods

- (void)initBackground {
    
    // Overlay
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_overlay.png"]];
    CGSize scaledSize = CGSizeMake(floorf(overlayImageView.frame.size.width / kDivideScaleFactor),
                                   floorf(overlayImageView.frame.size.height / kDivideScaleFactor));
    overlayImageView.frame = CGRectMake(floorf((self.frame.size.width - scaledSize.width) / 2.0),
                                        floorf((self.frame.size.height - scaledSize.height) / 2.0),
                                        scaledSize.width,
                                        scaledSize.height);
    [self.contentView addSubview:overlayImageView];
    
    // Cover
    UIImageView *colourImageView = [[UIImageView alloc] initWithImage:nil];
    colourImageView.frame = overlayImageView.frame;
    [self.contentView insertSubview:colourImageView belowSubview:overlayImageView];
    self.colourImageView = colourImageView;
    
    // Illustration.
    UIImageView *illustrationImageView = [[UIImageView alloc] initWithImage:nil];
    illustrationImageView.frame = overlayImageView.frame;
    [self.contentView insertSubview:illustrationImageView aboveSubview:overlayImageView];
    self.illustrationImageView = illustrationImageView;
}

@end
