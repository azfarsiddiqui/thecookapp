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
@property (nonatomic, strong) UIView *selectedDotView;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) BOOL animating;

@end

@implementation CKPagingView

#define kDotInsets  UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)

- (id)initWithNumPages:(NSInteger)numPages type:(CKPagingViewType)type {
    return [self initWithNumPages:numPages type:type contentInsets:kDotInsets];
}

- (id)initWithNumPages:(NSInteger)numPages type:(CKPagingViewType)type contentInsets:(UIEdgeInsets)contentInsets {
    return [self initWithNumPages:numPages type:type animated:YES contentInsets:contentInsets];
}

- (id)initWithNumPages:(NSInteger)numPages type:(CKPagingViewType)type animated:(BOOL)animated
         contentInsets:(UIEdgeInsets)contentInsets {
    
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundColor = [UIColor clearColor];
        self.numPages = numPages;
        self.pagingType = type;
        self.animated = animated;
        
        [self setUpDots];
    }
    return self;
}

- (void)setPage:(NSInteger)page {
    if (page > self.numPages - 1) {
        return;
    }
    
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    NSInteger previousPage = self.currentPage;
    self.currentPage = page;
    
    UIImageView *previousDotView = [self.dotViews objectAtIndex:previousPage];
    UIImageView *nextDotView = [self.dotViews objectAtIndex:page];
    
    if (self.animated) {
        
        if (!self.selectedDotView.superview) {
            self.selectedDotView.frame = nextDotView.superview.frame;
            [self addSubview:self.selectedDotView];
        }
        
        previousDotView.hidden = NO;
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.selectedDotView.frame = nextDotView.superview.frame;
                         }
                         completion:^(BOOL finished) {
                             self.animating = NO;
                             nextDotView.hidden = YES;
                         }];
        
    } else {
        
        UIImageView *previousDotView = [self.dotViews objectAtIndex:previousPage];
        previousDotView.image = [self dotImageForOn:NO];
        UIImageView *nextDotView = [self.dotViews objectAtIndex:page];
        nextDotView.image = [self dotImageForOn:YES];
        self.animating = NO;
    }
}

#pragma mark - Properties

- (UIView *)selectedDotView {
    if (!_selectedDotView) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self dotImageForOn:YES]];
        _selectedDotView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                   0.0,
                                                                   kDotInsets.left + imageView.frame.size.width + kDotInsets.right,
                                                                   kDotInsets.top + imageView.frame.size.height + kDotInsets.bottom)];
        imageView.frame = CGRectMake(kDotInsets.left, kDotInsets.top, imageView.frame.size.width, imageView.frame.size.height);
        [_selectedDotView addSubview:imageView];
    }
    return _selectedDotView;
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
