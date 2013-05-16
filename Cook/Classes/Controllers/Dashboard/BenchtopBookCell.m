//
//  CKDashboardBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopBookCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewHelper.h"
#import "EventHelper.h"

@interface BenchtopBookCell () <CKBookCoverViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation BenchtopBookCell

+ (CGSize)cellSize {
    return CGSizeMake(300.0, 438.0);
}

+ (CGFloat)storeScale {
    return 0.5;
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        CKBookCoverView *bookView = [[CKBookCoverView alloc] initWithFrame:frame delegate:self];
        bookView.center = self.contentView.center;
        bookView.frame = CGRectIntegral(bookView.frame);
        [self.contentView addSubview:bookView];
        self.bookCoverView = bookView;
        
        // Start spinning until book is available
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = self.contentView.center;
        activityView.frame = CGRectIntegral(activityView.frame);
        [activityView startAnimating];
        [self.contentView addSubview:activityView];
        self.activityView = activityView;
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    DLog();
}

- (void)setSelected:(BOOL)selected {
    DLog();
}

#pragma mark - BenchtopBookCell methods

- (void)enableEditMode:(BOOL)editMode {
    [self.bookCoverView enableEditMode:editMode];
}

- (BOOL)enabled {
    return (self.book != nil);
}

- (void)loadBook:(CKBook *)book {
    [self loadBook:book mine:NO];
}

- (void)loadBook:(CKBook *)book mine:(BOOL)mine {
    
    // Do nothing if the same book has already been loaded.
    if (self.book == book) {
        return;
    }
    [self loadBook:book mine:mine force:NO];
}

- (void)loadBook:(CKBook *)book mine:(BOOL)mine force:(BOOL)force {
    
    self.book = book;
    
    // Stop spinning.
    [self.activityView stopAnimating];
    
    // Update cover.
    [self.bookCoverView setCover:book.cover illustration:book.illustration];
    
    // Featured books is completely illustration-based only.
    if (!self.book.featured) {
        [self.bookCoverView setTitle:book.name author:[book userName] editable:mine];
    }
    
}

- (void)openBook:(BOOL)open {
    // [self.bookView open:open];
}

- (void)openBook:(BOOL)open completion:(void (^)(BOOL opened))completion {    
}

- (void)loadAsPlaceholder {
    [self.activityView stopAnimating];
}

#pragma mark - BookViewDelegate methods

- (void)bookViewWillOpen:(BOOL)open {
}

- (void)bookViewDidOpen:(BOOL)open {
}

#pragma mark - CKBookCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
    DLog();
    [self.bookCoverView enableEditMode:YES];
    [self.delegate benchtopBookCellEditRequestedForIndexPath:self.indexPath];
}

#pragma mark - Private methods


@end
