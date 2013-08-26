//
//  SignUpBookCoverViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "SignUpBookCoverViewCell.h"
#import "CKBook.h"
#import "CKSignInButtonView.h"
#import "CKFacebookSignInButtonView.h"

@interface SignUpBookCoverViewCell () <CKSignInButtonViewDelegate>

@property (nonatomic, strong) CKSignInButtonView *emailButton;
@property (nonatomic, strong) CKFacebookSignInButtonView *facebookButton;

@end

@implementation SignUpBookCoverViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.emailButton];
        [self.contentView addSubview:self.facebookButton];
    }
    return self;
}

- (void)loadBook:(CKBook *)book {
    self.bookCoverView.illustrationImageView.alpha = 0.5;
    [super loadBook:book];
}

#pragma mark - CKSignInButtonViewDelegate methods

- (void)signInTappedForButtonView:(CKSignInButtonView *)buttonView {
    if (buttonView == self.facebookButton) {
        if ([self.delegate respondsToSelector:@selector(signUpBookSignUpFacebookRequestedForCell:)]) {
            [self.delegate performSelector:@selector(signUpBookSignUpFacebookRequestedForCell:) withObject:self];
        }
    } else if (buttonView == self.emailButton) {
        if ([self.delegate respondsToSelector:@selector(signUpBookSignUpEmailRequestedForCell:)]) {
            [self.delegate performSelector:@selector(signUpBookSignUpEmailRequestedForCell:) withObject:self];
        }
    }
}

#pragma mark - Properties

- (CKFacebookSignInButtonView *)facebookButton {
    if (!_facebookButton) {
        UIEdgeInsets insets = UIEdgeInsetsMake(20.0, 40.0, 40.0, 40.0);
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_signup_facebook.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(37.0, 10.0, 37.0, 10.0)];
        CGSize availableSize = CGSizeMake(self.bookCoverView.bounds.size.width - insets.left - insets.right,
                                          buttonImage.size.height);
        
        _facebookButton = [[CKFacebookSignInButtonView alloc] initWithWidth:self.emailButton.frame.size.width
                                                                       text:@"SIGNUP WITH FACEBOOK" activity:NO delegate:self];
        _facebookButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _facebookButton.frame = CGRectMake(insets.left + floorf((availableSize.width - _emailButton.frame.size.width) / 2.0),
                                           self.emailButton.frame.origin.y - _facebookButton.frame.size.height + 7.0,
                                           _facebookButton.frame.size.width,
                                           _facebookButton.frame.size.height);
    }
    return _facebookButton;
}

- (CKSignInButtonView *)emailButton {
    if (!_emailButton) {
        UIEdgeInsets insets = UIEdgeInsetsMake(20.0, 20.0, 10.0, 20.0);
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_signup_white.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(37.0, 10.0, 37.0, 10.0)];
        CGSize availableSize = CGSizeMake(self.bookCoverView.bounds.size.width - insets.left - insets.right,
                                          buttonImage.size.height);
        
        _emailButton = [[CKSignInButtonView alloc] initWithWidth:availableSize.width text:@"SIGNUP WITH EMAIL"
                                                        activity:NO delegate:self];
        _emailButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _emailButton.frame = CGRectMake(insets.left + floorf((availableSize.width - _emailButton.frame.size.width) / 2.0),
                                        self.contentView.bounds.size.height - _emailButton.frame.size.height - insets.bottom,
                                        _emailButton.frame.size.width,
                                        _emailButton.frame.size.height);
    }
    return _emailButton;
}

@end
