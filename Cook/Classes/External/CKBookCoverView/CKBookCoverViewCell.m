//
//  CKBookCoverViewCell.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 27/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "CKBookCoverViewCell.h"

@interface CKBookCoverViewCell () <CKBookCoverViewDelegate>

@end

@implementation CKBookCoverViewCell

+ (CGSize)cellSize {
    return CGSizeMake(300.0, 438.0);
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        CKBookCoverView *bookView = [[CKBookCoverView alloc] initWithFrame:frame delegate:self];
        bookView.center = self.contentView.center;
        bookView.frame = CGRectIntegral(bookView.frame);
        [self.contentView addSubview:bookView];
        self.bookCoverView = bookView;
    }
    return self;
}

- (void)setCover:(NSString *)cover illustration:(NSString *)illustration author:(NSString *)author
           title:(NSString *)title caption:(NSString *)caption editable:(BOOL)editable {
    [self.bookCoverView setCover:cover illustration:illustration];
    [self.bookCoverView setTitle:title author:author caption:caption editable:editable];
}

- (void)enableEditMode:(BOOL)enable {
    self.editMode = enable;
    [self.bookCoverView enableEditMode:enable];
}

#pragma mark - CKBookCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
    DLog();
    [self.delegate bookCoverViewEditRequestedForIndexPath:self.indexPath];
}

@end
