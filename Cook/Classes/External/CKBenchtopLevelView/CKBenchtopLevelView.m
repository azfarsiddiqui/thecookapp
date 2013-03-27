//
//  CKBenchtopLevelView.m
//  CKBenchtopLevelView
//
//  Created by Jeff Tan-Ang on 27/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBenchtopLevelView.h"

@interface CKBenchtopLevelView ()

@property (nonatomic, assign) NSInteger numLevels;
@property (nonatomic, strong) NSMutableArray *dotViews;

@end

@implementation CKBenchtopLevelView

#define kDotInsets  UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)

- (id)initWithLevels:(NSInteger)numLevels {
    if ([super initWithFrame:CGRectZero]) {
        self.backgroundColor = [UIColor clearColor];
        self.numLevels = numLevels;
        [self setUpDots];
    }
    return self;
}

- (void)setLevel:(NSInteger)level {
    if (level > self.numLevels - 1) {
        return;
    }
    
    self.currentLevel = level;
    for (NSInteger levelIndex = 0; levelIndex < self.numLevels; levelIndex++) {
        UIImageView *dotView = [self.dotViews objectAtIndex:levelIndex];
        dotView.image = [self dotImageForOn:(levelIndex == level)];
    }
}

#pragma mark - Private methods

- (void)setUpDots {
    CGFloat yOffset = 0.0;
    self.dotViews = [NSMutableArray arrayWithCapacity:self.numLevels];
    for (NSInteger level = 0; level < self.numLevels; level++) {
        
        UIImageView *dotView = [[UIImageView alloc] initWithImage:[self dotImageForOn:NO]];
        dotView.frame = CGRectMake(kDotInsets.left, kDotInsets.top, dotView.frame.size.width, dotView.frame.size.height);
        [self.dotViews addObject:dotView];
        
        // Container view to house the dot.
        UIView *dotContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                            yOffset,
                                                                            kDotInsets.left + dotView.frame.size.width + kDotInsets.right,
                                                                            kDotInsets.top + dotView.frame.size.height + kDotInsets.bottom)];
        dotContainerView.backgroundColor = [UIColor clearColor];
        [dotContainerView addSubview:dotView];
        [self addSubview:dotContainerView];
        
        yOffset += dotContainerView.frame.size.height;
        
        // Updates self frame as we go.
        self.frame = CGRectUnion(self.frame, dotContainerView.frame);
    }
    
    // Start at 0
    [self setLevel:0];
}

- (UIImage *)dotImageForOn:(BOOL)on {
    return on ? [UIImage imageNamed:@"cook_dash_dot_on.png"] : [UIImage imageNamed:@"cook_dash_dot_off.png"];
}

@end
