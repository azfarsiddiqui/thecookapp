//
//  TagListCell.m
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "TagListCell.h"
#import "CKRecipeTag.h"
#import "Theme.h"

@interface TagListCell()

@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIImageView *tagIconView;
@property (nonatomic, strong) UIImageView *tagIconSelectedView;
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *highlightedImage;

@end

@implementation TagListCell

#define kColorSelected  [UIColor colorWithRed:0.118 green:0.624 blue:0.988 alpha:1.000]

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.tagIconView];
        [self.contentView addSubview:self.tagIconSelectedView];
        [self.contentView addSubview:self.tagLabel];
        self.tagIconSelectedView.alpha = 0.0;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.tagLabel.text = nil;
    self.tagIconSelectedView.alpha = 0.0;
    self.tagIconView.alpha = 1.0;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [UIView animateWithDuration:0.1 animations:^{
        self.tagIconView.alpha = selected ? 0.0 : 1.0;
        self.tagIconSelectedView.alpha = selected ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        self.tagLabel.textColor = selected ? kColorSelected : [Theme defaultLabelColor];
    }];
}

- (void)setHighlighted:(BOOL)highlighted {
    self.tagIconView.image = highlighted ? self.highlightedImage : self.normalImage;
}

- (void)configureTag:(CKRecipeTag *)recipeTag {
    self.recipeTag = recipeTag;
    [self configImageForType:recipeTag.imageType];
    
    NSString *tagDisplay = [recipeTag.localisedDisplayName uppercaseString];
    CGSize size = [tagDisplay boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                        attributes:@{ NSFontAttributeName : self.tagLabel.font }
                                           context:nil].size;
    self.tagLabel.text = tagDisplay;
    self.tagLabel.frame = (CGRect){
        floorf((self.contentView.bounds.size.width - size.width) / 2.0),
        self.tagIconView.frame.origin.y + self.tagIconView.frame.size.height - 4.0,
        size.width,
        size.height
    };
}

#pragma mark - Private methods

- (void)configImageForType:(NSString *)imageType {
    NSMutableString *tagImageString = [NSMutableString stringWithString:@"cook_tags_"];
    [tagImageString appendString:self.recipeTag.imageType];
    UIImage *selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", tagImageString, @"_on"]];
    UIImage *normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", tagImageString, @"_off"]];
    UIImage *highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", tagImageString, @"_onpress"]];
    if (!selectedImage)
        selectedImage = [UIImage imageNamed:@"cook_tags_savoury_on"];
    if (!normalImage)
        normalImage = [UIImage imageNamed:@"cook_tags_savoury_off"];
    if (!highlightedImage)
        highlightedImage = [UIImage imageNamed:@"cook_tags_savoury_onpress"];
    
    self.normalImage = normalImage;
    self.highlightedImage = highlightedImage;
    self.tagIconSelectedView.image = selectedImage;
    self.tagIconView.image = self.normalImage;
    self.tagIconView.frame = (CGRect){
        floorf((self.contentView.bounds.size.width - normalImage.size.width) / 2.0),
        self.contentView.bounds.origin.y,
        normalImage.size.width,
        normalImage.size.height
    };
    self.tagIconSelectedView.frame = self.tagIconView.frame;
}

#pragma mark - Properties

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagLabel.numberOfLines = 0;
        _tagLabel.font = [Theme tagLabelFont];
        _tagLabel.textColor = [Theme tagLabelColor];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _tagLabel;
}

- (UIImageView *)tagIconView {
    if (!_tagIconView) {
        _tagIconView = [[UIImageView alloc] initWithImage:nil];
        _tagIconView.frame = (CGRect){
            floorf((self.contentView.bounds.size.width - _tagIconView.frame.size.width) / 2.0),
            self.contentView.bounds.origin.y,
            _tagIconView.frame.size.width,
            _tagIconView.frame.size.height
        };
    }
    return _tagIconView;
}

- (UIImageView *)tagIconSelectedView {
    if (!_tagIconSelectedView) {
        _tagIconSelectedView = [[UIImageView alloc] initWithImage:nil];
        _tagIconSelectedView.frame = self.tagIconView.frame;
    }
    return _tagIconSelectedView;
}

@end
