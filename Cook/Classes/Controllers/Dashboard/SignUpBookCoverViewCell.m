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
#import "CKBlueSignInButtonView.h"

@interface SignUpBookCoverViewCell () <CKSignInButtonViewDelegate>

@property (nonatomic, strong) CKSignInButtonView *registerButton;
@property (nonatomic, strong) CKBlueSignInButtonView *signInButton;

@end

@implementation SignUpBookCoverViewCell

#define kWidth  142.0

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.signInButton];
        [self.contentView addSubview:self.registerButton];
    }
    return self;
}

- (void)loadBook:(CKBook *)book {
    self.bookCoverView.illustrationImageView.alpha = 0.5;
    [super loadBook:book];
}

#pragma mark - CKSignInButtonViewDelegate methods

- (void)signInTappedForButtonView:(CKSignInButtonView *)buttonView {
    if (buttonView == self.signInButton) {
        if ([self.delegate respondsToSelector:@selector(signUpBookSignInRequestedForCell:)]) {
            [self.delegate performSelector:@selector(signUpBookSignInRequestedForCell:) withObject:self];
        }
    } else if (buttonView == self.registerButton) {
        if ([self.delegate respondsToSelector:@selector(signUpBookRegisterRequestedForCell:)]) {
            [self.delegate performSelector:@selector(signUpBookRegisterRequestedForCell:) withObject:self];
        }
    }
}

#pragma mark - Properties

- (CKBlueSignInButtonView *)signInButton {
    if (!_signInButton) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 8.0, 8.0, 0.0);
        _signInButton = [[CKBlueSignInButtonView alloc] initWithWidth:self.registerButton.frame.size.width text:@"SIGN IN" activity:NO delegate:self];
        _signInButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
        _signInButton.frame = CGRectMake(insets.left,
                                         self.contentView.bounds.size.height - _signInButton.frame.size.height - insets.bottom,
                                         _signInButton.frame.size.width,
                                         _signInButton.frame.size.height);
    }
    return _signInButton;
}

- (CKSignInButtonView *)registerButton {
    if (!_registerButton) {
        _registerButton = [[CKSignInButtonView alloc] initWithWidth:kWidth text:@"REGISTER" activity:NO delegate:self];
        _registerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        _registerButton.frame = CGRectMake(self.signInButton.frame.origin.x + self.signInButton.frame.size.width,
                                           self.signInButton.frame.origin.y,
                                           _registerButton.frame.size.width,
                                           _registerButton.frame.size.height);
    }
    return _registerButton;
}

@end
