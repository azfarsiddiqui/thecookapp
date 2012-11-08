//
//  PageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "PageViewController.h"
#import "APBookmarkNavigationView.h"
#import "ViewHelper.h"

@interface PageViewController () <APBookmarkNavigationViewDelegate>

@property (nonatomic, assign) id<BookViewDelegate> delegate;

@end

@implementation PageViewController

- (id)initWithBookViewDelegate:(id<BookViewDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [self.delegate bookViewBounds];
    
    [self initPageView];
    [self initMenu];
    [self initBookmark];
}

- (void)initPageView {
    // Subclasses to implement.
}

- (void)loadData {
    // Subclasses to implement.
}

#pragma mark - APBookmarkNavigationViewDelegate methods

- (UIView *)bookmarkIconView {
    // return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_icons_customise.png"]];
    return nil;
}

- (NSUInteger)bookmarkNumberOfOptions {
    return 4;
}

- (UIView *)bookmarkOptionViewAtIndex:(NSUInteger)optionIndex {
    UIView *optionView = nil;
    switch (optionIndex) {
        case 0:
            optionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_icon_add.png"]];
            break;
        case 1:
            optionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_icon_facebook.png"]];
            break;
        case 2:
            optionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_icon_twitter.png"]];
            break;
        case 3:
            optionView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_icon_email.png"]];
            break;
        default:
            break;
    }
    return optionView;
}

- (NSString *)bookmarkOptionLabelAtIndex:(NSUInteger)optionIndex {
    NSString *optionLabel = nil;
    switch (optionIndex) {
        case 0:
            optionLabel = @"ADD";
            break;
        case 1:
            optionLabel = @"FACEBOOK";
            break;
        case 2:
            optionLabel = @"TWITTER";
            break;
        case 3:
            optionLabel = @"EMAIL";
            break;
        default:
            break;
    }
    return optionLabel;
}

- (void)bookmarkDidSelectOptionAtIndex:(NSUInteger)optionIndex {
    DLog();
}

#pragma mark - Private methods

- (void)initMenu {
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_cancel.png"]
                                                 target:self
                                               selector:@selector(closeTapped:)];
    closeButton.frame = CGRectMake(20.0,
                                   15.0,
                                   closeButton.frame.size.width,
                                   closeButton.frame.size.height);
    [self.view addSubview:closeButton];
}

- (void)initBookmark {
    UIEdgeInsets edgeInsets = [self.delegate bookViewInsets];
    APBookmarkNavigationView *bookmarkView = [[APBookmarkNavigationView alloc] initWithDelegate:self];
    bookmarkView.frame = CGRectMake(self.view.bounds.size.width - edgeInsets.right - bookmarkView.frame.size.width,
                                    0.0,
                                    bookmarkView.frame.size.width,
                                    bookmarkView.frame.size.height);
    [self.view addSubview:bookmarkView];
    
}

- (void)closeTapped:(id)sender {
    [self.delegate bookViewCloseRequested];
}

@end
