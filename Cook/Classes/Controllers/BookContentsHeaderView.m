//
//  ActivityHeaderViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentsHeaderView.h"
#import "CKBook.h"
#import "BookContentsViewController.h"

@interface BookContentsHeaderView ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) BookContentsViewController *contentsViewController;

@end

@implementation BookContentsHeaderView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)configureBook:(CKBook *)book {
    
    // Return if we've already configured with a book.
    if (self.book) {
        return;
    }
    self.book = book;
}

- (void)configureCategories:(NSArray *)categories {
    [self.contentsViewController configureCategories:categories];
}

- (BookContentsViewController *)contentsViewController {
    if (_contentsViewController == nil) {
        BookContentsViewController *contentsViewController = [[BookContentsViewController alloc] initWithBook:self.book];
        contentsViewController.view.frame = self.bounds;
        contentsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
        [self addSubview:contentsViewController.view];
        _contentsViewController = contentsViewController;
    }
    return _contentsViewController;
}

@end
