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
#import "UIImage+ProportionalFill.h"
#import "BenchtopBookCoverViewCell.h"
#import "CKBookCover.h"

@interface StoreBookCoverViewCell ()

@property (nonatomic, strong) UIView *followedIconView;
@property (nonatomic, strong) UIImageView *snapshotView;

@end

@implementation StoreBookCoverViewCell

+ (CGSize)cellSize {
    return [BenchtopBookCoverViewCell storeCellSize];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.bookCoverView removeFromSuperview];
        
        // Snapshot view.
        UIImageView *snapshotView = [[UIImageView alloc] initWithImage:nil];
        snapshotView.autoresizingMask = UIViewAutoresizingNone;
        snapshotView.contentMode = UIViewContentModeCenter;
        snapshotView.frame = self.contentView.bounds;
        [self.contentView addSubview:snapshotView];
        self.snapshotView = snapshotView;
    }
    return self;
}

- (void)loadBookCoverImage:(UIImage *)bookCoverImage followed:(BOOL)followed {
    self.snapshotView.image = bookCoverImage;
    
    // Followed indicator.
    [self updateFollowedIcon:followed];
}

- (CKBookCoverView *)createBookCoverViewWithDelegate:(id<CKBookCoverViewDelegate>)delegate {
    return [[CKBookCoverView alloc] initWithStoreMode:YES delegate:delegate];
}

- (UIImage *)shadowImage {
    return [CKBookCover storeOverlayImage];
}

- (UIOffset)shadowOffset {
    return (UIOffset) { 0.0, 5.0 };
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
            UIImageView *followedIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_btns_okay.png"]];
            followedIconView.frame = CGRectMake(self.contentView.bounds.size.width - 50.0,
                                                -20.0,
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
