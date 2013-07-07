//
//  BenchtopCell.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "BenchtopBookCoverViewCell.h"
#import "CKBookCover.h"
#import "ViewHelper.h"

@interface BenchtopBookCoverViewCell () <CKBookCoverViewDelegate>

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIView *shadowView;

@end

@implementation BenchtopBookCoverViewCell

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

+ (CGSize)cellSize {
    return CGSizeMake(300.0, 438.0);
}

+ (CGSize)illustrationPickerCellSize {
    return CGSizeMake(104.0, 146.0);
}

+ (CGSize)storeCellSize {
    return CGSizeMake(104.0, 146.0);
}

+ (CGFloat)storeScale {
    return 3.0;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        
        // Shadow underlay.
        UIImage *shadowImage = [self shadowImage];
        UIOffset shadowOffset = [self shadowOffset];
        UIImageView *shadowView = [[UIImageView alloc] initWithImage:shadowImage];
        shadowView.center = (CGPoint) { self.contentView.center.x + shadowOffset.horizontal, self.contentView.center.y + shadowOffset.vertical };
        [self.contentView addSubview:shadowView];
        self.shadowView = shadowView;
        
        // Add motion effects on shadow.
        [ViewHelper applyMotionEffectsWithOffset:20 view:self.shadowView];
        
        // Book cover.
        CKBookCoverView *bookCoverView = [self createBookCoverViewWithDelegate:self];
        bookCoverView.center = self.contentView.center;
        bookCoverView.autoresizingMask = UIViewAutoresizingNone;
        
        [self.contentView addSubview:bookCoverView];
        self.bookCoverView = bookCoverView;
        
    }
    return self;
}

- (CKBookCoverView *)createBookCoverViewWithDelegate:(id<CKBookCoverViewDelegate>)delegate {
    return [[CKBookCoverView alloc] initWithDelegate:delegate];
}

- (UIImage *)shadowImage {
    return [CKBookCover overlayImage];
}

- (UIOffset)shadowOffset {
    return (UIOffset) { 0.0, 15.0 };
}

- (void)loadBook:(CKBook *)book {
    
    // Update cover.
    [self.bookCoverView setCover:book.cover illustration:book.illustration];
    [self.bookCoverView setName:book.name author:[book userName] editable:[book editable]];
    
    // Reset delete mode.
    [self enableDeleteMode:NO];
}

- (void)enableDeleteMode:(BOOL)enable {
    
    // Disabled wiggle for now.
    // [self enableWiggle:enable];
}

- (void)enableEditMode:(BOOL)enable {
    [self.bookCoverView enableEditMode:enable];
}

#pragma mark - CKBooKCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
    if (self.delegate) {
        [self.delegate benchtopBookEditTappedForCell:self];
    }
}

- (void)enableWiggle:(BOOL)enable {
    if (enable) {
        self.bookCoverView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-1.5));
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse
                         animations:^ {
                             self.bookCoverView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(1.5));
                         }
                         completion:NULL
         ];

    } else {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear
                         animations:^ {
                             self.bookCoverView.transform = CGAffineTransformIdentity;
                         }
                         completion:NULL
         ];
    }
}

#pragma mark - Private methods

@end
