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

#define kContentsButtonTag 112233445566
@interface PageViewController () <APBookmarkNavigationViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *pageNumberLabel;
@property (nonatomic, assign) NavigationButtonStyle navigationButtonStyle;
@property (nonatomic, strong) NSArray *defaultOptionIcons;
@property (nonatomic, strong) NSArray *defaultOptionLabels;
@end

@implementation PageViewController

- (id)initWithBookViewDelegate:(id<BookViewDelegate>)delegate dataSource:(id<BookViewDataSource>)dataSource withButtonStyle:(NavigationButtonStyle)navigationButtonStyle {
    if (self = [super init]) {
        self.delegate = delegate;
        self.navigationButtonStyle = navigationButtonStyle;
        self.dataSource = dataSource;
        self.defaultOptionLabels = @[@"ADD",@"FACEBOOK",@"TWITTER",@"EMAIL"];
        self.defaultOptionIcons = @[@"cook_book_icon_add.png",@"cook_book_icon_facebook.png",@"cook_book_icon_twitter.png",@"cook_book_icon_email.png"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = [self.delegate bookViewBounds];
    [self initPageView];
    [self initMenu];
    [self initBookmark];
    [self initLoadingIndicator];
}

- (void)initPageView {
    // Subclasses to implement.
}

- (void)loadingIndicator:(BOOL)loading {
    if (loading) {
        [self.activityView startAnimating];
        self.activityView.hidden = NO;
    } else {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
    }
}

#pragma mark - APBookmarkNavigationViewDelegate methods

- (NSUInteger)bookmarkNumberOfOptions {
    return 4;
}

- (UIView *)bookmarkOptionViewAtIndex:(NSUInteger)optionIndex {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.defaultOptionIcons objectAtIndex:optionIndex]]];
}

- (NSString *)bookmarkOptionLabelAtIndex:(NSUInteger)optionIndex {
    return [self.defaultOptionLabels objectAtIndex:optionIndex];
}

- (void)bookmarkDidSelectOptionAtIndex:(NSUInteger)optionIndex {
    DLog();
}

#pragma mark - Private methods

- (void)initMenu {
    NSString *closeImageName = (self.navigationButtonStyle == NavigationButtonStyleGray) ? @"cook_book_icon_close_gray.png" : @"cook_book_icon_close_white.png";
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:closeImageName]
                                                 target:self
                                               selector:@selector(closeTapped:)];
    closeButton.frame = CGRectMake(20.0,
                                   15.0,
                                   closeButton.frame.size.width,
                                   closeButton.frame.size.height);
    [self.view addSubview:closeButton];
    
    
    NSString *contentsImageName = (self.navigationButtonStyle == NavigationButtonStyleGray) ? @"cook_book_icon_contents_gray.png" : @"cook_book_icon_contents_white.png";
    UIButton *contentsButton = [ViewHelper buttonWithImage:[UIImage imageNamed:contentsImageName]
                                                 target:self
                                               selector:@selector(contentTapped:)];
    contentsButton.frame = CGRectMake(60.0,
                                   15.0,
                                   contentsButton.frame.size.width,
                                   contentsButton.frame.size.height);
    contentsButton.tag = kContentsButtonTag;
    contentsButton.hidden = YES;
    [self.view addSubview:contentsButton];
    
    
}

- (void)showContentsButton
{
    UIView *contentsButton = [self.view viewWithTag:kContentsButtonTag];
    if (contentsButton) {
        contentsButton.hidden = NO;
    }
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

- (void)initLoadingIndicator {
    UIEdgeInsets edgeInsets = [self.delegate bookViewInsets];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(self.view.bounds.size.width - activityView.frame.size.width - edgeInsets.right,
                                    self.view.bounds.size.height - activityView.frame.size.height - edgeInsets.bottom,
                                    activityView.frame.size.width,
                                    activityView.frame.size.height);
    activityView.hidden = YES;
    [self.view addSubview:activityView];
    self.activityView = activityView;
}

-(void) hidePageNumber {
    [self loadingIndicator:YES];
    [self.pageNumberLabel removeFromSuperview];
    
}
- (void)showPageNumber {
    [self loadingIndicator:NO];
    
    UIEdgeInsets edgeInsets = [self.delegate bookViewInsets];
    UIFont *font = [UIFont systemFontOfSize:12.0];
    NSInteger pageNumber = [self.dataSource currentPageNumber];
    NSInteger numberOfPages = [self.dataSource numberOfPages];
    DLog(@"page %d of %d", pageNumber, numberOfPages)
    NSString *pageDisplay = [NSString stringWithFormat:@"Page %d of %d", pageNumber, numberOfPages];
    CGSize size = [pageDisplay sizeWithFont:font constrainedToSize:self.view.bounds.size lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - size.width - edgeInsets.right,
                                                                   self.view.bounds.size.height - size.height - edgeInsets.bottom,
                                                                   size.width,
                                                                   size.height)];
    pageLabel.backgroundColor = [UIColor clearColor];
    pageLabel.font = font;
    pageLabel.textColor = [UIColor blackColor];
    pageLabel.text = pageDisplay;
    [self.view addSubview:pageLabel];
    self.pageNumberLabel = pageLabel;
}

- (void)closeTapped:(id)sender {
    [self.delegate bookViewCloseRequested];
}

-(void)contentTapped:(id)sender {
    [self.delegate contentViewRequested];
}

@end
