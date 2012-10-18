//
//  BookCoverView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCoverView.h"

@interface BookCoverView ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BookCoverView

#define kContentInsets          UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
#define kBookTitleFont          [UIFont boldSystemFontOfSize:40.0]
#define kBookTitleColour        [UIColor lightGrayColor]
#define kBookTitleShadowColour  [UIColor blackColor]

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutBookCover];
    }
    return self;
}

- (void)layoutBookCover {
    [self initBackground];
}

- (void)updateTitle:(NSString *)title {
    self.title = title;
    [self.titleLabel removeFromSuperview];
    
    CGSize size = [title sizeWithFont:kBookTitleFont constrainedToSize:self.bounds.size lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                                                    floorf((self.bounds.size.height - size.height) / 2.0),
                                                                    size.width,
                                                                    size.height)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = kBookTitleFont;
    titleLabel.textColor = kBookTitleColour;
    titleLabel.shadowColor = kBookTitleShadowColour;
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    titleLabel.text = title;
    titleLabel.alpha = 0.0;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // Fade the title in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         titleLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];

}

#pragma mark - Private methods

- (void)initBackground {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_defaultbook.png"]];
    backgroundImageView.frame = CGRectMake(floorf((self.frame.size.width - backgroundImageView.frame.size.width) / 2.0),
                                           floorf((self.frame.size.height - backgroundImageView.frame.size.height) / 2.0),
                                           backgroundImageView.frame.size.width,
                                           backgroundImageView.frame.size.height);
    [self addSubview:backgroundImageView];
    [self sendSubviewToBack:backgroundImageView];
    self.backgroundImageView = backgroundImageView;
}

@end
