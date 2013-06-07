//
//  StoreBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreBookCoverViewCell.h"
#import "CKBookCoverView.h"
#import "CKBook.h"
#import "ViewHelper.h"

@interface StoreBookCoverViewCell ()

@property (nonatomic, strong) UIView *followedIconView;

@end

@implementation StoreBookCoverViewCell

+ (CGSize)cellSize {
    return [BenchtopBookCoverViewCell cellSize];
}

- (CKBookCoverView *)createBookCoverViewWithDelegate:(id<CKBookCoverViewDelegate>)delegate {
    return [[CKBookCoverView alloc] initWithFrame:self.contentView.bounds storeMode:YES delegate:delegate];
}

- (void)loadBook:(CKBook *)book {
    [self.bookCoverView setCover:book.cover illustration:book.illustration];
    [self.bookCoverView setName:book.name author:[book userName] editable:NO];
    [self enableDeleteMode:NO];
}

#pragma mark - Private methods

- (void)followTapped:(id)sender {
    if (self.delegate) {
        [self.delegate storeBookFollowTappedForCell:self];
    }
}

- (void)updateFollowedIcon:(BOOL)followed {
    if (followed) {
        if (!self.followedIconView) {
            UIImageView *followedIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_icon_added.png"]];
            followedIconView.frame = CGRectMake(-40.0,
                                                -40.0,
                                                followedIconView.frame.size.width,
                                                followedIconView.frame.size.height);
            self.followedIconView = followedIconView;
        }
        [self.contentView addSubview:self.followedIconView];
    } else {
        [self.followedIconView removeFromSuperview];
    }
}

@end
