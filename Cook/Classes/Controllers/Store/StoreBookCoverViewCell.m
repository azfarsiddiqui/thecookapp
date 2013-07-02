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

@interface StoreBookCoverViewCell ()

@property (nonatomic, strong) UIView *followedIconView;
@property (nonatomic, strong) UIImageView *snapshotView;

@end

@implementation StoreBookCoverViewCell

+ (CGSize)cellSize {
//    return [BenchtopBookCoverViewCell cellSize];
    return CGSizeMake(128.0, 180.0);
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.bookCoverView removeFromSuperview];
        
        UIImageView *snapshotView = [[UIImageView alloc] initWithImage:nil];
        snapshotView.frame = self.contentView.bounds;
        [self.contentView addSubview:snapshotView];
        self.snapshotView = snapshotView;
    }
    return self;
}


- (CKBookCoverView *)createBookCoverViewWithDelegate:(id<CKBookCoverViewDelegate>)delegate {
    CGSize fullSize = [BenchtopBookCoverViewCell cellSize];
    return [[CKBookCoverView alloc] initWithFrame:(CGRect){ 0.0, 0.0, fullSize.width, fullSize.height } storeMode:YES delegate:delegate];
}

- (void)loadBook:(CKBook *)book {
    [self.bookCoverView setCover:book.cover illustration:book.illustration];
    [self.bookCoverView setName:nil author:[book userName] editable:NO];
    
    UIImage *snapshotImage = [ViewHelper imageWithView:self.bookCoverView opaque:NO];

//    UIGraphicsBeginImageContextWithOptions(self.bookCoverView.bounds.size, NO, 0);
//    BOOL snapshotCompleted = [self.bookCoverView drawViewHierarchyInRect:self.bookCoverView.bounds];
//    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

//    self.snapshotView = [[UIImageView alloc] initWithImage:snapshotImage];
//    self.snapshotView.frame = self.contentView.bounds;
//    [self.contentView addSubview:self.snapshotView];
    
    self.snapshotView.image = snapshotImage;
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
