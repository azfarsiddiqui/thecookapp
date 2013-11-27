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
@property (nonatomic, strong) UIView *iconView;

@end

@implementation TagListCell

#define kColorSelected  [UIColor colorWithRed:0.118 green:0.624 blue:0.988 alpha:1.000]

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //Add subvierws
        [self.contentView addSubview:self.iconView];
        [self.iconView addSubview:self.tagIconSelectedView];
        [self.iconView addSubview:self.tagIconView];
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

//- (void)setHighlighted:(BOOL)highlighted {
//    self.tagIconView.hidden = !highlighted;
//    self.tagIconSelectedView.hidden = highlighted;
//}

- (void)configureTag:(CKRecipeTag *)recipeTag {
    self.tagLabel.text = [recipeTag.displayName uppercaseString];
    [self.tagLabel sizeToFit];
    self.recipeTag = recipeTag;
    [self configImageForType:recipeTag.imageType];
}

#pragma mark - Private methods

- (void)loadLayout {
    NSDictionary *views = @{@"tagLabel":self.tagLabel, @"iconView":self.iconView};
    self.tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=0)-[iconView]" options:0 metrics:0 views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[iconView]-[tagLabel]-(>=0)-|" options:NSLayoutFormatAlignAllCenterX metrics:0 views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.iconView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.f constant:0.f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.f constant:0.f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagIconView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.iconView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.f constant:0.f]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagIconSelectedView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.iconView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.f constant:0.f]];
}

- (void)configImageForType:(NSString *)imageType {
    if ([self.recipeTag.imageType isEqualToString:@"savoury"]) {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_savoury_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_savoury_on"];
    } else if ([self.recipeTag.imageType isEqualToString:@"drink"]) {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_drink_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_drink_on"];
    } else if ([self.recipeTag.imageType isEqualToString:@"health"]) {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_health_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_health_on"];
    } else if ([self.recipeTag.imageType isEqualToString:@"method"]) {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_method_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_method_on"];
    } else if ([self.recipeTag.imageType isEqualToString:@"meal"]) {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_meal_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_meal_on"];
    } else if ([self.recipeTag.imageType isEqualToString:@"bake"]) {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_bake_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_bake_on"];
    } else if ([self.recipeTag.imageType isEqualToString:@"condiment"]) {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_condiment_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_condiment_on"];
    } else if ([self.recipeTag.imageType isEqualToString:@"meat"]) {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_meat_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_meat_on"];
    } else if ([self.recipeTag.imageType isEqualToString:@"ingredient"]) {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_ingredient_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_ingredient_on"];
    } else {
        self.tagIconView.image = [UIImage imageNamed:@"cook_tags_meal_off"];
        self.tagIconSelectedView.image = [UIImage imageNamed:@"cook_tags_meal_on"];
    }
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

- (UIView *)iconView {
    if (!_iconView) {
        _iconView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _iconView;
}

@end
