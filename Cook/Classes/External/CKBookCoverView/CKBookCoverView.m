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
#import "CKTextFieldEditViewController.h"
#import "CKEditingViewHelper.h"

@interface CKBookCoverView () <CKEditableViewDelegate, CKEditingTextBoxViewDelegate,
    CKEditViewControllerDelegate>

@property (nonatomic, assign) id<CKBookCoverViewDelegate> delegate;
@property (nonatomic, assign) BookCoverLayout bookCoverLayout;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, strong) UIView *contentOverlay;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL multilineTitle;

@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKEditViewController *editViewController;

@end

@implementation CKBookCoverView

#define kContentInsets  UIEdgeInsetsMake(0.0, 13.0, 28.0, 10.0)
#define kOverlayDebug   1
#define kShadowColour   [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initBackground];
        
        // Content overlay.
        UIView *contentOverlay = [[UIView alloc] initWithFrame:CGRectZero];
        contentOverlay.backgroundColor = kOverlayDebug ? [UIColor whiteColor] : [UIColor clearColor];;
        contentOverlay.alpha = kOverlayDebug ? 0.3 : 1.0;
        [self addSubview:contentOverlay];
        self.contentOverlay = contentOverlay;
        
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
    [self setLayout:[CKBookCover layoutForIllustration:illustration]];
    self.illustrationImageView.image = [CKBookCover imageForIllustration:illustration];
    self.backgroundImageView.image = [CKBookCover imageForCover:cover];
}

- (void)setTitle:(NSString *)title author:(NSString *)author editable:(BOOL)editable {
    DLog(@"Book[%@] Author[%@] Layout[%d]", title, author, self.bookCoverLayout);
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
        case BookCoverLayoutBottom:
        default:
            [self setName:[author uppercaseString]];
            [self setTitle:[title uppercaseString]];
            break;
    }
    [self enableEditable:editable];
}

- (void)enableEditMode:(BOOL)enable {
    self.editMode = enable;
    self.editButton.hidden = enable;
    
    if (enable) {
        [self.editingHelper wrapEditingView:self.titleLabel
                              contentInsets:UIEdgeInsetsMake(18.0, 9.0, -7.0, 11.0)
                                   delegate:self white:NO];
        [self.editingHelper wrapEditingView:self.nameLabel
                              contentInsets:UIEdgeInsetsMake(18.0, 9.0, -7.0, 11.0)
                                   delegate:self white:NO];
    } else {
        [self.editingHelper unwrapEditingView:self.titleLabel];
        [self.editingHelper unwrapEditingView:self.nameLabel];
    }
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    if (editingView == self.titleLabel) {
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:NO
                                                                                                              title:@"Author"
                                                                                                     characterLimit:20];
        self.editViewController = editViewController;
    } else if (editingView == self.nameLabel) {
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:NO
                                                                                                              title:@"Title"
                                                                                                     characterLimit:20];
        self.editViewController = editViewController;
    }
    [self.editViewController performEditing:YES];
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
    DLog(@"%@", appear ? @"YES" : @"NO");
}

- (void)editViewControllerDidAppear:(BOOL)appear {
    DLog(@"%@", appear ? @"YES" : @"NO");
    if (!appear) {
        [self.editViewController.view removeFromSuperview];
        self.editViewController = nil;
    }
}

- (void)editViewControllerDismissRequested {
    [self.editViewController performEditing:NO];
}

- (void)editViewControllerEditRequested {
    // TODO REMOVE
}

- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value {
    
    if (editingView == self.titleLabel) {
        
        // Get updated value and update label.
        NSString *text = (NSString *)value;
        if (![text isEqualToString:self.titleLabel.text]) {
            [self setTitle:text];
            
            // Update the editing wrapper.
            [self.editingHelper updateEditingView:self.titleLabel animated:NO];
        }
        
    } else if (editingView == self.nameLabel) {
        
        // Get updated value and update label.
        NSString *text = (NSString *)value;
        if (![text isEqualToString:self.nameLabel.text]) {
            [self setName:text];
            
            // Update the editing wrapper.
            [self.editingHelper updateEditingView:self.nameLabel animated:NO];
        }
        
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
    self.contentOverlay.frame = [self contentFrameForLayout];
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

- (CGRect)titleFrameForSize:(CGSize)size {
    CGRect frame = CGRectZero;
    CGSize availableSize = [self availableContentSize];
    
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               kContentInsets.top + 50.0,
                               size.width,
                               size.height);
            break;
        case BookCoverLayoutBottom:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               availableSize.height - kContentInsets.bottom - size.height - 50.0,
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
        case BookCoverLayoutTop:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               kContentInsets.top,
                               size.width,
                               size.height);
            break;
        case BookCoverLayoutBottom:
            frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                               availableSize.height - kContentInsets.bottom - size.height,
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
        case BookCoverLayoutTop:
        case BookCoverLayoutBottom:
        default:
            textAligntment = NSTextAlignmentCenter;
            break;
    }
    return textAligntment;
}

- (NSTextAlignment)authorTextAlignment {
    NSTextAlignment textAligntment = NSTextAlignmentCenter;
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
        case BookCoverLayoutBottom:
        default:
            textAligntment = NSTextAlignmentCenter;
            break;
    }
    return textAligntment;
}

#pragma mark - Elements

- (void)setTitle:(NSString *)author {
    self.authorValue = author;
    UIFont *font = [Theme bookCoverViewModeTitleFont];
    
    if (!self.titleLabel) {
        UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        authorLabel.autoresizingMask = UIViewAutoresizingNone;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.font = font;
        authorLabel.textColor = [UIColor whiteColor];
        if (kOverlayDebug) {
            authorLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        [self addSubview:authorLabel];
        self.titleLabel = authorLabel;
    }
    
    self.titleLabel.textAlignment = [self authorTextAlignment];
    self.titleLabel.text = author;
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = [self authorFrameForSize:self.titleLabel.frame.size];
}

- (void)setName:(NSString *)name {
    self.nameValue = name;
    
    if (!self.nameLabel) {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.autoresizingMask = UIViewAutoresizingNone;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.numberOfLines = 0;
        if (kOverlayDebug) {
            nameLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
    }
    
    UIFont *minFont = [Theme bookCoverViewModeNameMinFont];
    UIFont *midFont = [Theme bookCoverViewModeNameMidFont];
    UIFont *maxFont = [Theme bookCoverViewModeNameMaxFont];
    
    self.nameLabel.textAlignment = [self titleTextAlignment];
    
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
    NSAttributedString *titleDisplay = [[NSAttributedString alloc] initWithString:name attributes:attributes];
    
    // Figure out required line height vs single line height.
    CGSize singleLineSize = [self singleLineSizeForLabel:self.nameLabel attributes:attributes];
    CGSize lineSize = [self lineSizeForLabel:self.nameLabel attributedString:titleDisplay];
    
    if (lineSize.height > singleLineSize.height * 2.0) {
        self.multilineTitle = YES;
        [attributes setObject:minFont forKey:NSFontAttributeName];
        titleDisplay = [[NSMutableAttributedString alloc] initWithString:name attributes:attributes];
    } else if (lineSize.width > 240.0) {
        self.multilineTitle = YES;
        [attributes setObject:minFont forKey:NSFontAttributeName];
        titleDisplay = [[NSMutableAttributedString alloc] initWithString:name attributes:attributes];
    } else if (lineSize.height > singleLineSize.height) {
        self.multilineTitle = YES;
        [attributes setObject:midFont forKey:NSFontAttributeName];
        titleDisplay = [[NSMutableAttributedString alloc] initWithString:name attributes:attributes];
    } else {
        self.multilineTitle = NO;
    }
    
    // DLog(@"Book Title [%@] Size [%@] Available [%@] Font [%@]", title, NSStringFromCGSize(lineSize), NSStringFromCGSize([self availableContentSize]), [attributes objectForKey:NSFontAttributeName]);
    
    self.nameLabel.attributedText = titleDisplay;
    CGSize size = [self.nameLabel sizeThatFits:[self availableContentSize]];
    self.nameLabel.frame = [self titleFrameForSize:size];
}

- (void)enableEditable:(BOOL)editable {
    self.editable = editable;
    if (editable) {
        if (!self.editButton) {
            UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *editImage = [UIImage imageNamed:@"cook_dash_icons_customise.png"];
            [editButton setBackgroundImage:editImage forState:UIControlStateNormal];
            [editButton addTarget:self action:@selector(editTapped:) forControlEvents:UIControlEventTouchUpInside];
            editButton.frame = CGRectMake(self.bounds.size.width - editImage.size.width + 8.0,
                                          -20.0,
                                          editImage.size.width,
                                          editImage.size.height);
            [self addSubview:editButton];
            self.editButton = editButton;
        }
        
        // Create editing helper if not already.
        if (!self.editingHelper) {
            self.editingHelper = [[CKEditingViewHelper alloc] init];
        }
        
    } else {
        
        [self.editButton removeFromSuperview];
        self.editButton = nil;
        self.editingHelper = nil;
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

- (CGRect)contentFrameForLayout {
    CGRect frame = CGRectZero;
    DLog(@"Layout: %d", self.bookCoverLayout);
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
            frame = CGRectMake(13.0, -3.0, 280.0, 210.0);
            break;
        case BookCoverLayoutBottom:
            frame = CGRectMake(13.0, 242.0, 280.0, 170.0);
            break;
        default:
            break;
    }
    return frame;
}

@end
