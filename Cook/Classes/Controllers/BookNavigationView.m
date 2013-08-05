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

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *homeButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BookNavigationView

#define kContentInsets  (UIEdgeInsets){ 20.0, 20.0, 0.0, 0.0 }

+ (CGFloat)navigationHeight {
    return 74.0;
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
    self.titleLabel.textColor = [self.delegate bookNavigationColour];
    self.titleLabel.text = [title uppercaseString];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = (CGRect){
        floorf((self.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
        floorf((self.bounds.size.height - self.titleLabel.frame.size.height) / 2.0) + 5.0,
        self.titleLabel.frame.size.width,
        self.titleLabel.frame.size.height
    };
    
    if (editable) {
        [self addSubview:self.addButton];
    }
}

#pragma mark - Properties

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_titlebar.png"]];
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
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_close_dark.png"]
                                          target:self selector:@selector(closeTapped:)];
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            kContentInsets.top,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _closeButton;
}

- (UIButton *)homeButton {
    if (!_homeButton) {
        _homeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_home_dark.png"]
                                          target:self selector:@selector(homeTapped:)];
        _homeButton.frame = (CGRect){
            self.closeButton.frame.origin.x + self.closeButton.frame.size.width + 5.0,
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

@end
