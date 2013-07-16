//
//  BookSocialViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 16/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookSocialViewController.h"
#import "ViewHelper.h"

@interface BookSocialViewController ()

@property (nonatomic, weak) id<BookSocialViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *underlayView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation BookSocialViewController

#define kUnderlayMaxAlpha   0.7
#define kButtonInsets       UIEdgeInsetsMake(15.0, 20.0, 15.0, 20.0)

- (id)initWithDelegate:(id<BookSocialViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.underlayView];
    [self.view addSubview:self.closeButton];
}

#pragma mark - Properties

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_inner_icon_close_dark.png"]
                                            target:self
                                          selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kButtonInsets.left,
            kButtonInsets.top,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

- (UIView *)underlayView {
    if (!_underlayView) {
        _underlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _underlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _underlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:kUnderlayMaxAlpha];
    }
    return _underlayView;
}

#pragma mark - Private methods

- (void)loadData {
    
}

- (void)closeTapped:(id)sender {
    [self.delegate bookSocialViewControllerCloseRequested];
}

@end
