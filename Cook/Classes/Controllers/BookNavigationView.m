//
//  BookNavigationView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationView.h"
#import "ViewHelper.h"
#import "Theme.h"
#import "CKBook.h"
#import "CKBookCover.h"

@interface BookNavigationView ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *homeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *editButton;

@end

@implementation BookNavigationView

#define kContentInsets      (UIEdgeInsets){ 20.0, 6.0, 0.0, 8.0 }
#define kDarkContentInsets  (UIEdgeInsets){ 20.0, 6.0, 0.0, 8.0 }

+ (CGFloat)navigationHeight {
    return 74.0;
}

+ (CGFloat)darkNavigationHeight {
    return 100.0;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.closeButton];
        [self addSubview:self.homeButton];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title editable:(BOOL)editable book:(CKBook *)book {
    self.editable = editable;
    self.book = book;
    [self updateTitle:title];
    
    if (editable) {
        [self addSubview:self.addButton];
        [self addSubview:self.editButton];
    }
}

- (void)updateTitle:(NSString *)title {
    
    // Ignore if the same title.
    if ([self.title isEqualToString:title]) {
        return;
    }
    self.title = title;
    
    self.titleLabel.textColor = [self.delegate bookNavigationColour];
    self.titleLabel.text = [title uppercaseString];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = (CGRect){
        floorf((self.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
        28.0,
        self.titleLabel.frame.size.width,
        self.titleLabel.frame.size.height
    };
}

- (void)setDark:(BOOL)dark {
    self.backgroundImageView.image = [self backgroundImageForDark:dark];
    [ViewHelper updateButton:self.homeButton withImage:[self homeImageForDark:dark] selectedImage:[self homeImageForDarkSelected:dark]];
    [ViewHelper updateButton:self.closeButton withImage:[self closeImageForDark:dark] selectedImage:[self closeImageForDarkSelected:dark]];
    
    // Update button insets.
    CGRect homeButtonFrame = self.homeButton.frame;
    CGRect closeButtonFrame = self.closeButton.frame;
    homeButtonFrame.origin.y = [self contentInsetsForDark:dark].top;
    closeButtonFrame.origin.y = homeButtonFrame.origin.y;
    self.homeButton.frame = homeButtonFrame;
    self.closeButton.frame = closeButtonFrame;
}

- (void)enableAddAndEdit:(BOOL)enable {
    self.editButton.alpha = enable ? 1.0 : 0.0;
    self.addButton.alpha = enable ? 1.0 : 0.0;
}

#pragma mark - Properties

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[self backgroundImageForDark:NO]];
        _backgroundImageView.frame = self.bounds;
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _backgroundImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [Theme navigationTitleFont];
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        UIEdgeInsets insets = [self contentInsetsForDark:NO];
        _closeButton = [ViewHelper buttonWithImage:[self closeImageForDark:NO]
                                     selectedImage:[self closeImageForDarkSelected:NO]
                                          target:self
                                          selector:@selector(closeTapped:)];
        _closeButton.frame = (CGRect){
            insets.left,
            insets.top,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _closeButton;
}

- (UIButton *)homeButton {
    if (!_homeButton) {
        _homeButton = [ViewHelper buttonWithImage:[self homeImageForDark:NO]
                                    selectedImage:[self homeImageForDarkSelected:NO]
                                           target:self
                                         selector:@selector(homeTapped:)];
        _homeButton.frame = (CGRect){
            self.closeButton.frame.origin.x + self.closeButton.frame.size.width + 2.0,
            self.closeButton.frame.origin.y,
            _homeButton.frame.size.width,
            _homeButton.frame.size.height
        };
        _homeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _homeButton;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [ViewHelper buttonWithImage:[CKBookCover addRecipeImageForCover:self.book.cover selected:NO]
                                   selectedImage:[CKBookCover addRecipeImageForCover:self.book.cover selected:YES]
                                          target:self selector:@selector(addTapped:)];
        _addButton.frame = (CGRect){
            self.bounds.size.width - _addButton.frame.size.width - kContentInsets.right,
            kContentInsets.top,
            _addButton.frame.size.width,
            _addButton.frame.size.height
        };
        _addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _addButton;
}

- (UIButton *)editButton {
    if (!_editButton && self.editable) {
        _editButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_edit_dark.png"]
                       selectedImage:[UIImage imageNamed:@"cook_book_inner_icon_edit_dark_onpress.png"]
                                           target:self
                                         selector:@selector(editTapped:)];
        _editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _editButton.frame = CGRectMake(self.addButton.frame.origin.x - 11.0 - _editButton.frame.size.width,
                                       kContentInsets.top,
                                       _editButton.frame.size.width,
                                       _editButton.frame.size.height);
    }
    return _editButton;
}


#pragma mark - Private methods

- (void)closeTapped:(id)sender {
    [self.delegate bookNavigationViewCloseTapped];
}

- (void)homeTapped:(id)sender {
    [self.delegate bookNavigationViewHomeTapped];
}

- (void)addTapped:(id)sender {
    [self.delegate bookNavigationViewAddTapped];
}

- (void)editTapped:(id)sender {
    [self.delegate bookNavigationViewEditTapped];
}

- (UIImage *)backgroundImageForDark:(BOOL)dark {
    if (dark) {
        return [UIImage imageNamed:@"cook_book_inner_titlebar_dark.png"];
    } else {
        return [UIImage imageNamed:@"cook_book_inner_titlebar.png"];
    }
}

- (UIImage *)closeImageForDark:(BOOL)dark {
    if (dark) {
        return [UIImage imageNamed:@"cook_book_inner_icon_close_light.png"];
    } else {
        return [UIImage imageNamed:@"cook_book_inner_icon_close_dark.png"];
    }
}

- (UIImage *)closeImageForDarkSelected:(BOOL)dark {
    if (dark) {
        return [UIImage imageNamed:@"cook_book_inner_icon_close_light_onpress.png"];
    } else {
        return [UIImage imageNamed:@"cook_book_inner_icon_close_dark_onpress.png"];
    }
}

- (UIImage *)homeImageForDark:(BOOL)dark {
    if (dark) {
        return [UIImage imageNamed:@"cook_book_inner_icon_home_light.png"];
    } else {
        return [UIImage imageNamed:@"cook_book_inner_icon_home_dark.png"];
    }
}

- (UIImage *)homeImageForDarkSelected:(BOOL)dark {
    if (dark) {
        return [UIImage imageNamed:@"cook_book_inner_icon_home_light_onpress.png"];
    } else {
        return [UIImage imageNamed:@"cook_book_inner_icon_home_dark_onpress.png"];
    }
}

- (UIEdgeInsets)contentInsetsForDark:(BOOL)dark {
    if (dark) {
        return kDarkContentInsets;
    } else {
        return kContentInsets;
    }
}

@end
