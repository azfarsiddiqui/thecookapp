//
//  BookProfileHeaderView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookProfileHeaderView.h"
#import "CKBookSummaryView.h"

@interface BookProfileHeaderView ()

@property (nonatomic, strong) UIView *underlayView;
@property (nonatomic, strong) CKBookSummaryView *summaryView;

@end

@implementation BookProfileHeaderView

+ (CGFloat)profileHeaderWidth {
    return 400.0;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.underlayView];
    }
    return self;
}

- (void)configureWithBook:(CKBook *)book {
    if (self.summaryView.superview) {
        return;
    }
    
    self.summaryView = [[CKBookSummaryView alloc] initWithBook:book];
    self.summaryView.frame = (CGRect){
        floorf((self.bounds.size.width - self.summaryView.frame.size.width) / 2.0),
        floorf((self.bounds.size.height - self.summaryView.frame.size.height) / 2.0),
        self.summaryView.frame.size.width,
        self.summaryView.frame.size.height
    };
    [self addSubview:self.summaryView];
    
}

#pragma mark - Properties

- (UIView *)underlayView {
    if (!_underlayView) {
        _underlayView = [[UIView alloc] initWithFrame:self.bounds];
        _underlayView.backgroundColor = [UIColor blackColor];
        _underlayView.alpha = 0.8;
    }
    return _underlayView;
}

@end
