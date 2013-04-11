//
//  BookTitleView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleView.h"
#import "Theme.h"
#import "CKBook.h"
#import "ImageHelper.h"
#import "CKMaskedLabel.h"
#import "CKUserProfilePhotoView.h"

@interface BookTitleView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKMaskedLabel *maskedLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;

@end

@implementation BookTitleView

#define kTitleInsets    UIEdgeInsetsMake(40.0, 40.0, 28.0, 40.0)
#define kTitleNameGap   0.0

+ (CGSize)headerSize {
    // Only height is used for a vertically scrolling collection view.
    return CGSizeMake(964.0, 520.0);
}

+ (CGSize)heroImageSize {
    CGSize headerSize = [BookTitleView headerSize];
    return CGSizeMake(headerSize.width, headerSize.height);
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        CGSize headerSize = [BookTitleView headerSize];
        
        // Pre-create the background image view to have exactly 964.0 width.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.frame = CGRectMake(floorf((self.bounds.size.width - headerSize.width) / 2.0),
                                     self.bounds.origin.y,
                                     headerSize.width,
                                     self.bounds.size.height);
        imageView.backgroundColor = [Theme categoryHeaderBackgroundColour];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        // Black overlay under the label.
        UIView *overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.alpha = 0.3;
        [self addSubview:overlayView];
        self.overlayView = overlayView;
        
        // Labels.
        CKMaskedLabel *maskedLabel = [[CKMaskedLabel alloc] initWithFrame:CGRectZero];
        maskedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        maskedLabel.numberOfLines = 2;
        maskedLabel.font = [Theme bookContentsTitleFont];
        maskedLabel.insets = kTitleInsets;
        [self addSubview:maskedLabel];
        self.maskedLabel = maskedLabel;
        
        UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        authorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        authorLabel.font = [Theme bookContentsNameFont];
        authorLabel.textColor = [Theme bookContentsNameColour];
        [self.maskedLabel addSubview:authorLabel];
        self.authorLabel = authorLabel;
        
        // Profile photo view.
        CKUserProfilePhotoView *profilePhotoView = [[CKUserProfilePhotoView alloc] initWithProfileSize:ProfileViewSizeMedium
                                                                                                border:YES];
        [self addSubview:profilePhotoView];
        self.profilePhotoView = profilePhotoView;
        
    }
    return self;
}

- (void)configureBook:(CKBook *)book {
    NSString *bookAuthor = [book.user.name uppercaseString];
    NSString *bookTitle = [NSString stringWithFormat:@"%@\u2028%@",[book.name uppercaseString], bookAuthor];
    NSAttributedString *titleDisplay = [self attributedTextForTitle:bookTitle titleFont:[Theme bookContentsTitleFont]
                                                             author:bookAuthor authorFont:[Theme bookContentsNameFont]];
    self.maskedLabel.attributedText = titleDisplay;
    
    // Figure out the required size with padding.
    CGSize availableSize = CGSizeMake(self.bounds.size.width - kTitleInsets.left - kTitleInsets.right, self.bounds.size.height);
    CGSize size = [self.maskedLabel sizeThatFits:availableSize];
    size.width += kTitleInsets.left + kTitleInsets.right;
    size.height += kTitleInsets.top + kTitleInsets.bottom;
    
    // Bump down font if exceeds maximum width.
    if (size.width >= availableSize.width) {
        titleDisplay = [self attributedTextForTitle:bookTitle titleFont:[Theme bookContentsTitleFont]
                                             author:bookAuthor authorFont:[Theme bookContentsNameFont]];
        self.maskedLabel.attributedText = titleDisplay;
        size = [self.maskedLabel sizeThatFits:availableSize];
        size.width += kTitleInsets.left + kTitleInsets.right;
        size.height += kTitleInsets.top + kTitleInsets.bottom;
    }
    
    // Set the frame in motion.
    self.maskedLabel.frame = CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                        floorf((self.bounds.size.height - size.height) / 2.0),
                                        size.width,
                                        size.height);
    self.overlayView.frame = self.maskedLabel.frame;
    
    // Load profile photoView.
    self.profilePhotoView.frame = CGRectMake(self.maskedLabel.frame.origin.x + floorf((self.maskedLabel.frame.size.width - self.profilePhotoView.frame.size.width) / 2.0),
                                             self.maskedLabel.frame.origin.y - floorf(self.profilePhotoView.frame.size.height / 2.0),
                                             self.profilePhotoView.frame.size.width,
                                             self.profilePhotoView.frame.size.height);
    [self.profilePhotoView loadProfilePhotoForUser:book.user];
}

- (void)configureImage:(UIImage *)image {
    [ImageHelper configureImageView:self.imageView image:image];
}

#pragma mark - Private methods

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font {
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = -10.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}

- (NSMutableAttributedString *)attributedTextForTitle:(NSString *)bookTitle titleFont:(UIFont *)titleFont
                                               author:(NSString *)author authorFont:(UIFont *)authorFont {
    NSDictionary *paragraphAttributes = [self paragraphAttributesForFont:titleFont];
    NSMutableAttributedString *titleDisplay = [[NSMutableAttributedString alloc] initWithString:bookTitle attributes:paragraphAttributes];
    [titleDisplay addAttribute:NSFontAttributeName
                         value:authorFont
                         range:NSMakeRange([bookTitle length] - [author length],
                                           [author length])];
    return titleDisplay;
}

@end
