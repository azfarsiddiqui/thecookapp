//
//  TagListCell.m
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "TagListCell.h"
#import "CKEditingTextBoxView.h"
#import "CKRecipeTag.h"
#import "CKActivityIndicatorView.h"
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
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //Add subvierws
        [self.contentView addSubview:self.tagIconView];
        [self.contentView addSubview:self.tagIconSelectedView];
        self.tagIconSelectedView.alpha = 0.0;
        [self.contentView addSubview:self.tagLabel];
        [self loadLayout];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
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
    self.tagLabel.text = [recipeTag.displayName uppercaseString];
    [self.tagLabel sizeToFit];
    self.recipeTag = recipeTag;
    [self configImageForType:recipeTag.imageType];
}

#pragma mark - Private methods

- (void)loadLayout {
    NSDictionary *views = @{@"tagLabel":self.tagLabel,
                            @"iconView":self.tagIconView};
    self.tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tagIconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tagIconSelectedView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-10)-[iconView]-(-3)-[tagLabel(20)]-(>=0)-|" options:NSLayoutFormatAlignAllCenterX metrics:0 views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.f constant:0.f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagIconSelectedView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.tagIconView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.f constant:0.f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagIconSelectedView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.tagIconView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.f constant:0.f]];
}

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
    self.tagIconSelectedView.image = selectedImage;
    self.normalImage = normalImage;
    self.highlightedImage = highlightedImage;
    
    self.tagIconView.image = self.normalImage;
}

#pragma mark - Properties

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagLabel.numberOfLines = 1;
        _tagLabel.font = [Theme tagLabelFont];
        _tagLabel.textColor = [Theme tagLabelColor];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

- (UIImageView *)tagIconView {
    if (!_tagIconView) {
        _tagIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_tags_meal_off"]];
    }
    return _tagIconView;
}

- (UIImageView *)tagIconSelectedView {
    if (!_tagIconSelectedView) {
        _tagIconSelectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_tags_meal_on"]];
    }
    return _tagIconSelectedView;
}

@end
