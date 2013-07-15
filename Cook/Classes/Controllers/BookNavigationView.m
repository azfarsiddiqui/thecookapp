//
//  BookNavigationView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationView.h"
#import "ViewHelper.h"

@interface BookNavigationView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
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
        [self addSubview:self.titleLabel];
        [self addSubview:self.addButton];
    }
    return self;
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

- (void)addTapped:(id)sender {
    DLog();
}

@end
