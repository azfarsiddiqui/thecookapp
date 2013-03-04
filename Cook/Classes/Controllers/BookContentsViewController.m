//
//  BookContentsViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentsViewController.h"
#import <Parse/Parse.h>
#import "CKBook.h"
#import "Theme.h"
#import "ImageHelper.h"
#import "CKRecipe.h"
#import "ParsePhotoStore.h"
#import "AppHelper.h"

@interface BookContentsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) id<BookContentsViewControllerDelegate> delegate;
@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *heroImage;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *contentsView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) NSArray *categories;

@end

@implementation BookContentsViewController

#define kContentsWidth      180.0
#define kTitleSize          CGSizeMake(600.0, 300.0)
#define kProfileWidth       200.0
#define kBookTitleInsets    UIEdgeInsetsMake(30.0, 20.0, 20.0, 20.0)
#define kTitleNameGap       0.0
#define kContentsItemHeight 50.0

- (id)initWithBook:(CKBook *)book delegate:(id<BookContentsViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
        self.photoStore = [[ParsePhotoStore alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    // Placed here to get the correct orientation.
    [self initImageView];
    [self initTitleView];
    [self initContentsView];
}

- (void)configureCategories:(NSArray *)categories {
    self.categories = categories;
    
    // Update the frame of the tableView so that we can position it center.
    [self updateTableFrame];
    [self.tableView reloadData];
}

- (void)configureRecipe:(CKRecipe *)recipe {
    [self.photoStore imageForParseFile:[recipe imageFile]
                                  size:[self imageFrame].size
                            completion:^(UIImage *image) {
                                self.heroImage = image;
                                if (self.imageView) {
                                    [ImageHelper configureImageView:self.imageView image:self.heroImage];
                                }
                            }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = [self.categories count];
    if ([self.book isUserBookAuthor:[CKUser currentUser]]) {
        numRows += 1;   // Add Recipe
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContentsCellId";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [Theme bookContentsItemColour];
        cell.textLabel.font = [Theme bookContentsItemFont];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger numRows = [self tableView:tableView numberOfRowsInSection:0];
    if (indexPath.item == (numRows - 1)) {
        cell.textLabel.text = @"ADD RECIPE";
    } else {
        NSString *categoryName = [[self.categories objectAtIndex:indexPath.item] uppercaseString];
        cell.textLabel.text = categoryName;
    }
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kContentsItemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger numRows = [self tableView:tableView numberOfRowsInSection:0];
    if (indexPath.item == (numRows - 1)) {
        [self.delegate bookContentsAddRecipeRequested];
    } else {
        [self.delegate bookContentsSelectedCategory:[self.categories objectAtIndex:indexPath.item]];
    }
}

#pragma mark - Private methods

- (void)initImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = [self imageFrame];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    [ImageHelper configureImageView:self.imageView image:self.heroImage];
}

- (CGRect)imageFrame {
    CGRect fullScreenFrame = [[AppHelper sharedInstance] fullScreenFrame];
    return CGRectMake(fullScreenFrame.origin.x,
                      fullScreenFrame.origin.y,
                      fullScreenFrame.size.width - kContentsWidth,
                      fullScreenFrame.size.height);
}

- (void)initTitleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(floorf((self.imageView.bounds.size.width - kTitleSize.width) / 2.0),
                                                                 floorf((self.imageView.bounds.size.height - kTitleSize.height) / 2.0),
                                                                 kTitleSize.width,
                                                                 kTitleSize.height)];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    titleView.backgroundColor = [UIColor clearColor];
    [self.imageView addSubview:titleView];
    self.titleView = titleView;
    
    // Semi-transparent black overlay.
    UIView *titleOverlayView = [[UIView alloc] initWithFrame:titleView.bounds];
    titleOverlayView.backgroundColor = [UIColor blackColor];
    titleOverlayView.alpha = 0.8;
    [titleView addSubview:titleOverlayView];
    
    // Profile photo
    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(titleView.bounds.origin.x,
                                                                                  titleView.bounds.origin.y,
                                                                                  kProfileWidth,
                                                                                  titleView.bounds.size.height)];
    profileImageView.backgroundColor = [UIColor darkGrayColor];
    profileImageView.alpha = 0.8;
    [titleView addSubview:profileImageView];
    self.profileImageView = profileImageView;
    
    // Book title.
    NSString *bookTitle = [self.book.name uppercaseString];
    CGSize availableSize = CGSizeMake(titleView.bounds.size.width - profileImageView.frame.size.width - profileImageView.frame.origin.x - kBookTitleInsets.left - kBookTitleInsets.right, titleView.bounds.size.height - kBookTitleInsets.top - kBookTitleInsets.bottom);
    CGSize size = [bookTitle sizeWithFont:[Theme bookContentsTitleFont] constrainedToSize:availableSize
                            lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + kBookTitleInsets.left + floorf((availableSize.width - size.width) / 2.0),
                                                                    floorf((availableSize.height - size.height) / 2.0),
                                                                    size.width,
                                                                    size.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 2;
    titleLabel.font = [Theme bookContentsTitleFont];
    titleLabel.textColor = [Theme bookContentsTitleColour];
    titleLabel.text = bookTitle;
    [titleView addSubview:titleLabel];
    
    // Book author.
    NSString *bookAuthor = [[self.book userName] uppercaseString];
    CGSize authorSize = [bookAuthor sizeWithFont:[Theme bookContentsNameFont] constrainedToSize:availableSize
                                   lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + kBookTitleInsets.left + floorf((availableSize.width - authorSize.width) / 2.0),
                                                                    floorf((availableSize.height - authorSize.height) / 2.0),
                                                                    authorSize.width,
                                                                    authorSize.height)];
    authorLabel.backgroundColor = [UIColor clearColor];
    authorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    authorLabel.font = [Theme bookContentsNameFont];
    authorLabel.textColor = [Theme bookContentsNameColour];
    authorLabel.text = bookAuthor;
    [titleView addSubview:authorLabel];
    
    // Combined height of title and name, to use for centering.
    CGFloat combinedHeight = titleLabel.frame.size.height + kTitleNameGap + authorLabel.frame.size.height;
    CGRect titleFrame = titleLabel.frame;
    CGRect authorFrame = authorLabel.frame;
    titleFrame.origin.y = kBookTitleInsets.top + floorf((availableSize.height - combinedHeight) / 2.0);
    authorFrame.origin.y = titleLabel.frame.origin.y + titleLabel.frame.size.height + kTitleNameGap;
    titleLabel.frame = titleFrame;
    authorLabel.frame = authorFrame;
}

- (void)initContentsView {
    UIView *contentsView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - kContentsWidth,
                                                                    self.view.bounds.origin.y,
                                                                    kContentsWidth,
                                                                    self.view.bounds.size.height)];
    contentsView.backgroundColor = [Theme bookContentsViewColour];
    [self.view addSubview:contentsView];
    self.contentsView = contentsView;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [contentsView addSubview:tableView];
    self.tableView = tableView;
    [self updateTableFrame];
}

- (void)updateTableFrame {
    CGFloat tableHeight = [self tableView:self.tableView numberOfRowsInSection:0] * kContentsItemHeight;
    self.tableView.frame = CGRectMake(self.contentsView.bounds.origin.x,
                                      floorf((self.contentsView.bounds.size.height - tableHeight) / 2.0),
                                      self.contentsView.bounds.size.width,
                                      tableHeight);

}

@end
