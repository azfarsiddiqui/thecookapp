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
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title editable:(BOOL)editable book:(CKBook *)book {
    self.editable = editable;
    self.book = book;
    
    [self addSubview:self.homeButton];
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
    self.titleLabel.text = [title uppercaseString];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = (CGRect){
        floorf((self.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
        28.0,
        self.titleLabel.frame.size.width,
        self.titleLabel.frame.size.height
    };
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
        _titleLabel.textColor = [Theme navigationTitleColour];
    }
    return _titleLabel;
}

- (UIButton *)homeButton {
    if (!_homeButton) {
        UIEdgeInsets insets = [self contentInsetsForDark:NO];
        _homeButton = [ViewHelper buttonWithImage:[CKBookCover backImageForCover:self.book.cover selected:NO]
                                    selectedImage:[CKBookCover backImageForCover:self.book.cover selected:YES]
                                           target:self selector:@selector(homeTapped:)];
        _homeButton.frame = (CGRect){
            insets.left,
            insets.top,
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
        _editButton = [ViewHelper buttonWithImage:[CKBookCover editImageForCover:self.book.cover selected:NO]
                                    selectedImage:[CKBookCover editImageForCover:self.book.cover selected:YES]
                                           target:self selector:@selector(editTapped:)];
        _editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        _editButton.frame = CGRectMake(self.addButton.frame.origin.x - 11.0 - _editButton.frame.size.width,
                                       kContentInsets.top,
                                       _editButton.frame.size.width,
                                       _editButton.frame.size.height);
    }
    return _editButton;
}


#pragma mark - Private methods

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

- (UIEdgeInsets)contentInsetsForDark:(BOOL)dark {
    if (dark) {
        return kDarkContentInsets;
    } else {
        return kContentInsets;
    }
}

@end
