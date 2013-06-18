//
//  BookIndexCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookIndexCell.h"
#import "Theme.h"
#import "MRCEnumerable.h"
#import "CKRecipe.h"

@interface BookIndexCell ()

@end

@implementation BookIndexCell

#define kTitleNumGap        20.0

+ (CGSize)cellSize {
    return (CGSize){
        400.0, [self requiredHeight]
    };
}

+ (CGFloat)requiredHeight {
    UIEdgeInsets contentInsets = [self contentInsets];
    CGFloat height = contentInsets.top;
    CGSize titleSize = [@"A" sizeWithFont:[Theme bookIndexFont] constrainedToSize:(CGSize){MAXFLOAT, MAXFLOAT} lineBreakMode:NSLineBreakByClipping];
    height += titleSize.height;
    height += contentInsets.bottom;
    return height;
}

+ (UIEdgeInsets)contentInsets {
    return UIEdgeInsetsMake(-8.0, 5.0, 0.0, 5.0);
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        // Title.
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [Theme bookIndexFont];
        titleLabel.textColor = [Theme bookIndexColour];
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        // Right num recipes.
        UILabel *numRecipesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        numRecipesLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        numRecipesLabel.backgroundColor = [UIColor clearColor];
        numRecipesLabel.font = [Theme bookIndexNumRecipesFont];
        numRecipesLabel.textColor = [Theme bookIndexNumRecipesColour];
        numRecipesLabel.lineBreakMode = NSLineBreakByClipping;
        [self.contentView addSubview:numRecipesLabel];
        self.numRecipesLabel = numRecipesLabel;
        
    }
    return self;
}

- (void)configureCategory:(NSString *)category recipes:(NSArray *)recipes {
    CGSize availableSize = [self availableSize];
    UIEdgeInsets contentInsets = [BookIndexCell contentInsets];
    CGSize size;
    
    // Number of recipes.
    NSString *numRecipesDisplay = [NSString stringWithFormat:@"%d", [recipes count]];
    size = [numRecipesDisplay sizeWithFont:self.numRecipesLabel.font constrainedToSize:availableSize lineBreakMode:NSLineBreakByClipping];
    self.numRecipesLabel.frame = CGRectMake(self.contentView.bounds.size.width - contentInsets.right - size.width,
                                            contentInsets.top,
                                            size.width,
                                            size.height);
    self.numRecipesLabel.text = numRecipesDisplay;
    
    // Title.
    NSString *title = [category uppercaseString];
    size = [title sizeWithFont:self.titleLabel.font
             constrainedToSize:CGSizeMake(availableSize.width - self.numRecipesLabel.frame.size.width - kTitleNumGap,
                                          availableSize.height)
                 lineBreakMode:NSLineBreakByTruncatingTail];
    self.titleLabel.frame = CGRectMake(contentInsets.left, contentInsets.top, size.width, size.height);
    self.titleLabel.text = title;
    
}

- (CGSize)availableSize {
    UIEdgeInsets contentInsets = [BookIndexCell contentInsets];
    return CGSizeMake(self.contentView.bounds.size.width - contentInsets.left - contentInsets.right,
                      self.contentView.bounds.size.height - contentInsets.top - contentInsets.bottom);
}

#pragma mark - Private methods

@end
