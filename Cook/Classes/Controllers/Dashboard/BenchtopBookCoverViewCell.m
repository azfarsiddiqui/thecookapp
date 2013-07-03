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

+ (CGFloat)storeScale {
    return 0.5;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CKBookCoverView *bookCoverView = [self createBookCoverViewWithDelegate:self];
        bookCoverView.center = self.contentView.center;
        bookCoverView.autoresizingMask = UIViewAutoresizingNone;
        
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:bookCoverView];
        self.bookCoverView = bookCoverView;
    }
    return self;
}

- (CKBookCoverView *)createBookCoverViewWithDelegate:(id<CKBookCoverViewDelegate>)delegate {
    return [[CKBookCoverView alloc] initWithFrame:self.contentView.bounds delegate:delegate];
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

- (void)applyMotionEffects {
    
    // Add some motion effects
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                         type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-50.0];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:50.0];
    [self.contentView addMotionEffect:xAxis];
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                         type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-50.0];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:50.0];
    [self.contentView addMotionEffect:yAxis];
}

@end
