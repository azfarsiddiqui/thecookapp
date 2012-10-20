//
//  CKDashboardBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBenchtopBookCell.h"
#import <QuartzCore/QuartzCore.h>
#import "BookCoverView.h"
#import "BookCoverViewFactory.h"

@interface CKBenchtopBookCell ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) BookCoverView *bookCoverView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *bookImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation CKBenchtopBookCell

#define kContentInsets          UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
#define kBookTitleFont          [UIFont boldSystemFontOfSize:40.0]
#define kBookTitleColour        [UIColor lightGrayColor]
#define kBookTitleShadowColour  [UIColor blackColor]

+ (CGSize)cellSize {
    return CGSizeMake(300.0, 438.0);
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        BookCoverView *bookCoverView = [[BookCoverView alloc] initWithFrame:frame];
        bookCoverView.center = self.contentView.center;
        bookCoverView.frame = CGRectIntegral(bookCoverView.frame);
        [self.contentView addSubview:bookCoverView];
        self.bookCoverView = bookCoverView;
        
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

- (BOOL)enabled {
    return (self.book != nil);
}

- (void)loadBook:(CKBook *)book {
    
    // Do nothing if the same book has already been loaded.
    if (self.book == book) {
        return;
    }
    
    self.book = book;
    
    // Stop spinning.
    [self.activityView stopAnimating];
    
    // Update book cover.
    [self.bookCoverView updateWithBook:book];
}

- (void)loadAsPlaceholder {
    [self.activityView stopAnimating];
}

#pragma mark - Private methods

- (CGSize)availableSize {
    return CGSizeMake(self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

- (void)setText:(NSString *)text {
    CGSize availableSize = [self availableSize];
    CGSize size = [text sizeWithFont:kBookTitleFont constrainedToSize:[self availableSize]
                       lineBreakMode:NSLineBreakByTruncatingTail];
    self.textLabel.hidden = NO;
    self.textLabel.frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                                      self.textLabel.frame.origin.y,
                                      size.width,
                                      size.height);
    self.textLabel.text = text;
}

@end
