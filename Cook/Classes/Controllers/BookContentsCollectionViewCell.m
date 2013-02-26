//
//  BookHomeResusableView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentsCollectionViewCell.h"
#import "BookContentsViewController.h"
#import "CKBook.h"

@interface BookContentsCollectionViewCell ()

@property (nonatomic, strong) BookContentsViewController *homeViewController;
@property (nonatomic, strong) CKBook *book;

@end

@implementation BookContentsCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)configureBook:(CKBook *)book {
    
    // Don't update if we've already configured it with a book - to prevent refresh of data.
    if (self.book) {
        return;
    }
    
    self.book = book;
    BookContentsViewController *homeViewController = [[BookContentsViewController alloc] initWithBook:book];
    homeViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:homeViewController.view];
    self.homeViewController = homeViewController;
}

@end
