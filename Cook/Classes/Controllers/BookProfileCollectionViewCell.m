//
//  BookProfileCollectionViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookProfileCollectionViewCell.h"
#import "CKBook.h"
#import "BookProfileViewController.h"

@interface BookProfileCollectionViewCell ()

@property (nonatomic, strong) BookProfileViewController *profileViewController;
@property (nonatomic, strong) CKBook *book;

@end

@implementation BookProfileCollectionViewCell

- (void)configureBook:(CKBook *)book {
    
    // Don't update if we've already configured it with a book - to prevent refresh of data.
    if (self.book) {
        return;
    }
    
    self.book = book;
    
    BookProfileViewController *profileViewController = [[BookProfileViewController alloc] initWithBook:book];
    profileViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:profileViewController.view];
    self.profileViewController = profileViewController;
}

@end
