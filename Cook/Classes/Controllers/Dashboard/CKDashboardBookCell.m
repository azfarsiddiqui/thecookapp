//
//  CKDashboardBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKDashboardBookCell.h"
#import <QuartzCore/QuartzCore.h>

@interface CKDashboardBookCell ()

@property (nonatomic, retain) UILabel *textLabel;

- (CGSize)availableSize;

@end

@implementation CKDashboardBookCell

#define kContentInsets          UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
#define kBookTitleFont          [UIFont boldSystemFontOfSize:40.0]
#define kBookTitleColour        [UIColor lightGrayColor]
#define kBookTitleShadowColour  [UIColor blackColor]

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIImageView *bookImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_defaultbook.png"]];
        bookImageView.center = self.contentView.center;
        [self.contentView addSubview:bookImageView];
        
        DLog(@"cell size: %@", NSStringFromCGSize(self.contentView.bounds.size));
        CGSize availableSize = [self availableSize];
        CGSize size = [@"A" sizeWithFont:kBookTitleFont constrainedToSize:availableSize
                           lineBreakMode:NSLineBreakByTruncatingTail];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kContentInsets.left,
                                                                   floorf((self.contentView.bounds.size.height - size.height) / 2.0),
                                                                   size.width,
                                                                   size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        label.backgroundColor = [UIColor clearColor];
        label.font = kBookTitleFont;
        label.textColor = kBookTitleColour;
        label.shadowColor = kBookTitleShadowColour;
        label.shadowOffset = CGSizeMake(0.0, 1.0);
        [self.contentView addSubview:label];
        self.textLabel = label;
    }
    return self;
}

- (void)setText:(NSString *)text {
    CGSize availableSize = [self availableSize];
    CGSize size = [text sizeWithFont:kBookTitleFont constrainedToSize:[self availableSize]
                       lineBreakMode:NSLineBreakByTruncatingTail];
    self.textLabel.frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - size.width) / 2.0),
                                      self.textLabel.frame.origin.y,
                                      size.width,
                                      size.height);
    self.textLabel.text = text;
}

#pragma mark - Private methods

- (CGSize)availableSize {
    return CGSizeMake(self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

@end
