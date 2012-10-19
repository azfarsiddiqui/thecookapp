//
//  BookCoverView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCoverView.h"
#import "UIColor+Expanded.h"
#import "CKUIHelper.h"

@interface BookCoverView ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UILabel *nameLabel;
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

- (void)updateName:(NSString *)name {
    self.name = name;
    [self.nameLabel removeFromSuperview];
    
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    CGFloat singleLineHeight = [CKUIHelper singleLineHeightForFont:[self coverNameFont]];
    CGSize size = [self.name sizeWithFont:[self coverNameFont]
                        constrainedToSize:CGSizeMake([self contentAvailableSize].width, singleLineHeight)
                            lineBreakMode:lineBreakMode];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                                                   edgeInsets.top,
                                                                   size.width,
                                                                   size.height)];
    nameLabel.autoresizingMask = UIViewAutoresizingNone;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.lineBreakMode = lineBreakMode;
    nameLabel.minimumScaleFactor = 0.7;
    nameLabel.font = [self coverNameFont];
    nameLabel.textColor = [self coverNameColor];
    nameLabel.shadowColor = [self coverNameShadowColor];
    nameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    nameLabel.text = self.name;
    nameLabel.alpha = 0.0;
    [self insertSubview:nameLabel belowSubview:self.overlayImageView];
    self.nameLabel = nameLabel;
    
    // Fade the title in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         nameLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)updateTitle:(NSString *)title {
    self.title = [title uppercaseString];
    [self.titleLabel removeFromSuperview];
    
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [self.title sizeWithFont:[self coverTitleFont] constrainedToSize:self.bounds.size lineBreakMode:lineBreakMode];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
    titleLabel.autoresizingMask = UIViewAutoresizingNone;
    titleLabel.numberOfLines = 0;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = lineBreakMode;
    titleLabel.textAlignment = [self coverTitleAlignment];
    titleLabel.minimumScaleFactor = 0.7;
    titleLabel.font = [self coverTitleFont];
    titleLabel.textColor = [self coverTitleColor];
    titleLabel.shadowColor = [self coverTitleShadowColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    titleLabel.text = self.title;
    titleLabel.alpha = 0.0;
    titleLabel.center = self.center;
    titleLabel.frame = CGRectIntegral(titleLabel.frame);
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

- (UIEdgeInsets)contentEdgeInsets {
    return UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
}

- (CGSize)contentAvailableSize {
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    return CGSizeMake(self.bounds.size.width - edgeInsets.left - edgeInsets.right,
                      self.bounds.size.height - edgeInsets.top - edgeInsets.bottom);
}
                   
- (UIFont *)coverNameFont {
    return [UIFont boldSystemFontOfSize:18.0];
}

- (UIColor *)coverNameColor {
    return [self coverTitleColor];
}

- (UIColor *)coverNameShadowColor {
    return [self coverTitleShadowColor];
}

- (UIFont *)coverTitleFont {
    return [UIFont boldSystemFontOfSize:70.0];
}

- (NSTextAlignment)coverTitleAlignment {
    return NSTextAlignmentCenter;
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
