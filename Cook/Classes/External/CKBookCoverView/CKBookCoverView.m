//
//  CKBookCoverView.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKBookCoverView.h"
#import "CKBookCover.h"

@interface CKBookCoverView ()

@property (nonatomic, assign) BookCoverLayout bookCoverLayout;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, strong) UILabel *layoutLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *captionLabel;

@end

@implementation CKBookCoverView

#define kContentInsets  UIEdgeInsetsMake(0.0, 10.0, 3.0, 5.0)
#define kOverlayDebug   0
#define kShadowColour   [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initBackground];
        
        if (kOverlayDebug) {
            UIView *contentOverlay = [[UIView alloc] initWithFrame:CGRectMake(kContentInsets.left,
                                                                              kContentInsets.top,
                                                                              self.bounds.size.width - kContentInsets.left - kContentInsets.right,
                                                                              self.bounds.size.height - kContentInsets.top - kContentInsets.bottom)];
            contentOverlay.backgroundColor = [UIColor whiteColor];
            contentOverlay.alpha = 0.3;
            [self addSubview:contentOverlay];
        }
        
    }
    return self;
}

- (void)setCover:(NSString *)cover illustration:(NSString *)illustration {
    self.illustrationImageView.image = [CKBookCover imageForIllustration:illustration];
    [self setLayout:[CKBookCover layoutForIllustration:illustration]];
    self.backgroundImageView.image = [CKBookCover imageForCover:cover];
}

- (void)setTitle:(NSString *)title author:(NSString *)author caption:(NSString *)caption {
    
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            [self setAuthor:[author uppercaseString]];
            [self setTitle:[title uppercaseString]];
            [self setCaption:caption];
            break;
        case BookCoverLayout2:
        case BookCoverLayout3:
        case BookCoverLayout4:
        case BookCoverLayout5:
        default:
            [self setAuthor:[author uppercaseString]];
            [self setCaption:caption];
            [self setTitle:[title uppercaseString]];
            break;
    }
}

#pragma mark - Private methods

- (void)initBackground {
    
    // Starts with the gray cover.
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[CKBookCover placeholderCoverImage]];
    backgroundImageView.frame = CGRectMake(floorf((self.frame.size.width - backgroundImageView.frame.size.width) / 2.0),
                                           floorf((self.frame.size.height - backgroundImageView.frame.size.height) / 2.0),
                                           backgroundImageView.frame.size.width,
                                           backgroundImageView.frame.size.height);
    [self addSubview:backgroundImageView];
    self.backgroundImageView = backgroundImageView;
    
    // Overlay
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[CKBookCover overlayImage]];
    overlayImageView.frame = backgroundImageView.frame;
    [self insertSubview:overlayImageView aboveSubview:backgroundImageView];
    self.overlayImageView = overlayImageView;
    
    // Illustration.
    UIImageView *illustrationImageView = [[UIImageView alloc] initWithImage:nil];
    illustrationImageView.frame = backgroundImageView.frame;
    [self insertSubview:illustrationImageView aboveSubview:backgroundImageView];
    self.illustrationImageView = illustrationImageView;
}

- (void)setLayout:(BookCoverLayout)layout {
    self.bookCoverLayout = layout;
    
    if (kOverlayDebug) {
        if (!self.layoutLabel) {
            UILabel *layoutLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            layoutLabel.autoresizingMask = UIViewAutoresizingNone;
            layoutLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:layoutLabel];
            self.layoutLabel = layoutLabel;
        }
        
        NSString *layoutDisplay = [NSString stringWithFormat:@"%d", layout + 1];
        NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
        UIFont *font = [UIFont boldSystemFontOfSize:12.0];
        CGSize size = [layoutDisplay sizeWithFont:font
                                constrainedToSize:self.bounds.size
                                    lineBreakMode:lineBreakMode];
        self.layoutLabel.frame = CGRectMake(self.bounds.size.width - kContentInsets.right - size.width,
                                            kContentInsets.top,
                                            size.width,
                                            size.height);
        self.layoutLabel.lineBreakMode = lineBreakMode;
        self.layoutLabel.minimumScaleFactor = 0.7;
        self.layoutLabel.font = font;
        self.layoutLabel.textColor = [UIColor whiteColor];
        self.layoutLabel.text = layoutDisplay;
    }
}

- (CGSize)lineSizeForFont:(UIFont *)font lines:(NSInteger)lines {
    CGSize singleLineSize = [self singleLineSizeForFont:font];
    return CGSizeMake(singleLineSize.width, singleLineSize.height * 2.0);
}

- (CGSize)singleLineSizeForFont:(UIFont *)font {
    CGFloat singleLineHeight = [@"A" sizeWithFont:font constrainedToSize:self.bounds.size lineBreakMode:NSLineBreakByTruncatingTail].height;
    return CGSizeMake([self availableContentSize].width, singleLineHeight);
}

- (CGSize)singleLineSizeForLabel:(UILabel *)label attributes:(NSDictionary *)attributes {
    label.attributedText = [[NSAttributedString alloc] initWithString:@"A" attributes:attributes];
    return [label sizeThatFits:[self availableContentSize]];
}

- (CGSize)lineSizeForLabel:(UILabel *)label attributedString:(NSAttributedString *)attributedString {
    label.attributedText = attributedString;
    return [label sizeThatFits:[self availableContentSize]];
}

- (CGSize)availableContentSize {
    return CGSizeMake(self.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

#pragma mark - Frames

// BookCoverLayout1: authorLabel
// BookCoverLayout2: captionLabel
// BookCoverLayout3: captionLabel
// BookCoverLayout4: captionLabel
- (CGRect)titleFrameForSize:(CGSize)size {
    CGRect frame = CGRectZero;
    CGSize availableSize = [self availableContentSize];
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.authorLabel.frame.origin.y + self.authorLabel.frame.size.height + 24.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout2:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.captionLabel.frame.origin.y - size.height - 5.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout3:
            frame = CGRectMake(kContentInsets.left,
                               self.captionLabel.frame.origin.y - size.height,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout4:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.captionLabel.frame.origin.y - size.height,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout5:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.captionLabel.frame.origin.y - size.height,
                               size.width,
                               size.height);
            break;
        default:
            break;
    }
    return frame;
}

- (CGRect)authorFrameForSize:(CGSize)size {
    CGRect frame = CGRectZero;
    CGSize availableSize = [self availableContentSize];
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               kContentInsets.top + 10.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout2:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.bounds.size.height - kContentInsets.bottom - size.height - 5.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout3:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.bounds.size.height - kContentInsets.bottom - size.height - 5.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout4:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.bounds.size.height - kContentInsets.bottom - size.height - 5.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout5:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.bounds.size.height - kContentInsets.bottom - size.height - 5.0,
                               size.width,
                               size.height);
            break;
        default:
            break;
    }
    return frame;
}

// BookCoverLayout1: titleLabel
// BookCoverLayout2:
// BookCoverLayout3:
// BookCoverLayout4: authorLabel
- (CGRect)captionFrameForSize:(CGSize)size {
    CGRect frame = CGRectZero;
    CGSize availableSize = [self availableContentSize];
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout2:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               floorf((availableSize.height - size.height) / 2.0) - 30.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout3:
            frame = CGRectMake(kContentInsets.left + 5.0,
                               floorf((availableSize.height - size.height) / 2.0) - 70.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout4:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               self.authorLabel.frame.origin.y - size.height - 5.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout5:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               floorf((availableSize.height - size.height) / 2.0),
                               size.width,
                               size.height);
            break;
        default:
            break;
    }
    return frame;
}

#pragma mark - Text alignments

- (NSTextAlignment)titleTextAlignment {
    NSTextAlignment textAligntment = NSTextAlignmentCenter;
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            textAligntment = NSTextAlignmentCenter;
            break;
        case BookCoverLayout2:
            textAligntment = NSTextAlignmentCenter;
            break;
        case BookCoverLayout3:
            textAligntment = NSTextAlignmentLeft;
            break;
        case BookCoverLayout4:
            textAligntment = NSTextAlignmentCenter;
            break;
        case BookCoverLayout5:
            textAligntment = NSTextAlignmentCenter;
            break;
        default:
            break;
    }
    return textAligntment;
}

#pragma mark - Elements

- (void)setAuthor:(NSString *)author {
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    UIFont *font = [UIFont fontWithName:@"Neutraface2Condensed-Bold" size:20];
    
    if (!self.authorLabel) {
        UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        authorLabel.autoresizingMask = UIViewAutoresizingNone;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.textColor = [UIColor whiteColor];
        authorLabel.shadowColor = kShadowColour;
        authorLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        authorLabel.lineBreakMode = lineBreakMode;
        authorLabel.minimumScaleFactor = 0.7;
        authorLabel.font = font;
        if (kOverlayDebug) {
            authorLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        [self addSubview:authorLabel];
        self.authorLabel = authorLabel;
    }
    
    
    CGSize size = [author sizeWithFont:font constrainedToSize:[self singleLineSizeForFont:font] lineBreakMode:lineBreakMode];
    self.authorLabel.frame = [self authorFrameForSize:size];
    self.authorLabel.text = author;
}

- (void)setCaption:(NSString *)caption {
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    UIFont *font = [UIFont fontWithName:@"Neutraface2Condensed-Medium" size:24];
    
    if (!self.captionLabel) {
        UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        captionLabel.autoresizingMask = UIViewAutoresizingNone;
        captionLabel.backgroundColor = [UIColor clearColor];
        captionLabel.shadowColor = kShadowColour;
        captionLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        captionLabel.lineBreakMode = lineBreakMode;
        captionLabel.minimumScaleFactor = 0.7;
        captionLabel.font = font;
        captionLabel.textColor = [UIColor whiteColor];
        if (kOverlayDebug) {
            captionLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        [self addSubview:captionLabel];
        self.captionLabel = captionLabel;
    }
    
    CGSize size = [caption sizeWithFont:font constrainedToSize:[self singleLineSizeForFont:font] lineBreakMode:lineBreakMode];
    self.captionLabel.frame = [self captionFrameForSize:size];
    self.captionLabel.text = caption;
}

- (void)setTitle:(NSString *)title {
    if (!self.titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.autoresizingMask = UIViewAutoresizingNone;
        titleLabel.backgroundColor = [UIColor clearColor];
        if (kOverlayDebug) {
            titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        self.titleLabel.numberOfLines = 0;
    }
    
    UIFont *minFont = [UIFont fontWithName:@"Neutraface2Condensed-Bold" size:60];
    UIFont *midFont = [UIFont fontWithName:@"Neutraface2Condensed-Bold" size:68];
    UIFont *maxFont = [UIFont fontWithName:@"Neutraface2Condensed-Bold" size:100];
    
    // Paragraph style.
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = -10.0;
    paragraphStyle.alignment = [self titleTextAlignment];
    paragraphStyle.paragraphSpacingBefore = 0.0;
    paragraphStyle.paragraphSpacing = 0.0;
    
    // Attributed text
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = kShadowColour;
    shadow.shadowOffset = CGSizeMake(0.0, -1.0);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       maxFont, NSFontAttributeName,
                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                       shadow, NSShadowAttributeName,
                                       paragraphStyle, NSParagraphStyleAttributeName,
                                       nil];
    NSAttributedString *titleDisplay = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    
    // Figure out required line height vs single line height.
    CGSize singleLineSize = [self singleLineSizeForLabel:self.titleLabel attributes:attributes];
    CGSize lineSize = [self lineSizeForLabel:self.titleLabel attributedString:titleDisplay];
    DLog(@"Required Height: %f", lineSize.height);
    DLog(@"Single   Height: %f", singleLineSize.height);
    if (lineSize.height > singleLineSize.height) {
        
        // If more than 14 characters, bump down the font again.
        if ([titleDisplay.string length] > 16) {
            [attributes setObject:minFont forKey:NSFontAttributeName];
        } else {
            [attributes setObject:midFont forKey:NSFontAttributeName];
        }
        titleDisplay = [[NSMutableAttributedString alloc] initWithString:title attributes:attributes];
    }
    
    self.titleLabel.attributedText = titleDisplay;
    CGSize size = [self.titleLabel sizeThatFits:[self availableContentSize]];
    self.titleLabel.frame = [self titleFrameForSize:size];
}


@end
