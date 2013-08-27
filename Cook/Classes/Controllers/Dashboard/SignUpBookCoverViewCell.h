//
//  SignUpBookCoverViewCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopBookCoverViewCell.h"

@class SignUpBookCoverViewCell;

@protocol SignUpBookCoverViewCellDelegate <BenchtopBookCoverViewCellDelegate>

@optional
- (void)signUpBookSignInRequestedForCell:(SignUpBookCoverViewCell *)cell;
- (void)signUpBookRegisterRequestedForCell:(SignUpBookCoverViewCell *)cell;

@end

@interface SignUpBookCoverViewCell : BenchtopBookCoverViewCell

@end
