//
//  BenchtopCell.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "BenchtopBookCoverViewCell.h"
#import "ViewHelper.h"

@interface BenchtopBookCoverViewCell () <CKBookCoverViewDelegate>

@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation BenchtopBookCoverViewCell

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

+ (CGSize)cellSize {
    return CGSizeMake(300.0, 438.0);
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CKBookCoverView *bookView = [[CKBookCoverView alloc] initWithFrame:frame delegate:self];
        bookView.center = self.contentView.center;
        bookView.frame = CGRectIntegral(bookView.frame);
        [self.contentView addSubview:bookView];
        self.bookCoverView = bookView;
    }
    return self;
}

- (void)loadBook:(CKBook *)book {
    [self.bookCoverView setCover:book.cover illustration:book.illustration];
    [self.bookCoverView setTitle:book.name author:[book userName] caption:book.caption editable:[book editable]];
}

- (void)enableDeleteMode:(BOOL)enable {
    if (enable) {
        [self startWiggle];
    } else {
        [self stopWiggle];
    }
}

#pragma mark - CKBooKCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
    if (self.delegate) {
        [self.delegate benchtopBookEditTappedForCell:self];
    }
}

- (void)startWiggle {
    self.bookCoverView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-1.5));
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^ {
                         self.bookCoverView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(1.5));
                     }
                     completion:NULL
     ];
}

- (void)stopWiggle {
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
                     animations:^ {
                         self.bookCoverView.transform = CGAffineTransformIdentity;
                     }
                     completion:NULL
     ];
}

@end
