//
//  CategoryHeaderView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryHeaderView.h"
#import <Parse/Parse.h>
#import "Theme.h"
#import "BookNavigationFlowLayout.h"
#import "UIImage+ProportionalFill.h"
#import "CKRecipe.h"
#import "CKRecipeImage.h"
#import "CategoryHeaderLabelView.h"

@interface CategoryHeaderView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CategoryHeaderLabelView *labelView;;

@end

@implementation CategoryHeaderView

#define kCategoryFont   [Theme defaultFontWithSize:100.0]

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        // Pre-create the background image view.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        // Pre-create the label.
        CategoryHeaderLabelView *labelView = [[CategoryHeaderLabelView alloc] initWithBounds:frame.size];
        [self addSubview:labelView];
        self.labelView = labelView;
        
    }
    return self;
}

- (void)configureCategoryName:(NSString *)categoryName {
    self.categoryName = categoryName;
    [self.labelView setText:categoryName];
    self.labelView.frame = CGRectIntegral(CGRectMake((self.bounds.size.width - self.labelView.frame.size.width) / 2.0,
                                                     (self.bounds.size.height - self.labelView.frame.size.height) / 2.0,
                                                     self.labelView.frame.size.width,
                                                     self.labelView.frame.size.height));
}

- (void)configureImage:(UIImage *)image {
    self.imageView.image = image;
    if (image) {
        self.imageView.alpha = 0.0;
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.imageView.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

- (CGSize)imageSize {
    return self.imageView.frame.size;
}

@end
