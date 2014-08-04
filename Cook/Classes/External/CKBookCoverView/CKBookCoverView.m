//
//  CKBookCoverView.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKBookCoverView.h"
#import "CKBookCover.h"
#import "CKBook.h"
#import "Theme.h"
#import "CKTextFieldEditViewController.h"
#import "CKEditingViewHelper.h"
#import "NSString+Utilities.h"
#import "ViewHelper.h"
#import "ImageHelper.h"
#import "CKPhotoManager.h"
#import "EventHelper.h"
#import "CKActivityIndicatorView.h"
#import "DataHelper.h"

@interface CKBookCoverView () <CKEditingTextBoxViewDelegate, CKEditViewControllerDelegate>

@property (nonatomic, weak) id<CKBookCoverViewDelegate> delegate;
@property (nonatomic, assign) BookCoverLayout bookCoverLayout;
@property (nonatomic, strong) UIView *contentOverlay;
@property (nonatomic, strong) UITextView *nameTextView;
@property (nonatomic, strong) UITextView *authorTextView;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL standaloneMode;
@property (nonatomic, strong) UIImageView *updatesIcon;
@property (nonatomic, strong) UILabel *updatesLabel;

@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKEditViewController *editViewController;

@end

@implementation CKBookCoverView

#define kOverlayDebug   0
#define kShadowColour   [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]
#define kDisabledAlpha  1.0

- (void)dealloc {
    if (!self.standaloneMode) {
        [EventHelper unregisterPhotoLoading:self];
    }
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id<CKBookCoverViewDelegate>)delegate {
    return [self initWithStandaloneMode:NO delegate:delegate];
}

- (id)initWithStandaloneMode:(BOOL)standaloneMode delegate:(id<CKBookCoverViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.standaloneMode = standaloneMode;

        CGSize coverSize = [CKBookCover coverImageSize];
        self.frame = (CGRect){ 0.0, 0.0, coverSize.width, coverSize.height };
        
        // Cover
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:nil];
        backgroundImageView.frame = self.bounds;
        [self addSubview:backgroundImageView];
        self.backgroundImageView = backgroundImageView;
        
        // Illustration.
        UIImageView *illustrationImageView = [[UIImageView alloc] initWithImage:nil];
        illustrationImageView.frame = self.bounds;
        [self addSubview:illustrationImageView];
        self.illustrationImageView = illustrationImageView;
        
        // Register photo loading events only for non-store mode, as store will handle remote covers loading in order
        // to do resizing.
        if (!self.standaloneMode) {
            [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
        }
    }
    return self;
}

- (void)enable:(BOOL)enable {
    [self enable:enable animated:YES];
}

- (void)enable:(BOOL)enable animated:(BOOL)animated {
    if (animated) {
        if (enable) {
            self.editButton.alpha = 0.0;
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.editButton.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        } else {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.editButton.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
    } else {
        self.editButton.alpha = enable ? 1.0 : 0.0;
    }
}

- (void)loadBook:(CKBook *)book {
    [self loadBook:book editable:[book editable]];
}

- (void)loadBook:(CKBook *)book update:(NSInteger)updates {
    [self loadBook:book editable:[book editable] loadRemoteIllustration:YES updates:updates];
}

- (void)loadNewBook:(CKBook *)book {
    [self loadBook:book editable:[book editable] loadRemoteIllustration:YES updates:0];
    [self markNew];
}

- (void)loadBook:(CKBook *)book editable:(BOOL)editable {
    [self loadBook:book editable:editable loadRemoteIllustration:YES];
}

- (void)loadBook:(CKBook *)book editable:(BOOL)editable loadRemoteIllustration:(BOOL)loadRemoteIllustrations {
    [self loadBook:book editable:editable loadRemoteIllustration:loadRemoteIllustrations updates:0];
}

- (void)loadBook:(CKBook *)book editable:(BOOL)editable loadRemoteIllustration:(BOOL)loadRemoteIllustration
         updates:(NSInteger)updates {
    
    self.book = book;
    
    if ([self.book hasRemoteImage]) {
        
        // Load a blank illustration.
        [self setCover:book.cover illustration:[CKBookCover blankFeaturedIllustrationImageName]];
        
        if (loadRemoteIllustration) {
            
            // Load a illustration.
            [self setCover:book.cover illustration:nil];
            
            // Load the image remotely.
            [[CKPhotoManager sharedInstance] imageForUrl:[self.book remoteImageUrl]
                                                    size:self.illustrationImageView.bounds.size];
            
        }
        
    } else {
        [self setCover:book.cover illustration:book.illustration];
    }
    
    [self setName:book.name author:[book userName] editable:editable];    
    [self loadUpdates:updates];
}

- (void)loadRemoteIllustrationImage:(UIImage *)illustrationImage {
    self.illustrationImageView.image = illustrationImage;
}

- (void)setCover:(NSString *)cover illustration:(NSString *)illustration {
    [self setLayout:[CKBookCover layoutForIllustration:illustration guest:self.book.guest]];
    if (illustration) {
        self.illustrationImageView.image = [CKBookCover imageForIllustration:illustration];
    }
    self.backgroundImageView.image = [CKBookCover imageForCover:cover];
}

- (void)setName:(NSString *)name author:(NSString *)author editable:(BOOL)editable {
    // DLog(@"Book[%@] Author[%@] Layout[%d]", name, author, self.bookCoverLayout);
    // DLog(@"Book[%@] Author[%@] EditMode[%@]", name, author, self.editMode ? @"YES" : @"NO");
    
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
        case BookCoverLayoutBottom:
        case BookCoverLayoutMid:
        default:
            [self setName:[name uppercaseString]];
            [self setAuthor:[author uppercaseString]];
            break;
    }
    
    // Make sure refreshes of the book retains its current edit state.
    if (!self.editMode) {
        [self enableEditable:editable];
    }
    
}

- (void)enableEditMode:(BOOL)enable animated:(BOOL)animated {
    self.editMode = enable;
    self.editButton.hidden = enable;
    if (!enable) {
        [self.editButton setBackgroundImage:[CKBookCover editButtonUnderlayImageForCover:self.book.cover]
                                   forState:UIControlStateNormal];
        [self.editButton setBackgroundImage:[CKBookCover editButtonUnderlayOnPressImageForCover:self.book.cover]
                                   forState:UIControlStateHighlighted];
    }
    
    if (enable) {
        
        // Only allow editing if caption is not localised.
        if (![self.book captionLocalised]) {
            [self.editingHelper wrapEditingView:self.nameTextView
                                  contentInsets:UIEdgeInsetsMake(15.0, 20.0, 12.0, 40.0)
                                       delegate:self white:NO animated:animated];
        }
        
        // Only allow editing if title is not localised.
        if (![self.book titleLocalised]) {
            [self.editingHelper wrapEditingView:self.authorTextView
                                  contentInsets:UIEdgeInsetsMake(5.0, 20.0, 5.0, 28.0)
                                       delegate:self white:NO animated:animated];
        }
        
    } else {
        [self.editingHelper unwrapEditingView:self.nameTextView];
        [self.editingHelper unwrapEditingView:self.authorTextView];
    }
}

- (void)clearUpdates {
    [self.updatesIcon removeFromSuperview];
}

- (void)markNew {
    
    self.updatesIcon.image = [CKBookCover updatesIconImageForCover:self.book.cover];
    
    if (!self.updatesIcon.superview) {
        [self addSubview:self.updatesIcon];
    }
    if (!self.updatesLabel.superview) {
        self.updatesLabel.center = self.updatesIcon.center;
        [self.updatesIcon addSubview:self.updatesLabel];
    }
    
    self.updatesLabel.text = NSLocalizedString(@"NEW", nil);
    self.updatesLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:18.0];
    
    // Required size.
    UIEdgeInsets labelInsets = (UIEdgeInsets){ 6.0, 13.0, 12.0, 13.0 };
    CGFloat maxWidth = self.updatesIcon.frame.size.width - labelInsets.left - labelInsets.right;
    [self.updatesLabel sizeToFit];
    
    // Three iterations of size changes.
    CGPoint adjustment = (CGPoint){ 0.0, -4.0 };
    if (self.updatesLabel.frame.size.width > maxWidth) {
        
        adjustment.x = 1.0;
        self.updatesLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:14.0];
        [self.updatesLabel sizeToFit];
        
        if (self.updatesLabel.frame.size.width > maxWidth) {
            self.updatesLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:11.0];
            adjustment.x = 1.0;
            [self.updatesLabel sizeToFit];
        }
        
    }
    
    self.updatesLabel.frame = (CGRect){
        floorf((self.updatesIcon.bounds.size.width - self.updatesLabel.frame.size.width) / 2.0) + adjustment.x,
        floorf((self.updatesIcon.bounds.size.width - self.updatesLabel.frame.size.height) / 2.0) + adjustment.y,
        self.updatesLabel.frame.size.width,
        self.updatesLabel.frame.size.height
    };
    
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    if (editingView == self.nameTextView) {
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:NO
                                                                                                              title:nil
                                                                                                     characterLimit:32];
        editViewController.forceUppercase = YES;
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:50.0];
        self.editViewController = editViewController;
    } else if (editingView == self.authorTextView) {
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:NO
                                                                                                              title:nil
                                                                                                     characterLimit:20];
        editViewController.forceUppercase = YES;
        editViewController.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:60.0];
        self.editViewController = editViewController;
    }
    [self.editViewController performEditing:YES];
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
    if ([self.delegate respondsToSelector:@selector(bookCoverViewEditWillAppear:)]) {
        [self.delegate bookCoverViewEditWillAppear:appear];
    }
}

- (void)editViewControllerDidAppear:(BOOL)appear {
    if ([self.delegate respondsToSelector:@selector(bookCoverViewEditDidAppear:)]) {
        [self.delegate bookCoverViewEditDidAppear:appear];
    }
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
    
    if (editingView == self.nameTextView) {
        
        // Get updated value and update label.
        NSString *text = (NSString *)value;
        if (![text isEqualToString:self.nameTextView.text]) {
            [self setName:text];
            
            // Update the editing wrapper.
            [self.editingHelper updateEditingView:self.nameTextView animated:NO];
        }
        
    } else if (editingView == self.authorTextView) {
        
        // Get updated value and update label.
        NSString *text = (NSString *)value;
        if (![text isEqualToString:self.authorTextView.text]) {
            [self setAuthor:text];
            
            // Update the editing wrapper.
            [self.editingHelper updateEditingView:self.authorTextView animated:NO];
        }
        
    }
    
}

#pragma mark - Properties

- (UIView *)contentOverlay {
    if (!_contentOverlay) {
        _contentOverlay = [[UIView alloc] initWithFrame:CGRectZero];
        _contentOverlay.backgroundColor = kOverlayDebug ? [UIColor whiteColor] : [UIColor clearColor];;
        _contentOverlay.alpha = kOverlayDebug ? 0.3 : 1.0;
        [self addSubview:_contentOverlay];
    }
    return _contentOverlay;
}

- (UIImageView *)updatesIcon {
    if (!_updatesIcon) {
        _updatesIcon = [[UIImageView alloc] initWithImage:[CKBookCover updatesIconImageForCover:self.book.cover]];
        _updatesIcon.frame = (CGRect){
            self.bounds.size.width - _updatesIcon.frame.size.width + 26.0,
            self.bounds.origin.y - 32.0,
            _updatesIcon.frame.size.width,
            _updatesIcon.frame.size.height
        };
    }
    return _updatesIcon;
}

- (UILabel *)updatesLabel {
    if (!_updatesLabel) {
        _updatesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _updatesLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:28.0];
        _updatesLabel.backgroundColor = [UIColor clearColor];
        _updatesLabel.textColor = [UIColor whiteColor];
        _updatesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _updatesLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.05];
        _updatesLabel.textAlignment = NSTextAlignmentCenter;
        _updatesLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _updatesLabel;
}

#pragma mark - Private methods

- (void)setLayout:(BookCoverLayout)layout {
    self.bookCoverLayout = layout;
    self.contentOverlay.frame = [self contentFrameForLayout];
}

#pragma mark - Frames

- (CGRect)authorFrame {
    CGSize size = [self.authorTextView sizeThatFits:self.contentOverlay.bounds.size];
    CGRect frame = self.authorTextView.frame;
    frame.origin.x = floorf((self.authorTextView.superview.bounds.size.width - size.width) / 2.0);
    frame.size = size;
    CGRect nameFrame = self.nameTextView.frame;
    
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
            frame.origin.y = floorf((self.authorTextView.superview.bounds.size.height - size.height) / 2.0);
            break;
        case BookCoverLayoutBottom:
            frame.origin.y = floorf(((self.authorTextView.superview.bounds.size.height - (self.authorTextView.superview.bounds.size.height - nameFrame.origin.y)) - size.height) / 2.0);
            break;
        case BookCoverLayoutMid:
            frame.origin.y = floorf((self.authorTextView.superview.bounds.size.height - size.height) / 2.0);
            break;
        default:
            break;
    }
    
    return CGRectIntegral(frame);
}

- (CGRect)nameFrame {
    CGSize size = [self.nameTextView sizeThatFits:self.contentOverlay.bounds.size];
    CGRect frame = self.nameTextView.frame;
    frame.origin.x = floorf((self.nameTextView.superview.bounds.size.width - size.width) / 2.0);
    frame.size = size;

    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
            frame.origin.y = 0.0;
            break;
        case BookCoverLayoutBottom:
            frame.origin.y = self.nameTextView.superview.bounds.size.height - frame.size.height + 5.0;
            break;
        case BookCoverLayoutMid:
            frame.origin.y = 0.0;
            break;
        default:
            break;
    }
    return CGRectIntegral(frame);
}

#pragma mark - Text alignments

- (NSTextAlignment)titleTextAlignment {
    NSTextAlignment textAligntment = NSTextAlignmentCenter;
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
        case BookCoverLayoutBottom:
        case BookCoverLayoutMid:
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
        case BookCoverLayoutMid:
        default:
            textAligntment = NSTextAlignmentCenter;
            break;
    }
    return textAligntment;
}

#pragma mark - Elements

- (void)setName:(NSString *)title {
    self.nameValue = title;
    
    if (!self.nameTextView) {
        UITextView *nameTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        nameTextView.autoresizingMask = UIViewAutoresizingNone;
        nameTextView.backgroundColor = [UIColor clearColor];
        nameTextView.font = [self captionFont];
        nameTextView.textColor = [UIColor whiteColor];
        nameTextView.editable = NO;
        nameTextView.scrollEnabled = NO;
        nameTextView.userInteractionEnabled = NO;

        if (kOverlayDebug) {
            nameTextView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        [self.contentOverlay addSubview:nameTextView];
        self.nameTextView = nameTextView;
    }
    
    self.nameTextView.textAlignment = [self authorTextAlignment];
    self.nameTextView.text = title;
    self.nameTextView.frame = [self nameFrame];
    self.nameTextView.alpha = self.book.disabled ? kDisabledAlpha : 1.0;
    
    // Update editing wrapper if in edit mode.
    if (self.editMode) {
        [self.editingHelper updateEditingView:self.nameTextView];
    }
}

- (void)setAuthor:(NSString *)name {
    self.authorValue = name;
    
    if (!self.authorTextView) {
        UITextView *authorTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        authorTextView.autoresizingMask = UIViewAutoresizingNone;
        authorTextView.backgroundColor = [UIColor clearColor];
        authorTextView.editable = NO;
        authorTextView.scrollEnabled = NO;
        authorTextView.userInteractionEnabled = NO;
        if (kOverlayDebug) {
            authorTextView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        
        [self.contentOverlay addSubview:authorTextView];
        self.authorTextView = authorTextView;
    }
    
    UIFont *maxFont = [self authorFont];
    self.authorTextView.textAlignment = [self titleTextAlignment];
    self.authorTextView.alpha = self.book.disabled ? kDisabledAlpha : 1.0;
    
    // Paragraph style.
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = -20.0;
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
    self.authorTextView.attributedText = titleDisplay;
    
//    [self adjustsFontSizeForLabel:self.authorLabel attributes:attributes toFitSize:self.contentOverlay.bounds.size decrementFontSize:5.0];
    [self adjustsFontSizeForLabel:self.authorTextView text:name attributes:attributes
                        toFitSize:self.contentOverlay.bounds.size fontSizes:@[@58, @50, @46, @42, @40, @38]];
    
    self.authorTextView.frame = [self authorFrame];
    
    // Update editing wrapper if in edit mode.
    if (self.editMode) {
        [self.editingHelper updateEditingView:self.authorTextView];
    }

}

- (void)enableEditable:(BOOL)editable {
    self.editable = editable;
    if (editable) {
        if (!self.editButton) {
            UIButton *editButton = [ViewHelper buttonWithImage:[CKBookCover editButtonUnderlayImageForCover:self.book.cover]
                                                 selectedImage:[CKBookCover editButtonUnderlayOnPressImageForCover:self.book.cover]
                                                        target:self selector:@selector(editTapped:)];
            editButton.frame = CGRectMake(self.bounds.size.width - editButton.frame.size.width + 1.0,
                                          self.bounds.origin.y - 2.0,
                                          editButton.frame.size.width,
                                          editButton.frame.size.height);
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
    [self enableEditMode:NO animated:NO];
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
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
            frame = (CGRect){
                20.0,
                5.0,
                278.0,
                290.0
            };
            break;
        case BookCoverLayoutBottom:
            frame = (CGRect){
                20.0,
                242.0,
                278.0,
                187.0
            };
            break;
        case BookCoverLayoutMid:
            frame = (CGRect){
                20.0,
                7.0,
                278.0,
                408.0
            };
            break;
        default:
            break;
    }
    return frame;
}

- (void)adjustsFontSizeForLabel:(UITextView *)label text:(NSString *)text attributes:(NSDictionary *)attributes
                      toFitSize:(CGSize)size fontSizes:(NSArray *)fontSizes {
    
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    UIFont *font = [attributes objectForKey:NSFontAttributeName];
    
    // Find a font that fits the height of the box.
    NSNumber *selectedFontNumber = nil;
    for (NSNumber *fontNumber in fontSizes) {
        
        // Try the current font in the attributed string.
        CGFloat fontSize = [fontNumber floatValue];
        font = [font fontWithSize:fontSize];
        [mutableAttributes setObject:font forKey:NSFontAttributeName];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:mutableAttributes];
        label.attributedText = attributedText;
        
        // Check label height against available fitSize.
        // if it fits within the height, break now we have a candidate fontSize.
        CGSize labelSize = [label sizeThatFits:CGSizeMake(size.width, MAXFLOAT)];
        if (labelSize.height <= size.height) {
            selectedFontNumber = fontNumber;
            break;
        }
        
    }
    
    // DLog(@"Current Font [%@] after height eval: %@", text, selectedFontNumber);
    
    // Get the remaining font sizes.
    NSInteger selectedFontIndex = [fontSizes indexOfObject:selectedFontNumber];
    
    // Now find a font so that we don't have a single word that exceeds the width.
    NSArray *words = [text componentsSeparatedByString:@" "];
    for (NSString *word in words) {
        
        // Now look for a font that fits the word on a single line.
        for (NSInteger fontIndex = selectedFontIndex; fontIndex < [fontSizes count]; fontIndex++) {
            
            NSNumber *fontNumber = [fontSizes objectAtIndex:fontIndex];
            CGFloat fontSize = [fontNumber floatValue];
            font = [font fontWithSize:fontSize];
            
            // Try the current font in the attributed string.
            [mutableAttributes setObject:font forKey:NSFontAttributeName];
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:word attributes:mutableAttributes];
            label.attributedText = attributedText;
            
            // Check label height against available fitSize.
            // if it fits within the height, break now we have a candidate fontSize.
            CGSize labelSize = [label sizeThatFits:CGSizeMake(MAXFLOAT, size.height)];
            if (labelSize.width <= size.width) {
                selectedFontNumber = fontNumber;
                break;
            }
        }
        
        // DLog(@"Current Font [%@]: %@", word, selectedFontNumber);
    }
    
    // DLog(@"Current Font [%@] after word eval: %@", text, selectedFontNumber);
    
    // Use the current font.
    font = [font fontWithSize:[selectedFontNumber floatValue]];
    [mutableAttributes setObject:font forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:mutableAttributes];
    label.attributedText = attributedText;
}

- (void)adjustsFontSizeForLabel:(UILabel *)label attributes:(NSDictionary *)attributes toFitSize:(CGSize)size
              decrementFontSize:(CGFloat)decrementFontSize {
    
    NSString *text = label.attributedText.string;
    
    UIFont *currentFont = [attributes objectForKey:NSFontAttributeName];
    CGFloat currentPoint = currentFont.pointSize;
    
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    
    for (CGFloat points = currentPoint; points >= 10; points -= decrementFontSize) {
        currentFont = [currentFont fontWithSize:points];
        [mutableAttributes setObject:currentFont forKey:NSFontAttributeName];
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                             attributes:mutableAttributes];
        label.attributedText = attributedText;
        
        // Check label height.
        CGSize labelSize = [label sizeThatFits:size];
        if (labelSize.height <= size.height) {
            break;
        }
        
    }
    
    // Loop through words in string and resize to fit
    for (NSString *word in [text componentsSeparatedByString:@" "]) {
        
        for (CGFloat points = currentPoint; points >= 10; points -=decrementFontSize) {
            currentFont = [currentFont fontWithSize:points];
            [mutableAttributes setObject:currentFont forKey:NSFontAttributeName];
            
//            DLog(@"****** WORD [%@] FONT[%f]", word, currentPoint);
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:word
                                                                                 attributes:mutableAttributes];
            label.attributedText = attributedText;
            
            // Check label height.
            CGSize labelSize = [label sizeThatFits:CGSizeMake(MAXFLOAT, size.height)];
            if (labelSize.width <= size.width) {
//                DLog(@"****** WORD [%@] FONT[%f] WIDTH [%f] SIZE [%f]", word, currentPoint, labelSize.width, size.width);
                break;
            }
            
        }
        
//        float width = [word sizeWithFont:currentFont].width;
//        while (width > size.width && width > 0) {
//            currentPoint -= decrementFontSize;
//            currentFont = [currentFont fontWithSize:currentPoint];
//            width = [word sizeWithFont:currentFont].width;
//            DLog(@"****** WORD [%@] FONT[%f] WIDTH [%f] SIZE [%f]", word, currentPoint, width, size.width);
//        }
        
    }
    
    [mutableAttributes setObject:currentFont forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                         attributes:mutableAttributes];
    label.attributedText = attributedText;
}

- (UIFont *)authorFont {
    if (self.standaloneMode) {
        return [Theme bookCoverViewStoreModeNameMaxFont];
    } else {
        return [Theme bookCoverViewModeNameMaxFont];
    }
}

- (UIFont *)captionFont {
    return [Theme bookCoverViewModeTitleFont];
}

- (void)photoLoadingReceived:(NSNotification *)notification {
    
    if ([self.book hasRemoteImage]) {
        NSURL *url = [self.book remoteImageUrl];
        NSString *receivedPhotoName = [EventHelper nameForPhotoLoading:notification];
        NSString *photoName = [[url absoluteString] lowercaseString];
        
        if ([photoName isEqualToString:receivedPhotoName]) {
            
            if ([EventHelper hasImageForPhotoLoading:notification]) {
                UIImage *image = [EventHelper imageForPhotoLoading:notification];
                self.illustrationImageView.image = image;
            }
        }
    }
}

- (void)loadUpdates:(NSInteger)updates {
    if (updates > 0) {
        // Update with book colour.
        self.updatesIcon.image = [CKBookCover updatesIconImageForCover:self.book.cover];
        
        if (!self.updatesIcon.superview) {
            [self addSubview:self.updatesIcon];
        }
        if (!self.updatesLabel.superview) {
            self.updatesLabel.center = self.updatesIcon.center;
            [self.updatesIcon addSubview:self.updatesLabel];
        }
        self.updatesLabel.text = [DataHelper friendlyDisplayForCount:updates];
        self.updatesLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:28.0];
        [self.updatesLabel sizeToFit];
        self.updatesLabel.frame = (CGRect){
            floorf((self.updatesIcon.bounds.size.width - self.updatesLabel.frame.size.width) / 2.0),
            floorf((self.updatesIcon.bounds.size.height - self.updatesLabel.frame.size.height) / 2.0) - 3.0,
            self.updatesLabel.frame.size.width,
            self.updatesLabel.frame.size.height
        };
        
    } else {
        [self clearUpdates];
    }
}

@end
