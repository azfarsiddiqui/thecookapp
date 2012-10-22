//
//  BookCoverView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookView.h"
#import "BookCover.h"
#import "UIColor+Expanded.h"
#import "CKUIHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface BookView ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *taglineLabel;
@property (nonatomic, strong) UILabel *numRecipesLabel;

@end

@implementation BookView

#define kContentInsets          UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutBookCover];
    }
    return self;
}

- (void)layoutBookCover {
    [self initBackground];
}

- (void)updateWithBook:(CKBook *)book {
    DLog(@"Update with book %@", book);
    
    // Update content if it's necessary.
    if (![self.book.cover isEqualToString:book.cover]) {
        self.backgroundImageView.image = [BookCover imageForCover:book.cover];
    }
    if (![self.book.illustration isEqualToString:book.illustration]) {
        self.illustrationImageView.image = [BookCover imageForIllustration:book.illustration];
    }
    if (![[self.book userName] isEqualToString:[book userName]]) {
        [self updateName:[book userName]];
    }
    if (![self.book.name isEqualToString:book.name]) {
        [self updateTitle:book.name];
    }
    if (![self.book.tagline isEqualToString:book.tagline]) {
        [self updateTagline:book.tagline];
    }
    if (!self.book || self.book.numRecipes != book.numRecipes) {
        [self updateNumRecipes:book.numRecipes];
    }
    self.book = book;
}

- (void)open:(BOOL)open {
    DLog();
}

- (UIEdgeInsets)contentEdgeInsets {
    return UIEdgeInsetsMake(10.0, 10.0, 13.0, 10.0);
}

- (CGSize)contentAvailableSize {
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    return CGSizeMake(self.bounds.size.width - edgeInsets.left - edgeInsets.right,
                      self.bounds.size.height - edgeInsets.top - edgeInsets.bottom);
}
                   
- (UIFont *)coverNameFont {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:18];
}

- (UIColor *)coverNameColour {
    return [self coverTitleColour];
}

- (UIColor *)coverNameShadowColour {
    return [self coverTitleShadowColour];
}

- (UIFont *)coverTitleFont {
    return [UIFont fontWithName:@"AvenirNext-Bold" size:78];
}

- (NSTextAlignment)coverTitleAlignment {
    return NSTextAlignmentCenter;
}

- (UIColor *)coverTitleColour {
    return [UIColor colorWithHexString:@"222222"];
}

- (UIColor *)coverTitleShadowColour {
    return [UIColor colorWithRed:255 green:255 blue:255 alpha:0.15];
}

- (UIFont *)coverTaglineFont {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
}

- (UIColor *)coverTaglineColour {
    return [self coverTitleColour];
}

- (UIColor *)coverTaglineShadowColor {
    return [self coverTitleShadowColour];
}

- (UIFont *)coverNumRecipesFont {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
}

- (UIColor *)coverNumRecipesColour {
    return [self coverTitleColour];
}

- (UIColor *)coverNumRecipesShadowColour {
    return [self coverTitleShadowColour];
}

- (UIImage *)coverBackgroundImage {
    return [UIImage imageNamed:[BookCover defaultCover]];
}

- (UIImage *)coverIllustrationImage {
    return [UIImage imageNamed:[BookCover defaultIllustration]];
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

- (void)updateName:(NSString *)name {
    NSString *displayName = [name uppercaseString];
    [self.nameLabel removeFromSuperview];
    
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    CGFloat singleLineHeight = [CKUIHelper singleLineHeightForFont:[self coverNameFont]];
    CGSize size = [displayName sizeWithFont:[self coverNameFont]
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
    nameLabel.textColor = [self coverNameColour];
    nameLabel.shadowColor = [self coverNameShadowColour];
    nameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    nameLabel.text = displayName;
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

- (void)updateTagline:(NSString *)tagline {
    NSString *displayTagline = [tagline uppercaseString];
    [self.taglineLabel removeFromSuperview];
    
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    CGFloat singleLineHeight = [CKUIHelper singleLineHeightForFont:[self coverTaglineFont]];
    CGSize size = [displayTagline sizeWithFont:[self coverTaglineFont]
                             constrainedToSize:CGSizeMake([self contentAvailableSize].width, singleLineHeight)
                                 lineBreakMode:lineBreakMode];
    UILabel *taglineLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                                                      self.bounds.size.height - edgeInsets.bottom - size.height,
                                                                      size.width,
                                                                      size.height)];
    taglineLabel.autoresizingMask = UIViewAutoresizingNone;
    taglineLabel.backgroundColor = [UIColor clearColor];
    taglineLabel.lineBreakMode = lineBreakMode;
    taglineLabel.minimumScaleFactor = 0.7;
    taglineLabel.font = [self coverTaglineFont];
    taglineLabel.textColor = [self coverTaglineColour];
    taglineLabel.shadowColor = [self coverTaglineShadowColor];
    taglineLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    taglineLabel.text = displayTagline;
    taglineLabel.alpha = 0.0;
    [self insertSubview:taglineLabel belowSubview:self.overlayImageView];
    self.taglineLabel = taglineLabel;
    
    // Fade the tagline in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         taglineLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)updateNumRecipes:(NSUInteger)numRecipes {
    NSString *displayNum = [NSString stringWithFormat:@"%d", numRecipes];
    [self.numRecipesLabel removeFromSuperview];
    
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    UIEdgeInsets insets = UIEdgeInsetsMake(2.0, 6.0, 1.0, 6.0);
    CGFloat singleLineHeight = [CKUIHelper singleLineHeightForFont:[self coverNumRecipesFont]];
    CGSize size = [displayNum sizeWithFont:[self coverNumRecipesFont]
                         constrainedToSize:CGSizeMake([self contentAvailableSize].width, singleLineHeight)
                             lineBreakMode:lineBreakMode];
    UILabel *numRecipesLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                                                         self.bounds.size.height - insets.bottom - size.height - 40.0,
                                                                         insets.left + size.width + insets.right,
                                                                         insets.top + size.height + insets.bottom)];
    numRecipesLabel.autoresizingMask = UIViewAutoresizingNone;
    numRecipesLabel.layer.cornerRadius = 10.0;
    numRecipesLabel.backgroundColor = [UIColor whiteColor];
    numRecipesLabel.lineBreakMode = lineBreakMode;
    numRecipesLabel.textAlignment = NSTextAlignmentCenter;
    numRecipesLabel.minimumScaleFactor = 0.7;
    numRecipesLabel.font = [self coverNumRecipesFont];
    numRecipesLabel.textColor = [self coverNumRecipesColour];
    numRecipesLabel.shadowColor = [self coverNumRecipesShadowColour];
    numRecipesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    numRecipesLabel.text = displayNum;
    numRecipesLabel.alpha = 0.0;
    [self insertSubview:numRecipesLabel belowSubview:self.overlayImageView];
    self.numRecipesLabel = numRecipesLabel;
    
    // Fade the tagline in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         numRecipesLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)updateTitle:(NSString *)title {
    NSString *displayTitle = [title uppercaseString];
    [self.titleLabel removeFromSuperview];
    
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [displayTitle sizeWithFont:[self coverTitleFont] constrainedToSize:self.bounds.size lineBreakMode:lineBreakMode];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
    titleLabel.autoresizingMask = UIViewAutoresizingNone;
    titleLabel.numberOfLines = 0;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = lineBreakMode;
    titleLabel.textAlignment = [self coverTitleAlignment];
    titleLabel.minimumScaleFactor = 0.7;
    titleLabel.font = [self coverTitleFont];
    titleLabel.textColor = [self coverTitleColour];
    titleLabel.shadowColor = [self coverTitleShadowColour];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    titleLabel.text = displayTitle;
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

@end
