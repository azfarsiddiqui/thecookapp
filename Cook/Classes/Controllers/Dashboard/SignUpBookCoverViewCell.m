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

#define kWidth  272.0   // 270 + 12 shadows left/right

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.registerButton];
        [self.contentView addSubview:self.signInButton];
    }
    return self;
}

- (void)loadBook:(CKBook *)book {
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
        _signInButton = [[CKBlueSignInButtonView alloc] initWithWidth:self.registerButton.frame.size.width
                                                                 text:NSLocalizedString(@"SIGN IN", nil)
                                                             activity:NO delegate:self];
        _signInButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
        _signInButton.frame = CGRectMake(self.registerButton.frame.origin.x,
                                         self.registerButton.frame.origin.y - _signInButton.frame.size.height + 8.0,
                                         _signInButton.frame.size.width,
                                         _signInButton.frame.size.height);
    }
    return _signInButton;
}

- (CKSignInButtonView *)registerButton {
    if (!_registerButton) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 0.0, 16.0, 0.0);
        _registerButton = [[CKSignInButtonView alloc] initWithWidth:kWidth text:NSLocalizedString(@"REGISTER", nil) activity:NO delegate:self];
        _registerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        _registerButton.frame = CGRectMake(floorf((self.contentView.bounds.size.width - kWidth) / 2.0),
                                           self.contentView.bounds.size.height - _registerButton.frame.size.height - insets.bottom,
                                           _registerButton.frame.size.width,
                                           _registerButton.frame.size.height);
    }
    return _registerButton;
}

@end
