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

@interface BookNavigationView ()

@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *homeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *editButton;

@end

@implementation BookNavigationView

#define kContentInsets      (UIEdgeInsets){ 20.0, 20.0, 0.0, 20.0 }
#define kDarkContentInsets  (UIEdgeInsets){ 30.0, 20.0, 0.0, 0.0 }
#define kButtonInsets       (UIEdgeInsets){ 28.0, 0.0, 0.0, 0.0 }
#define kButtonGap          5.0

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

- (void)setTitle:(NSString *)title editable:(BOOL)editable {
    self.editable = editable;
    self.titleLabel.textColor = [self.delegate bookNavigationColour];
    self.titleLabel.text = [title uppercaseString];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = (CGRect){
        floorf((self.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
        kButtonInsets.top,
        self.titleLabel.frame.size.width,
        self.titleLabel.frame.size.height
    };
    
    if (editable) {
        [self addSubview:self.addButton];
        [self addSubview:self.editButton];
    }
}

- (void)setDark:(BOOL)dark {
    self.backgroundImageView.image = [self backgroundImageForDark:dark];
    [ViewHelper updateButton:self.homeButton withImage:[self homeImageForDark:dark]];
    [ViewHelper updateButton:self.closeButton withImage:[self closeImageForDark:dark]];
    
    // Update button insets.
    CGRect homeButtonFrame = self.homeButton.frame;
    CGRect closeButtonFrame = self.closeButton.frame;
    homeButtonFrame.origin.y = [self contentInsetsForDark:dark].top;
    closeButtonFrame.origin.y = homeButtonFrame.origin.y;
    self.homeButton.frame = homeButtonFrame;
    self.closeButton.frame = closeButtonFrame;
}

- (void)setHomeAlpha:(CGFloat)homeAlpha {
    self.homeButton.alpha = homeAlpha;
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
                                          target:self selector:@selector(closeTapped:)];
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
                                          target:self selector:@selector(homeTapped:)];
        _homeButton.frame = (CGRect){
            self.closeButton.frame.origin.x + self.closeButton.frame.size.width + kButtonGap,
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
        _addButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_add.png"]
                                   selectedImage:[UIImage imageNamed:@"cook_book_inner_icon_add_onpress.png"]
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
                                           target:self
                                         selector:@selector(editTapped:)];
        _editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _editButton.frame = CGRectMake(self.addButton.frame.origin.x - kButtonGap - _editButton.frame.size.width,
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

- (UIImage *)homeImageForDark:(BOOL)dark {
    if (dark) {
        return [UIImage imageNamed:@"cook_book_inner_icon_home_light.png"];
    } else {
        return [UIImage imageNamed:@"cook_book_inner_icon_home_dark.png"];
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
