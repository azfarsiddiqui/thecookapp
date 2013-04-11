//
//  CKBookPagingView.m
//  CKBookPagingView
//
//  Created by Jeff Tan-Ang on 11/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBookPagingView.h"

@interface CKBookPagingView ()

@property (nonatomic, strong) NSMutableArray *dotViews;

@end

@implementation CKBookPagingView

#define kDotInsets  UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)

- (id)initWithNumPages:(NSUInteger)numPages {
    if ([super initWithFrame:CGRectZero]) {
        self.backgroundColor = [UIColor clearColor];
        self.numPages = numPages;
        [self setUpDots];
    }
    return self;
}

- (void)setPage:(NSInteger)page {
    if (page > [self.dotViews count] + 1) {
        return;
    }
    
    self.currentPage = page;
    for (NSInteger pageIndex = 0; pageIndex < [self.dotViews count]; pageIndex++) {
        UIImageView *dotView = [self.dotViews objectAtIndex:pageIndex];
        BOOL on = (pageIndex == page);
        if (pageIndex == 0) {
            dotView.image = [self listImageForOn:on];
        } else {
            dotView.image = [self dotImageForOn:on];
        }
    }
}

- (void)setNumPages:(NSUInteger)numPages {
    _numPages = numPages;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setUpDots];
}

#pragma mark - Private methods

- (void)setUpDots {
    self.frame = CGRectZero;
    CGFloat xOffset = 0.0;
    self.dotViews = [NSMutableArray arrayWithCapacity:self.numPages + 1];
    for (NSInteger page = 0; page < self.numPages + 1; page++) {
        
        UIImageView *dotView = nil;
        if (page == 0) {
            dotView = [[UIImageView alloc] initWithImage:[self listImageForOn:NO]];
        } else {
            dotView = [[UIImageView alloc] initWithImage:[self dotImageForOn:NO]];
        }
        dotView.frame = CGRectMake(kDotInsets.left, kDotInsets.top, dotView.frame.size.width, dotView.frame.size.height);
        [self.dotViews addObject:dotView];
        
        // Container view to house the dot.
        UIView *dotContainerView = [[UIView alloc] initWithFrame:CGRectMake(xOffset,
                                                                            0.0,
                                                                            kDotInsets.left + dotView.frame.size.width + kDotInsets.right,
                                                                            kDotInsets.top + dotView.frame.size.height + kDotInsets.bottom)];
        dotContainerView.backgroundColor = [UIColor clearColor];
        [dotContainerView addSubview:dotView];
        [self addSubview:dotContainerView];
        
        xOffset += dotContainerView.frame.size.width;
        
        // Updates self frame as we go.
        self.frame = CGRectUnion(self.frame, dotContainerView.frame);
    }
    
    // Start at 0
    [self setPage:0];
}

- (UIImage *)dotImageForOn:(BOOL)on {
    return [UIImage imageNamed:[NSString stringWithFormat:@"cook_book_dots_page_%@.png", on ? @"on" : @"off"]];
}

- (UIImage *)listImageForOn:(BOOL)on {
    return [UIImage imageNamed:[NSString stringWithFormat:@"cook_book_dots_list_%@.png", on ? @"on" : @"off"]];
}

@end
