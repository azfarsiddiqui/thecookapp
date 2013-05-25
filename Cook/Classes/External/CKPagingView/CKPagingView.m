//
//  CKPagingView.m
//  CKPagingView
//
//  Created by Jeff Tan-Ang on 27/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPagingView.h"

@interface CKPagingView ()

@property (nonatomic, strong) NSMutableArray *dotViews;

@end

@implementation CKPagingView

#define kDotInsets  UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)

- (id)initWithNumPages:(NSInteger)numPages type:(CKPagingViewType)type {
    return [self initWithNumPages:numPages type:type contentInsets:kDotInsets];
}

- (id)initWithNumPages:(NSInteger)numPages type:(CKPagingViewType)type contentInsets:(UIEdgeInsets)contentInsets {
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundColor = [UIColor clearColor];
        self.numPages = numPages;
        self.pagingType = type;
        
        [self setUpDots];
    }
    return self;
}

- (void)setPage:(NSInteger)page {
    
    if (page > self.numPages - 1) {
        return;
    }
    
    NSLog(@"setPage [%d]", page);
    
    self.currentPage = page;
    for (NSInteger pageIndex = 0; pageIndex < self.numPages; pageIndex++) {
        UIImageView *dotView = [self.dotViews objectAtIndex:pageIndex];
        dotView.image = [self dotImageForOn:(pageIndex == page)];
    }
}

#pragma mark - Private methods

- (void)setUpDots {
    CGPoint dotOffset = CGPointZero;
    
    self.dotViews = [NSMutableArray arrayWithCapacity:self.numPages];
    for (NSInteger level = 0; level < self.numPages; level++) {
        
        UIImageView *dotView = [[UIImageView alloc] initWithImage:[self dotImageForOn:NO]];
        dotView.frame = CGRectMake(kDotInsets.left, kDotInsets.top, dotView.frame.size.width, dotView.frame.size.height);
        [self.dotViews addObject:dotView];
        
        // Container view to house the dot.
        UIView *dotContainerView = [[UIView alloc] initWithFrame:CGRectMake(dotOffset.x,
                                                                            dotOffset.y,
                                                                            kDotInsets.left + dotView.frame.size.width + kDotInsets.right,
                                                                            kDotInsets.top + dotView.frame.size.height + kDotInsets.bottom)];
        dotContainerView.backgroundColor = [UIColor clearColor];
        [dotContainerView addSubview:dotView];
        [self addSubview:dotContainerView];
        
        // Increment offset.
        if (self.pagingType == CKPagingViewTypeHorizontal) {
            dotOffset.x += dotContainerView.frame.size.width;
        } else {
            dotOffset.y += dotContainerView.frame.size.height;
        }
        
        // Updates self frame as we go.
        self.frame = CGRectUnion(self.frame, dotContainerView.frame);
    }
    
    // Start at 0
    [self setPage:0];
}

- (UIImage *)dotImageForOn:(BOOL)on {
    return on ? [UIImage imageNamed:@"cook_dash_dot_on.png"] : [UIImage imageNamed:@"cook_dash_dot_off.png"];
}

@end
