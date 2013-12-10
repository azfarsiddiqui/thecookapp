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

@end

@implementation BenchtopBookCoverViewCell

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

+ (CGSize)cellSize {
    
    // Benchtop cells snaps to grid of 300 rows.
    return CGSizeMake(300.0, 438.0);
}

+ (CGSize)illustrationPickerCellSize {
    
    // Illustration cell is exactly the small cover size.
    return [CKBookCover smallCoverImageSize];
}

+ (CGSize)storeCellSize {
    
    // Illustration cell is exactly the medium cover size.
    return [CKBookCover mediumImageSize];
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

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
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
    [self loadBook:book updates:0 isNew:NO];
}

- (void)loadBook:(CKBook *)book updates:(NSInteger)updates {
    [self loadBook:book updates:updates isNew:NO];
}

- (void)loadBook:(CKBook *)book updates:(NSInteger)updates isNew:(BOOL)isNew {
    
    // Update cover.
    if (isNew) {
        [self.bookCoverView loadNewBook:book];
    } else {
        [self.bookCoverView loadBook:book update:updates];
    }
    
    // Reset delete mode.
    [self enableDeleteMode:NO];
}

- (void)enableDeleteMode:(BOOL)enable {
    
    // Disabled wiggle for now.
    // [self enableWiggle:enable];
}

- (void)enableEditMode:(BOOL)enable {
    [self.bookCoverView enableEditMode:enable animated:YES];
}

#pragma mark - CKBooKCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
    if ([self.delegate respondsToSelector:@selector(benchtopBookEditTappedForCell:)]) {
        [self.delegate benchtopBookEditTappedForCell:self];
    }
}

- (void)bookCoverViewEditWillAppear:(BOOL)appear {
    if ([self.delegate respondsToSelector:@selector(benchtopBookEditWillAppear:forCell:)]) {
        [self.delegate benchtopBookEditWillAppear:appear forCell:self];
    }
}

- (void)bookCoverViewEditDidAppear:(BOOL)appear {
    if ([self.delegate respondsToSelector:@selector(benchtopBookEditDidAppear:forCell:)]) {
        [self.delegate benchtopBookEditDidAppear:appear forCell:self];
    }
}

#pragma mark - Private methods

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

@end
