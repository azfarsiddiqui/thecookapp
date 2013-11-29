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

@property (nonatomic, strong) UIImageView *statusIconView;
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
    [self updateBookStatus:bookStatus];
}

- (void)updateBookStatus:(BookStatus)bookStatus {
    
    // Followed/FB indicator.
    [self updateFollowedAndFacebookIcon:bookStatus];
    
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

- (void)updateFollowedAndFacebookIcon:(BookStatus)status {

    if (status == kBookStatusFollowed || status == kBookStatusFBSuggested) {
        UIImage *iconImage = (status == kBookStatusFollowed) ? [UIImage imageNamed:@"cook_btns_okay.png"] : [UIImage imageNamed:@"cook_library_icon_facebook.png"];
        
        if (!self.statusIconView) {
            self.statusIconView = [[UIImageView alloc] initWithFrame:(CGRect){
                self.contentView.bounds.size.width - 50.0,
                -20.0,
                iconImage.size.width,
                iconImage.size.height
            }];
        }
        
        self.statusIconView.image = iconImage;
        
        if (!self.statusIconView.superview) {
            [self.contentView addSubview:self.statusIconView];
        }
        
    } else {
        [self.statusIconView removeFromSuperview];
    }
    
}

@end
