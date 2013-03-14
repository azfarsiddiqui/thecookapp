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

@end

@implementation StoreBookCoverViewCell

+ (CGSize)cellSize {
    return [BenchtopBookCoverViewCell cellSize];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
//        // Follow button.
//        UIButton *followButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_dash_library_add.png"]
//                                                      target:self
//                                                    selector:@selector(followTapped:)];
//        followButton.frame = CGRectMake(self.contentView.bounds.size.width - 70.0,
//                                        -20.0,
//                                        followButton.frame.size.width,
//                                        followButton.frame.size.height);
//        [self.contentView addSubview:followButton];
        
    }
    return self;
}

#pragma mark - Private methods

- (void)followTapped:(id)sender {
    if (self.delegate) {
        [self.delegate storeBookFollowTappedForCell:self];
    }
}


@end
