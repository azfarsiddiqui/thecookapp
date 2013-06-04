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

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *numRecipesLabel;

@end

@implementation BookIndexCell

#define kContentInsets      UIEdgeInsetsMake(-8.0, 5.0, 0.0, 5.0)
#define kTitleNumGap        20.0
#define kTitleSubtitleGap   -10.0

+ (CGSize)cellSize {
    return (CGSize){
        400.0, [self requiredHeight]
    };
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

        // Subtitle.
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.font = [Theme bookIndexSubtitleFont];
        subtitleLabel.textColor = [Theme bookIndexSubtitleColour];
        subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:subtitleLabel];
        self.subtitleLabel = subtitleLabel;
        
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
    CGSize size;
    
    // Number of recipes.
    NSString *numRecipesDisplay = [NSString stringWithFormat:@"%d", [recipes count]];
    size = [numRecipesDisplay sizeWithFont:self.numRecipesLabel.font constrainedToSize:availableSize lineBreakMode:NSLineBreakByClipping];
    self.numRecipesLabel.frame = CGRectMake(self.contentView.bounds.size.width - kContentInsets.right - size.width,
                                            kContentInsets.top,
                                            size.width,
                                            size.height);
    self.numRecipesLabel.text = numRecipesDisplay;
    
    // Title.
    NSString *title = [category uppercaseString];
    size = [title sizeWithFont:self.titleLabel.font
             constrainedToSize:CGSizeMake(availableSize.width - self.numRecipesLabel.frame.size.width - kTitleNumGap,
                                          availableSize.height)
                 lineBreakMode:NSLineBreakByTruncatingTail];
    self.titleLabel.frame = CGRectMake(kContentInsets.left, kContentInsets.top, size.width, size.height);
    self.titleLabel.text = title;
    
    // Subtitle.
    NSString *subtitle = [[[recipes collect:^id(CKRecipe *recipe) {
        return recipe.name;
    }] componentsJoinedByString:@", "] uppercaseString];
    size = [subtitle sizeWithFont:self.subtitleLabel.font
                constrainedToSize:CGSizeMake(availableSize.width - self.numRecipesLabel.frame.size.width,
                                             availableSize.height)
                    lineBreakMode:NSLineBreakByTruncatingTail];
    self.subtitleLabel.frame = CGRectMake(kContentInsets.left,
                                          self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleSubtitleGap,
                                          size.width,
                                          size.height);
    self.subtitleLabel.text = subtitle;
    
    // Workaround to get rid of extra spacing that gets introduced when it truncates.
    [self.subtitleLabel sizeToFit];
    self.subtitleLabel.frame = CGRectMake(self.subtitleLabel.frame.origin.x,
                                          self.subtitleLabel.frame.origin.y,
                                          size.width,
                                          self.subtitleLabel.frame.size.height);
}

#pragma mark - Private methods

- (CGSize)availableSize {
    return CGSizeMake(self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

+ (CGFloat)requiredHeight {
    CGFloat height = kContentInsets.top;
    CGSize titleSize = [@"A" sizeWithFont:[Theme bookIndexFont] constrainedToSize:(CGSize){MAXFLOAT, MAXFLOAT} lineBreakMode:NSLineBreakByClipping];
    CGSize subtitleSize = [@"A" sizeWithFont:[Theme bookIndexSubtitleFont] constrainedToSize:(CGSize){MAXFLOAT, MAXFLOAT} lineBreakMode:NSLineBreakByClipping];
    height += titleSize.height + kTitleSubtitleGap + subtitleSize.height;
    height += kContentInsets.bottom;
    return height;
}

@end
