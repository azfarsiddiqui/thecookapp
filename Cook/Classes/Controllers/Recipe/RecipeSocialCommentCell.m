//
//  RecipeSocialCommentsCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeSocialCommentCell.h"

@interface RecipeSocialCommentCell ()

@end

@implementation RecipeSocialCommentCell

#define kWidth  600.0

+ (CGSize)sizeForComment:(CKRecipeComment *)comment {
    return CGSizeZero;
}

+ (CGSize)unitSize {
    return (CGSize){ kWidth, 100.0 };
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

@end
