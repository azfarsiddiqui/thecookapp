//
//  BenchtopCell.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "BenchtopBookCoverViewCell.h"

@interface BenchtopBookCoverViewCell () <CKBookCoverViewDelegate>

@end

@implementation BenchtopBookCoverViewCell

+ (CGSize)cellSize {
    return CGSizeMake(300.0, 438.0);
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CKBookCoverView *bookView = [[CKBookCoverView alloc] initWithFrame:frame delegate:self];
        bookView.center = self.contentView.center;
        bookView.frame = CGRectIntegral(bookView.frame);
        [self.contentView addSubview:bookView];
        self.bookCoverView = bookView;
    }
    return self;
}

- (void)loadBook:(CKBook *)book {
    [self.bookCoverView setCover:book.cover illustration:book.illustration];
    [self.bookCoverView setTitle:book.name author:[book userName] caption:book.caption editable:[book editable]];
}

#pragma mark - CKBooKCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
    DLog();
}

@end
