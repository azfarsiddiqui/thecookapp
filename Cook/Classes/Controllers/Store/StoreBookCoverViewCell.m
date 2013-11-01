//
//  StoreBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreBookCoverViewCell.h"
#import "CKBookCoverView.h"
#import "ViewHelper.h"
#import "UIImage+ProportionalFill.h"
#import "BenchtopBookCoverViewCell.h"
#import "CKBookCover.h"

@interface StoreBookCoverViewCell ()

@property (nonatomic, strong) UIView *statusIconView;
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

- (void)loadBookCoverImage:(UIImage *)bookCoverImage status:(BookStatus)bookStatus {
    self.snapshotView.image = bookCoverImage;
    
    // Followed indicator.
    [self updateFollowedIcon:bookStatus];
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

- (void)updateFollowedIcon:(BookStatus)status {
    if (status == kBookStatusFollowed) {
        if (!self.statusIconView) {
            UIImageView *followedIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_btns_okay.png"]];
            followedIconView.frame = CGRectMake(self.contentView.bounds.size.width - 50.0,
                                                -20.0,
                                                followedIconView.frame.size.width,
                                                followedIconView.frame.size.height);
            self.statusIconView = followedIconView;
        }
        [self.contentView addSubview:self.statusIconView];
    } else if (status == kBookStatusFBSuggested) {
        if (!self.statusIconView) {
            UIImageView *fbSuggestIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_icon_facebook.png"]];
            fbSuggestIconView.frame = CGRectMake(self.contentView.bounds.size.width - 50.0,
                                                -20.0,
                                                fbSuggestIconView.frame.size.width,
                                                fbSuggestIconView.frame.size.height);
            self.statusIconView = fbSuggestIconView;
        }
        [self.contentView addSubview:self.statusIconView];
    } else { //if (status == kBookStatusNone)
        [self.statusIconView removeFromSuperview];
    }
}

@end
