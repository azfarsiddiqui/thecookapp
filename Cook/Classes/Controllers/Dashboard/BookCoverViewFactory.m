//
//  BookCoverViewFactory.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCoverViewFactory.h"

@implementation BookCoverViewFactory

+ (BookView *)bookCoverViewWithFrame:(CGRect)frame {
    return [[BookView alloc] initWithFrame:frame];
}

+ (BookView *)bookCoverViewWithType:(NSString *)type frame:(CGRect)frame {
    BookView *bookCoverView = [BookCoverViewFactory bookCoverViewWithFrame:frame];
    bookCoverView.type = type;
    return bookCoverView;
}

@end
