//
//  ContentsPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ContentsPageViewController.h"
#import "ContentsCollectionViewController.h"
#import "UIFont+Cook.h"

@interface ContentsPageViewController ()

@property (nonatomic, strong) ContentsCollectionViewController *contentsCollectionViewController;

@end

@implementation ContentsPageViewController

#pragma mark - PageViewController methods

#define kNameYOffset    150.0

- (void)loadData {
}

- (void)initPageView {
    [self initCollectionView];
    [self initTitleView];
}

#pragma mark - Private methods

- (void)initTitleView {
    
    CKBook *book = [self.delegate currentBook];
    NSString *title = book.name;
    UIFont *font = [UIFont bookTitleFontWithSize:50.0];
    CGSize size = [title sizeWithFont:font constrainedToSize:self.view.bounds.size lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat xOffset = self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width;
    CGFloat availableWidth = self.view.bounds.size.width - xOffset;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + floorf((availableWidth - size.width) / 2.0),
                                                                   kNameYOffset,
                                                                   size.width,
                                                                   size.height)];
    nameLabel.font = font;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.shadowColor = [UIColor whiteColor];
    nameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    nameLabel.text = title;
    [self.view addSubview:nameLabel];
    
}

- (void)initCollectionView {
    ContentsCollectionViewController *collectionViewController  = [[ContentsCollectionViewController alloc] init];
    collectionViewController.view.frame = CGRectMake(78.0,
                                                     0.0,
                                                     collectionViewController.view.frame.size.width,
                                                     self.view.bounds.size.height);
    [self.view addSubview:collectionViewController.view];
    self.contentsCollectionViewController = collectionViewController;
}

@end
