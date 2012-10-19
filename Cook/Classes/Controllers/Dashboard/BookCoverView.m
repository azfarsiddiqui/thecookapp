//
//  BookCoverView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCoverView.h"
#import "UIColor+Expanded.h"

@interface BookCoverView ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BookCoverView

#define kContentInsets          UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
#define kBookTitleFont          [UIFont boldSystemFontOfSize:40.0]
#define kBookTitleColour        [UIColor lightGrayColor]
#define kBookTitleShadowColour  [UIColor blackColor]

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutBookCover];
    }
    return self;
}

- (void)layoutBookCover {
    [self initBackground];
}

- (void)updateTitle:(NSString *)title {
    self.title = [title uppercaseString];
    [self.titleLabel removeFromSuperview];
    
    CGSize size = [title sizeWithFont:[self coverTitleFont] constrainedToSize:self.bounds.size lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                                                    floorf((self.bounds.size.height - size.height) / 2.0),
                                                                    size.width,
                                                                    size.height)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.minimumScaleFactor = 0.7;
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = [self coverTitleFont];
    titleLabel.textColor = [self coverTitleColor];
    titleLabel.shadowColor = [self coverTitleShadowColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    titleLabel.text = self.title;
    titleLabel.alpha = 0.0;
    [self insertSubview:titleLabel belowSubview:self.overlayImageView];
    self.titleLabel = titleLabel;
    
    // Fade the title in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         titleLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];

}

- (UIFont *)coverTitleFont {
    return [UIFont boldSystemFontOfSize:70.0];
}

- (UIColor *)coverTitleColor {
    return [UIColor colorWithHexString:@"222222"];
}

- (UIColor *)coverTitleShadowColor {
    return [UIColor colorWithRed:255 green:255 blue:255 alpha:0.15];
}

- (UIImage *)coverBackgroundImage {
    return [UIImage imageNamed:@"cook_book_red.png"];
}

- (UIImage *)coverIllustrationImage {
    return [UIImage imageNamed:@"cook_book_graphic_cleaver.png"];
}

- (UIImage *)coverOverlayImage {
    return [UIImage imageNamed:@"cook_book_overlay.png"];
}

#pragma mark - Private methods

- (void)initBackground {
    
    // Cover
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[self coverBackgroundImage]];
    backgroundImageView.frame = CGRectMake(floorf((self.frame.size.width - backgroundImageView.frame.size.width) / 2.0),
                                           floorf((self.frame.size.height - backgroundImageView.frame.size.height) / 2.0),
                                           backgroundImageView.frame.size.width,
                                           backgroundImageView.frame.size.height);
    [self addSubview:backgroundImageView];
    [self sendSubviewToBack:backgroundImageView];
    self.backgroundImageView = backgroundImageView;
    
    // Overlay
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[self coverOverlayImage]];
    overlayImageView.frame = backgroundImageView.frame;
    [self insertSubview:overlayImageView aboveSubview:backgroundImageView];
    self.overlayImageView = overlayImageView;
    
    // Illustration.
    UIImageView *illustrationImageView = [[UIImageView alloc] initWithImage:[self coverIllustrationImage]];
    illustrationImageView.frame = backgroundImageView.frame;
    [self insertSubview:illustrationImageView aboveSubview:backgroundImageView];
    self.illustrationImageView = illustrationImageView;
}

@end
