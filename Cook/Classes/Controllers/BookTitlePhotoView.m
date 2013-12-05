//
//  BookTitlePhotoView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 29/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitlePhotoView.h"
#import "BookTitleView.h"
#import "CKBook.h"
#import "CKUser.h"
#import "CKUserProfilePhotoView.h"

@interface BookTitlePhotoView () <CKUserProfilePhotoViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, weak) id<BooKTitlePhotoViewDelegate> delegate;
@property (nonatomic, strong) BookTitleView *bookTitleView;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;

@end

@implementation BookTitlePhotoView

- (id)initWithBook:(CKBook *)book delegate:(id<BooKTitlePhotoViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.book = book;
        self.delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
        
        // Profile photo view.
        self.profilePhotoView.frame = (CGRect){
            floorf((self.bookTitleView.frame.size.width - self.profilePhotoView.frame.size.width) / 2.0),
            self.bounds.origin.y,
            self.profilePhotoView.frame.size.width,
            self.profilePhotoView.frame.size.height
        };
        [self addSubview:self.profilePhotoView];
        
        // Profile photo frame.
        UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_title_profile_overlay.png"]];
        frameImageView.frame = (CGRect){
            floorf((self.profilePhotoView.bounds.size.width - frameImageView.frame.size.width) / 2.0),
            -5.0,
            frameImageView.frame.size.width,
            frameImageView.frame.size.height
        };
        [self.profilePhotoView addSubview:frameImageView];
        
        // Title banner.
        self.bookTitleView.frame = (CGRect){
            self.bounds.origin.x,
            self.profilePhotoView.frame.origin.y + 55.0,
            self.bookTitleView.frame.size.width,
            self.bookTitleView.frame.size.height
        };
        [self insertSubview:self.bookTitleView belowSubview:self.profilePhotoView];
        
        self.frame = CGRectIntegral(CGRectUnion(self.profilePhotoView.frame, self.bookTitleView.frame));
    }
    return self;
}

#pragma mark - CKUserProfilePhotoViewDelegate methods

- (void)userProfilePhotoViewTappedForUser:(CKUser *)user {
    [self.delegate bookTitlePhotoViewProfileTapped];
}

#pragma mark - Properties

- (CKUserProfilePhotoView *)profilePhotoView {
    if (!_profilePhotoView) {
        _profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.book.user profileSize:ProfileViewSizeLarge];
        _profilePhotoView.delegate = self;
        _profilePhotoView.highlightOnTap = NO;
    }
    return _profilePhotoView;
}

- (BookTitleView *)bookTitleView {
    if (!_bookTitleView) {
        _bookTitleView = [[BookTitleView alloc] initWithTitle:self.book.author subtitle:self.book.name];;
    }
    return _bookTitleView;
}

@end
