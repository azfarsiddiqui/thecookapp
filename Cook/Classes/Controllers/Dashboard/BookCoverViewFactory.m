//
//  BookCoverViewFactory.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCoverViewFactory.h"

@implementation BookCoverViewFactory

+ (BookCoverView *)bookCoverViewWithFrame:(CGRect)frame {
    return [[BookCoverView alloc] initWithFrame:frame];
}

+ (BookCoverView *)bookCoverViewWithType:(NSString *)type frame:(CGRect)frame {
    BookCoverView *bookCoverView = [BookCoverViewFactory bookCoverViewWithFrame:frame];
    bookCoverView.type = type;
    return bookCoverView;
}

@end
