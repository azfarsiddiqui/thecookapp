//
//  CKBookCoverView.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKBookCoverView.h"
#import "CKBookCover.h"
#import "CKEditableView.h"
#import "Theme.h"
#import "CKTextFieldEditingViewController.h"

@interface CKBookCoverView () <CKEditableViewDelegate, CKEditingViewControllerDelegate>

@property (nonatomic, assign) id<CKBookCoverViewDelegate> delegate;
@property (nonatomic, assign) BookCoverLayout bookCoverLayout;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, strong) UILabel *layoutLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) CKEditableView *authorEditableView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CKEditableView *titleEditableView;
@property (nonatomic, strong) CKEditableView *captionEditableView;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL multilineTitle;

@property (nonatomic, strong) CKTextFieldEditingViewController *textEditingViewController;

@end

@implementation CKBookCoverView

#define kContentInsets  UIEdgeInsetsMake(0.0, 25.0, 10.0, 15.0)
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

- (id)initWithFrame:(CGRect)frame delegate:(id<CKBookCoverViewDelegate>)delegate {
    if (self = [self initWithFrame:frame]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setCover:(NSString *)cover illustration:(NSString *)illustration {
    self.illustrationImageView.image = [CKBookCover imageForIllustration:illustration];
    [self setLayout:[CKBookCover layoutForIllustration:illustration]];
    self.backgroundImageView.image = [CKBookCover imageForCover:cover];
}

- (void)setTitle:(NSString *)title author:(NSString *)author caption:(NSString *)caption editable:(BOOL)editable {
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
        case BookCoverLayout2:
        case BookCoverLayout3:
        case BookCoverLayout4:
        default:
            [self setTitle:[title uppercaseString]];
            [self setAuthor:[author uppercaseString]];
            [self setCaption:caption];
            break;
    }
    [self enableEditable:editable];
}

- (void)enableEditMode:(BOOL)enable {
    self.editMode = enable;
    self.editButton.hidden = enable;
    [self.authorEditableView enableEditMode:enable];
    [self.captionEditableView enableEditMode:enable];
    [self.titleEditableView enableEditMode:enable];
}

#pragma mark - CKEditableViewDelegate methods

- (void)editableViewEditRequestedForView:(UIView *)view {
    UIView *rootView = [self rootView];
    CKTextFieldEditingViewController *editingViewController = [[CKTextFieldEditingViewController alloc] initWithDelegate:self];
    editingViewController.textAlignment = NSTextAlignmentCenter;
    editingViewController.view.frame = [self rootView].bounds;
    [rootView addSubview:editingViewController.view];
    self.textEditingViewController = editingViewController;

    if (view == self.authorEditableView) {
        UILabel *authorLabel = (UILabel *)self.authorEditableView.contentView;
        editingViewController.editableTextFont = [Theme bookCoverEditableAuthorTextFont];
        editingViewController.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        editingViewController.characterLimit = 20;
        editingViewController.text = authorLabel.text;
        editingViewController.sourceEditingView = self.authorEditableView;
        editingViewController.editingTitle = @"Book Author";
        [editingViewController enableEditing:YES completion:nil];
    } else if (view == self.captionEditableView) {
        UILabel *captionLabel = (UILabel *)self.captionEditableView.contentView;
        editingViewController.editableTextFont = [Theme bookCoverEditableCaptionTextFont];
        editingViewController.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        editingViewController.characterLimit = 40;
        editingViewController.text = captionLabel.text;
        editingViewController.sourceEditingView = self.captionEditableView;
        editingViewController.editingTitle = @"Book Caption";
        [editingViewController enableEditing:YES completion:nil];
    } else if (view == self.titleEditableView) {
        UILabel *titleLabel = (UILabel *)self.titleEditableView.contentView;
        editingViewController.editableTextFont = [Theme bookCoverEditableTitleTextFont];
        editingViewController.titleFont = [Theme bookCoverEditableFieldDescriptionFont];
        editingViewController.characterLimit = 20;
        editingViewController.text = titleLabel.text;
        editingViewController.sourceEditingView = self.titleEditableView;
        editingViewController.editingTitle = @"Book Title";
        [editingViewController enableEditing:YES completion:nil];
    } 
}

#pragma mark - CKEditingViewControllerDelegate methods

- (void)editingViewWillAppear:(BOOL)appear {
    
}

- (void)editingViewDidAppear:(BOOL)appear {
    if (!appear) {
        [self.textEditingViewController.view removeFromSuperview];
        self.textEditingViewController = nil;
    }
}

-(void)editingView:(UIView *)editingView saveRequestedWithResult:(id)result {
    if (editingView == self.authorEditableView) {
        NSString *author = (NSString *)result;
        [self setAuthor:author];
        [self.authorEditableView enableEditMode:YES];
    } else if (editingView == self.captionEditableView) {
        NSString *caption = (NSString *)result;
        [self setCaption:caption];
        [self.captionEditableView enableEditMode:YES];
    } else if (editingView == self.titleEditableView) {
        NSString *title = (NSString *)result;
        [self setTitle:title];
        [self.titleEditableView enableEditMode:YES];
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

// BookCoverLayout1: authorTextField
// BookCoverLayout2: captionTextField
// BookCoverLayout3: captionTextField
// BookCoverLayout4: captionTextField
- (CGRect)titleFrameForSize:(CGSize)size {
    CGRect frame = CGRectZero;
    CGSize availableSize = [self availableContentSize];
    CGFloat anchor = [self titleAnchor];
    
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               anchor - floorf(size.height / 2.0),
                               size.width,
                               size.height);
            break;
        case BookCoverLayout2:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               anchor - floorf(size.height / 2.0),
                               size.width,
                               size.height);
            break;
        case BookCoverLayout3:
            frame = CGRectMake(kContentInsets.left,
                               anchor - floorf(size.height / 2.0),
                               size.width,
                               size.height);
            break;
        case BookCoverLayout4:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               anchor - floorf(size.height / 2.0),
                               size.width,
                               size.height);
            break;
        default:
            break;
    }
    return frame;
}

- (CGRect)titleEditableAdjustedFrameWithSize:(CGSize)size {
    CGRect frame = CGRectZero;
    CGSize availableSize = [self availableContentSize];
    CGFloat anchor = [self titleAnchor];
    CGFloat width = (size.width > availableSize.width) ? size.width : availableSize.width;
    width = (self.titleEditableView.frame.size.width > width) ? self.titleEditableView.frame.size.width : width;
    CGFloat sideOffset = kContentInsets.left - 5.0;
    CGFloat topOffset = anchor - floorf(size.height / 2.0) - 6.0;
    
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            frame = CGRectMake(sideOffset,
                               topOffset,
                               width,
                               size.height);
            break;
        case BookCoverLayout2:
            frame = CGRectMake(sideOffset,
                               topOffset,
                               width,
                               size.height);
            break;
        case BookCoverLayout3:
            frame = CGRectMake(sideOffset,
                               topOffset,
                               width,
                               size.height);
            break;
        case BookCoverLayout4:
            frame = CGRectMake(sideOffset,
                               topOffset,
                               width,
                               size.height);
            break;
        default:
            break;
    }
    return frame;
}

- (CGFloat)titleAnchor {
    CGFloat offset = 0.0;
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            offset = 110.0;
            break;
        case BookCoverLayout2:
            offset = 330.0;
            break;
        case BookCoverLayout3:
            offset = 90.0;
            break;
        case BookCoverLayout4:
            offset = 200.0;
            break;
        default:
            break;
    }
    return offset;
}

- (CGRect)authorFrameForSize:(CGSize)size {
    CGRect frame = CGRectZero;
    CGFloat sideOffset = 30.0;
    CGSize availableSize = [self availableContentSize];
    UIEdgeInsets authorInsets = UIEdgeInsetsMake(kContentInsets.top, kContentInsets.left + sideOffset, kContentInsets.bottom, kContentInsets.right + sideOffset);
    availableSize = CGSizeMake(availableSize.width - (sideOffset * 2.0), availableSize.height);
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            frame = CGRectMake(authorInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               authorInsets.top + 10.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout2:
            frame = CGRectMake(authorInsets.left,
                               authorInsets.top + 10.0,
                               availableSize.width,
                               size.height);
            break;
        case BookCoverLayout3:
            frame = CGRectMake(authorInsets.left,
                               self.bounds.size.height - kContentInsets.bottom - size.height,
                               availableSize.width,
                               size.height);
            break;
        case BookCoverLayout4:
            frame = CGRectMake(authorInsets.left,
                               self.titleLabel.frame.origin.y - size.height,
                               availableSize.width,
                               size.height);
            break;
        default:
            break;
    }
    return frame;
}

- (CGRect)authorEditableAdjustedFrameWithSize:(CGSize)size {
    CGRect frame = CGRectZero;
    CGFloat sideOffset = 30.0;
    CGSize availableSize = [self availableContentSize];
    UIEdgeInsets authorInsets = UIEdgeInsetsMake(kContentInsets.top, kContentInsets.left + sideOffset, kContentInsets.bottom, kContentInsets.right + sideOffset);
    availableSize = CGSizeMake(availableSize.width - (sideOffset * 2.0), availableSize.height);
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            frame = CGRectMake(authorInsets.left + floorf((availableSize.width - size.width) / 2.0) - 2.0,
                               authorInsets.top + 4.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout2:
            frame = CGRectMake(authorInsets.left + floorf((availableSize.width - size.width) / 2.0) - 2.0,
                               authorInsets.top + 4.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout3:
            frame = CGRectMake(authorInsets.left + floorf((availableSize.width - size.width) / 2.0) - 2.0,
                               self.bounds.size.height - kContentInsets.bottom - size.height,
                               size.width,
                               size.height);
            break;
        case BookCoverLayout4:
            frame = CGRectMake(authorInsets.left + floorf((availableSize.width - size.width) / 2.0) - 2.0,
                               self.titleLabel.frame.origin.y - size.height,
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
// BookCoverLayout4: authorTextField
- (CGRect)captionFrameForSize:(CGSize)size {
    CGRect frame = CGRectZero;
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
        case BookCoverLayout2:
        case BookCoverLayout3:
        case BookCoverLayout4:
        default:
            frame = CGRectMake(kContentInsets.left,
                               self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + (self.multilineTitle ? -9.0 : -16.0),
                               size.width,
                               size.height);
            break;
    }
    return frame;
}

- (CGRect)captionEditableAdjustedFrameWithSize:(CGSize)size {
    CGRect frame = CGRectZero;
    CGSize availableSize = [self availableContentSize];
    CGFloat width = (size.width > availableSize.width) ? size.width : availableSize.width;
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
        case BookCoverLayout2:
        case BookCoverLayout3:
        case BookCoverLayout4:
        default:
            frame = CGRectMake(kContentInsets.left - 5.0,
                               self.titleEditableView.frame.origin.y + self.titleEditableView.frame.size.height + (self.multilineTitle ? -7.0 : -18.0),
                               width,
                               size.height);
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

- (NSTextAlignment)authorTextAlignment {
    NSTextAlignment textAligntment = NSTextAlignmentCenter;
    switch (self.bookCoverLayout) {
        case BookCoverLayout1:
            textAligntment = NSTextAlignmentCenter;
            break;
        case BookCoverLayout2:
            textAligntment = NSTextAlignmentCenter;
            break;
        case BookCoverLayout3:
            textAligntment = NSTextAlignmentCenter;
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

- (NSTextAlignment)captionTextAlignment {
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
    self.authorValue = author;
    UIFont *font = [Theme bookCoverViewModeAuthorFont];
    UIEdgeInsets editableInsets = UIEdgeInsetsMake(3.0, 5.0, -4.0, 4.0);
    CGSize availableSize = [self availableContentSize];
    
    if (!self.authorEditableView) {
        UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        authorLabel.autoresizingMask = UIViewAutoresizingNone;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.font = font;
        authorLabel.textColor = [UIColor whiteColor];
        if (kOverlayDebug) {
            authorLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }

        CKEditableView *authorEditableView = [[CKEditableView alloc] initWithDelegate:self];
        authorEditableView.contentInsets = editableInsets;
        authorEditableView.contentView = authorLabel;
        [self addSubview:authorEditableView];
        self.authorEditableView = authorEditableView;
    }
    
    UILabel *authorLabel = (UILabel *)self.authorEditableView.contentView;
    authorLabel.textAlignment = [self authorTextAlignment];
    authorLabel.text = author;
    [authorLabel sizeToFit];
    authorLabel.frame = CGRectMake(0.0, 0.0, availableSize.width, authorLabel.frame.size.height);
    self.authorEditableView.contentView = authorLabel;
    self.authorEditableView.frame = [self authorEditableAdjustedFrameWithSize:self.authorEditableView.frame.size];
}

- (void)setCaption:(NSString *)caption {
    self.captionValue = caption;
    UIFont *font = [Theme bookCoverViewModeCaptionFont];
    UIEdgeInsets editableInsets = UIEdgeInsetsMake(3.0, 5.0, -4.0, 4.0);
    CGSize availableSize = [self availableContentSize];
    
    if (!self.captionEditableView) {
        UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        captionLabel.autoresizingMask = UIViewAutoresizingNone;
        captionLabel.backgroundColor = [UIColor clearColor];
        captionLabel.font = font;
        captionLabel.textColor = [UIColor whiteColor];
        if (kOverlayDebug) {
            captionLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }

        CKEditableView *captionEditableView = [[CKEditableView alloc] initWithDelegate:self];
        captionEditableView.contentInsets = editableInsets;
        captionEditableView.contentView = captionLabel;
        [self addSubview:captionEditableView];
        self.captionEditableView = captionEditableView;
    }
    
    UILabel *captionLabel = (UILabel *)self.captionEditableView.contentView;
    captionLabel.textAlignment = [self captionTextAlignment];
    captionLabel.text = caption;
    [captionLabel sizeToFit];
    captionLabel.frame = CGRectMake(0.0, 0.0, availableSize.width, captionLabel.frame.size.height);
    self.captionEditableView.contentView = captionLabel;
    self.captionEditableView.frame = [self captionEditableAdjustedFrameWithSize:self.captionEditableView.frame.size];
}

- (void)setTitle:(NSString *)title {
    self.titleValue = title;
    UIEdgeInsets editableInsets = UIEdgeInsetsMake(3.0, 5.0, -4.0, 4.0);
    CGSize availableSize = [self availableContentSize];
    
    if (!self.titleEditableView) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.autoresizingMask = UIViewAutoresizingNone;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 0;
        if (kOverlayDebug) {
            titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        
        CKEditableView *titleEditableView = [[CKEditableView alloc] initWithDelegate:self];
        titleEditableView.contentInsets = editableInsets;
        titleEditableView.contentView = titleLabel;
        [self addSubview:titleEditableView];
        self.titleEditableView = titleEditableView;
    }
    
    UIFont *minFont = [Theme bookCoverViewModeTitleMinFont];
    UIFont *midFont = [Theme bookCoverViewModeTitleMidFont];
    UIFont *maxFont = [Theme bookCoverViewModeTitleMaxFont];
    
    UILabel *titleLabel = (UILabel *)self.titleEditableView.contentView;
    titleLabel.textAlignment = [self titleTextAlignment];
    
    // Paragraph style.
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = -10.0;
    paragraphStyle.alignment = [self titleTextAlignment];
    
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
    CGSize singleLineSize = [self singleLineSizeForLabel:titleLabel attributes:attributes];
    CGSize lineSize = [self lineSizeForLabel:titleLabel attributedString:titleDisplay];
    if (lineSize.height > singleLineSize.height * 2.0) {
        self.multilineTitle = YES;
        [attributes setObject:minFont forKey:NSFontAttributeName];
        titleDisplay = [[NSMutableAttributedString alloc] initWithString:title attributes:attributes];
    } else if (lineSize.height > singleLineSize.height) {
        self.multilineTitle = YES;
        [attributes setObject:midFont forKey:NSFontAttributeName];
        titleDisplay = [[NSMutableAttributedString alloc] initWithString:title attributes:attributes];
    } else {
        self.multilineTitle = NO;
    }
    
    titleLabel.attributedText = titleDisplay;
    [titleLabel sizeToFit];
    CGSize size = [titleLabel sizeThatFits:[self availableContentSize]];
    titleLabel.frame = CGRectMake(0.0, 0.0, availableSize.width, size.height);
    self.titleEditableView.contentView = titleLabel;
    self.titleEditableView.frame = [self titleEditableAdjustedFrameWithSize:size];
}

- (void)enableEditable:(BOOL)editable {
    self.editable = editable;
    if (editable && !self.editButton) {
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *editImage = [UIImage imageNamed:@"cook_dash_icons_customise.png"];
        [editButton setBackgroundImage:editImage forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editTapped:) forControlEvents:UIControlEventTouchUpInside];
        editButton.frame = CGRectMake(self.bounds.size.width - editImage.size.width - 7.0,
                                      5.0,
                                      editImage.size.width,
                                      editImage.size.height);
        [self addSubview:editButton];
        self.editButton = editButton;
    } else if (!editable) {
        [self.editButton removeFromSuperview];
        self.editButton = nil;
    }
    
    // Reset the editable mode of the fields to NO.
    [self enableEditMode:NO];
}

- (void)editTapped:(id)sender {
    DLog(@"editTapped");
    
    // Inform delegate edit has been requested.
    [self.delegate bookCoverViewEditRequested];
    
}

- (UIView *)rootView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

@end
