//
//  BookCoverView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCoverView.h"
#import "BookCover.h"
#import "UIColor+Expanded.h"
#import "ViewHelper.h"
#import "AppHelper.h"
#import "EventHelper.h"
#import "NSString+Utilities.h"
#import "UIFont+Cook.h"

@interface BookCoverView ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *numRecipesLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, assign) BOOL opened;

@end

@implementation BookCoverView

#define RADIANS(degrees)        ((degrees * (float)M_PI) / 180.0f)

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
    [self updateWithBook:book mine:NO];
}

- (void)updateWithBook:(CKBook *)book mine:(BOOL)mine {
    [self updateIfRequiredWithBook:book force:NO];
}

- (void)updateWithBook:(CKBook *)book mine:(BOOL)mine force:(BOOL)force {
    [self updateIfRequiredWithBook:book force:force];
    if (mine) {
        [self updateEditButtonWithBook:book];
    } else {
        [self.editButton removeFromSuperview];
        self.editButton = nil;
    }
    self.book = book;
}

- (UIEdgeInsets)contentEdgeInsets {
    return UIEdgeInsetsMake(20.0, 10.0, 13.0, 10.0);
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
    return [UIFont bookTitleFontWithSize:78.0];
}

- (NSTextAlignment)coverTitleAlignment {
    return NSTextAlignmentCenter;
}

- (UIColor *)coverTitleColour {
    return [UIColor colorWithHexString:@"FFFFFF"];
}

- (UIColor *)coverTitleShadowColour {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
}

- (UIFont *)coverCaptionFont {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
}

- (UIColor *)coverCaptionColour {
    return [self coverTitleColour];
}

- (UIColor *)coverCaptionShadowColor {
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

- (void)initBackground {
    
    // Cover
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[self coverBackgroundImage]];
    backgroundImageView.frame = CGRectMake(floorf((self.frame.size.width - backgroundImageView.frame.size.width) / 2.0),
                                           floorf((self.frame.size.height - backgroundImageView.frame.size.height) / 2.0),
                                           backgroundImageView.frame.size.width,
                                           backgroundImageView.frame.size.height);
    [self addSubview:backgroundImageView];
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

- (void)updateName:(NSString *)name book:(CKBook *)book {
    NSString *displayName = [name uppercaseString];
    [self.nameLabel removeFromSuperview];
    
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    CGFloat singleLineHeight = [ViewHelper singleLineHeightForFont:[self coverNameFont]];
    CGSize size = [displayName sizeWithFont:[self coverNameFont]
                          constrainedToSize:CGSizeMake([self contentAvailableSize].width, singleLineHeight)
                              lineBreakMode:lineBreakMode];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.autoresizingMask = UIViewAutoresizingNone;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.lineBreakMode = lineBreakMode;
    nameLabel.minimumScaleFactor = 0.7;
    nameLabel.font = [self coverNameFont];
    nameLabel.textColor = [self coverNameColour];
    nameLabel.shadowColor = [self coverNameShadowColour];
    nameLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    nameLabel.text = displayName;
    nameLabel.alpha = 1.0;
    nameLabel.frame = [self nameLabelFrameForSize:size book:book];
    [self insertSubview:nameLabel belowSubview:self.overlayImageView];
    self.nameLabel = nameLabel;
}

- (void)updateTitle:(NSString *)title book:(CKBook *)book {
    NSString *displayTitle = [title uppercaseString];
    [self.titleLabel removeFromSuperview];
    
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [displayTitle sizeWithFont:[self coverTitleFont] constrainedToSize:self.bounds.size lineBreakMode:lineBreakMode];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.autoresizingMask = UIViewAutoresizingNone;
    titleLabel.numberOfLines = 0;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = lineBreakMode;
    titleLabel.textAlignment = [self coverTitleAlignment];
    titleLabel.minimumScaleFactor = 0.7;
    titleLabel.font = [self coverTitleFont];
    titleLabel.textColor = [self coverTitleColour];
    titleLabel.shadowColor = [self coverTitleShadowColour];
    titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    titleLabel.text = displayTitle;
    titleLabel.alpha = 1.0;
    titleLabel.frame = [self titleLabelFrameForSize:size book:book];
    [self insertSubview:titleLabel belowSubview:self.overlayImageView];
    self.titleLabel = titleLabel;
}

- (void)updateCaption:(NSString *)caption book:(CKBook *)book {
    NSString *displayCaption = [caption uppercaseString];
    [self.captionLabel removeFromSuperview];
    
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    CGFloat singleLineHeight = [ViewHelper singleLineHeightForFont:[self coverCaptionFont]];
    CGSize size = [displayCaption sizeWithFont:[self coverCaptionFont]
                             constrainedToSize:CGSizeMake([self contentAvailableSize].width, singleLineHeight)
                                 lineBreakMode:lineBreakMode];
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    captionLabel.autoresizingMask = UIViewAutoresizingNone;
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.lineBreakMode = lineBreakMode;
    captionLabel.minimumScaleFactor = 0.7;
    captionLabel.font = [self coverCaptionFont];
    captionLabel.textColor = [self coverCaptionColour];
    captionLabel.shadowColor = [self coverCaptionShadowColor];
    captionLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    captionLabel.text = displayCaption;
    captionLabel.alpha = 1.0;
    captionLabel.frame = [self captionLabelFrameForSize:size book:book];
    [self insertSubview:captionLabel belowSubview:self.overlayImageView];
    self.captionLabel = captionLabel;
}

- (void)updateEditButtonWithBook:(CKBook *)book {
    if (!self.editButton) {
        UIEdgeInsets edgeInsets = [self contentEdgeInsets];
        UIButton *editButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_dash_icons_customise.png"] target:self selector:@selector(editTapped:)];
        editButton.frame = CGRectMake(self.bounds.size.width - editButton.frame.size.width - edgeInsets.right,
                                      edgeInsets.top - 3.0,
                                      editButton.frame.size.width,
                                      editButton.frame.size.height);
        [self addSubview:editButton];
        self.editButton = editButton;
    }
}

- (CGRect)nameLabelFrameForSize:(CGSize)size book:(CKBook *)book {
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    BookCoverLayout layout = [BookCover layoutForIllustration:book.illustration];
    CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);
    CGPoint origin = frame.origin;
    switch (layout) {
        case BookCoverLayout1:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), edgeInsets.top);
            break;
        case BookCoverLayout2:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0),  self.bounds.size.height - edgeInsets.bottom - size.height);
            break;
        case BookCoverLayout3:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0),  self.bounds.size.height - edgeInsets.bottom - size.height);
            break;
        case BookCoverLayout4:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), self.bounds.size.height - edgeInsets.bottom - size.height);
            break;
        case BookCoverLayout5:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), self.bounds.size.height - edgeInsets.bottom - size.height);
            break;
        default:
            break;
    }
    frame.origin = origin;
    return frame;
}

- (CGRect)titleLabelFrameForSize:(CGSize)size book:(CKBook *)book  {
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    BookCoverLayout layout = [BookCover layoutForIllustration:book.illustration];
    CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);
    CGPoint origin = frame.origin;
    switch (layout) {
        case BookCoverLayout1:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), edgeInsets.top + 10.0);
            break;
        case BookCoverLayout2:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), edgeInsets.top);
            break;
        case BookCoverLayout3:
            origin = CGPointMake(edgeInsets.left, edgeInsets.top);
            break;
        case BookCoverLayout4:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), self.bounds.size.height - edgeInsets.bottom - size.height - self.nameLabel.frame.size.height);
            break;
        case BookCoverLayout5:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), floorf((self.bounds.size.height - size.height) / 2.0) - 20.0);
            break;
        default:
            break;
    }
    frame.origin = origin;
    return frame;
}

- (CGRect)captionLabelFrameForSize:(CGSize)size book:(CKBook *)book  {
    UIEdgeInsets edgeInsets = [self contentEdgeInsets];
    BookCoverLayout layout = [BookCover layoutForIllustration:book.illustration];
    CGRect titleFrame = self.titleLabel.frame;
    CGFloat titleOffset = titleFrame.origin.y + titleFrame.size.height - 20.0;
    CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);
    CGPoint origin = frame.origin;
    switch (layout) {
        case BookCoverLayout1:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), titleOffset + 5.0);
            break;
        case BookCoverLayout2:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), titleOffset);
            break;
        case BookCoverLayout3:
            origin = CGPointMake(edgeInsets.left, titleOffset);
            break;
        case BookCoverLayout4:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), titleOffset);
            break;
        case BookCoverLayout5:
            origin = CGPointMake(floorf((self.bounds.size.width - size.width) / 2.0), titleOffset);
            break;
        default:
            break;
    }
    frame.origin = origin;
    return frame;
}

- (void)updateIfRequiredWithBook:(CKBook *)book {
    [self updateIfRequiredWithBook:book force:NO];
}

- (void)updateIfRequiredWithBook:(CKBook *)book force:(BOOL)force {
    
    // Update content if it's necessary.
    if (force || ![self.book.cover isEqualToString:book.cover]) {
        self.backgroundImageView.image = [BookCover imageForCover:book.cover];
    }
    if (force || ![self.book.illustration isEqualToString:book.illustration]) {
        self.illustrationImageView.image = [BookCover imageForIllustration:book.illustration];
    }
    
    [self updateName:[book userName] book:book];
    [self updateTitle:book.name book:book];
    [self updateCaption:book.caption book:book];
}

- (void)editTapped:(id)sender {
    DLog();
    [EventHelper postEditMode:YES];
}

@end
