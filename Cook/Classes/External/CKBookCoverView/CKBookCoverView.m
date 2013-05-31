//
//  CKBookCoverView.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKBookCoverView.h"
#import "CKBookCover.h"
#import "Theme.h"
#import "CKTextFieldEditViewController.h"
#import "CKEditingViewHelper.h"
#import "NSString+Utilities.h"

@interface CKBookCoverView () <CKEditingTextBoxViewDelegate, CKEditViewControllerDelegate>

@property (nonatomic, assign) id<CKBookCoverViewDelegate> delegate;
@property (nonatomic, assign) BookCoverLayout bookCoverLayout;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UIImageView *illustrationImageView;
@property (nonatomic, strong) UIView *contentOverlay;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL editMode;

@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, strong) CKEditViewController *editViewController;

@end

@implementation CKBookCoverView

#define kContentInsets  UIEdgeInsetsMake(0.0, 13.0, 28.0, 10.0)
#define kOverlayDebug   0
#define kShadowColour   [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initBackground];
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

- (void)setName:(NSString *)name author:(NSString *)author editable:(BOOL)editable {
    // DLog(@"Book[%@] Author[%@] Layout[%d]", name, author, self.bookCoverLayout);
    // DLog(@"Book[%@] Author[%@] EditMode[%@]", name, author, self.editMode ? @"YES" : @"NO");
    
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
        case BookCoverLayoutBottom:
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

- (void)enableEditMode:(BOOL)enable {
    // DLog(@"enableEditMode: %@", enable ? @"YES" : @"NO");
    
    self.editMode = enable;
    self.editButton.hidden = enable;
    
    if (enable) {
        [self.editingHelper wrapEditingView:self.nameLabel
                              contentInsets:UIEdgeInsetsMake(20.0, 30.0, 10.0, 38.0)
                                   delegate:self white:NO];
        [self.editingHelper wrapEditingView:self.authorLabel
                              contentInsets:UIEdgeInsetsMake(5.0, 30.0, -10.0, 28.0)
                                   delegate:self white:NO];
    } else {
        [self.editingHelper unwrapEditingView:self.nameLabel];
        [self.editingHelper unwrapEditingView:self.authorLabel];
    }
}

#pragma mark - CKEditingTextBoxViewDelegate methods

- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView {
    if (editingView == self.nameLabel) {
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:NO
                                                                                                              title:@"Title"
                                                                                                     characterLimit:32];
        editViewController.fontSize = 40.0;
        self.editViewController = editViewController;
    } else if (editingView == self.authorLabel) {
        CKTextFieldEditViewController *editViewController = [[CKTextFieldEditViewController alloc] initWithEditView:editingView
                                                                                                           delegate:self
                                                                                                      editingHelper:self.editingHelper
                                                                                                              white:NO
                                                                                                              title:@"Name"
                                                                                                     characterLimit:20];
        self.editViewController = editViewController;
    }
    [self.editViewController performEditing:YES];
}

#pragma mark - CKEditViewControllerDelegate methods

- (void)editViewControllerWillAppear:(BOOL)appear {
    // DLog(@"%@", appear ? @"YES" : @"NO");
}

- (void)editViewControllerDidAppear:(BOOL)appear {
    // DLog(@"%@", appear ? @"YES" : @"NO");
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
    
    if (editingView == self.nameLabel) {
        
        // Get updated value and update label.
        NSString *text = (NSString *)value;
        if (![text isEqualToString:self.nameLabel.text]) {
            [self setName:text];
            
            // Update the editing wrapper.
            [self.editingHelper updateEditingView:self.nameLabel animated:NO];
        }
        
    } else if (editingView == self.authorLabel) {
        
        // Get updated value and update label.
        NSString *text = (NSString *)value;
        if (![text isEqualToString:self.authorLabel.text]) {
            [self setAuthor:text];
            
            // Update the editing wrapper.
            [self.editingHelper updateEditingView:self.authorLabel animated:NO];
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

#pragma mark - Frames

- (CGRect)authorFrame {
    CGSize size = [self.authorLabel sizeThatFits:self.contentOverlay.bounds.size];
    CGRect frame = self.authorLabel.frame;
    frame.origin.x = floorf((self.authorLabel.superview.bounds.size.width - size.width) / 2.0);
    frame.size = size;
    CGRect nameFrame = self.nameLabel.frame;
    
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
            frame.origin.y = nameFrame.origin.y + nameFrame.size.height + floorf(((self.authorLabel.superview.bounds.size.height - nameFrame.origin.y - nameFrame.size.height)  - size.height) / 2.0);
            break;
        case BookCoverLayoutBottom:
            frame.origin.y = floorf(((self.authorLabel.superview.bounds.size.height - (self.authorLabel.superview.bounds.size.height - nameFrame.origin.y)) - size.height) / 2.0);
            break;
        default:
            break;
    }
    
    return frame;
}

- (CGRect)nameFrame {
    CGRect frame = self.nameLabel.frame;
    frame.origin.x = floorf((self.nameLabel.superview.bounds.size.width - self.nameLabel.frame.size.width) / 2.0);

    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
            frame.origin.y = 0.0;
            break;
        case BookCoverLayoutBottom:
            frame.origin.y = self.nameLabel.superview.bounds.size.height - frame.size.height;
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

- (void)setName:(NSString *)title {
    self.nameValue = title;
    
    if (!self.nameLabel) {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.autoresizingMask = UIViewAutoresizingNone;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [Theme bookCoverViewModeTitleFont];
        nameLabel.textColor = [UIColor whiteColor];
        if (kOverlayDebug) {
            nameLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        [self.contentOverlay addSubview:nameLabel];
        self.nameLabel = nameLabel;
    }
    
    self.nameLabel.textAlignment = [self authorTextAlignment];
    self.nameLabel.text = title;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = [self nameFrame];
    
    // Update editing wrapper if in edit mode.
    if (self.editMode) {
        [self.editingHelper updateEditingView:self.nameLabel];
    }
}

- (void)setAuthor:(NSString *)name {
    self.authorValue = name;
    
    if (!self.authorLabel) {
        UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        authorLabel.autoresizingMask = UIViewAutoresizingNone;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.numberOfLines = 0;
        if (kOverlayDebug) {
            authorLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }
        
        [self.contentOverlay addSubview:authorLabel];
        self.authorLabel = authorLabel;
    }
    
    UIFont *maxFont = [Theme bookCoverViewModeNameMaxFont];
    self.authorLabel.textAlignment = [self titleTextAlignment];
    
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
    self.authorLabel.attributedText = titleDisplay;
    
//    [self adjustsFontSizeForLabel:self.authorLabel attributes:attributes toFitSize:self.contentOverlay.bounds.size decrementFontSize:5.0];
    [self adjustsFontSizeForLabel:self.authorLabel text:name attributes:attributes
                        toFitSize:self.contentOverlay.bounds.size fontSizes:@[@56, @48, @44, @40]];
    
    self.authorLabel.frame = [self authorFrame];
    
    // Update editing wrapper if in edit mode.
    if (self.editMode) {
        [self.editingHelper updateEditingView:self.authorLabel];
    }

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
                                          -22.0,
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
    switch (self.bookCoverLayout) {
        case BookCoverLayoutTop:
            frame = CGRectMake(15.0, -3.0, 278.0, 210.0);
            break;
        case BookCoverLayoutBottom:
            frame = CGRectMake(15.0, 232.0, 278.0, 180.0);
            break;
        default:
            break;
    }
    return frame;
}

- (void)adjustsFontSizeForLabel:(UILabel *)label text:(NSString *)text attributes:(NSDictionary *)attributes
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

@end
