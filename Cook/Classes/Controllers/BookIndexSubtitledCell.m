//
//  BookIndexSubtitledCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookIndexSubtitledCell.h"
#import "Theme.h"
#import "MRCEnumerable.h"
#import "CKRecipe.h"

@interface BookIndexSubtitledCell ()

@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation BookIndexSubtitledCell

#define kTitleSubtitleGap   -10.0

+ (CGSize)cellSize {
    return (CGSize){
        400.0, [self requiredHeight]
    };
}

+ (CGFloat)requiredHeight {
    UIEdgeInsets contentInsets = [self contentInsets];
    CGFloat height = contentInsets.top;
    CGSize titleSize = [@"A" sizeWithFont:[Theme bookIndexFont] constrainedToSize:(CGSize){MAXFLOAT, MAXFLOAT} lineBreakMode:NSLineBreakByClipping];
    CGSize subtitleSize = [@"A" sizeWithFont:[Theme bookIndexSubtitleFont] constrainedToSize:(CGSize){MAXFLOAT, MAXFLOAT} lineBreakMode:NSLineBreakByClipping];
    height += titleSize.height + kTitleSubtitleGap + subtitleSize.height;
    height += contentInsets.bottom;
    return height;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        // Subtitle.
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.font = [Theme bookIndexSubtitleFont];
        subtitleLabel.textColor = [Theme bookIndexSubtitleColour];
        subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:subtitleLabel];
        self.subtitleLabel = subtitleLabel;
        
    }
    return self;
}

- (void)configureCategory:(NSString *)category recipes:(NSArray *)recipes {
    [super configureCategory:category recipes:recipes];
    
    CGSize availableSize = [self availableSize];
    UIEdgeInsets contentInsets = [BookIndexCell contentInsets];
    
    // Subtitle.
    NSString *subtitle = [[[recipes collect:^id(CKRecipe *recipe) {
        return recipe.name;
    }] componentsJoinedByString:@", "] uppercaseString];
    CGSize size = [subtitle sizeWithFont:self.subtitleLabel.font
                       constrainedToSize:CGSizeMake(availableSize.width - self.numRecipesLabel.frame.size.width,
                                             availableSize.height)
                    lineBreakMode:NSLineBreakByTruncatingTail];
    self.subtitleLabel.frame = CGRectMake(contentInsets.left,
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

@end
