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

@interface CategoryHeaderView ()

@property (nonatomic, strong) PFImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation CategoryHeaderView

#define kCategoryFont   [Theme defaultBoldFontWithSize:64.0]

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        // Pre-create the background image view.
        PFImageView *imageView = [[PFImageView alloc] initWithImage:nil];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        // Pre-create the label.
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = kCategoryFont;
        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        self.label = label;
        
    }
    return self;
}

- (void)prepareForReuse {
    self.label.text = nil;
}

- (void)configureCategoryName:(NSString *)categoryName {
    self.categoryName = categoryName;
    NSString *name = [categoryName uppercaseString];
    CGSize size = [name sizeWithFont:kCategoryFont forWidth:self.bounds.size.width lineBreakMode:NSLineBreakByCharWrapping];
    self.label.frame = CGRectIntegral(CGRectMake((self.bounds.size.width - size.width) / 2.0,
                                                 (self.bounds.size.height - size.height) / 2.0,
                                                 size.width,
                                                 size.height));
    self.label.text = name;
}

- (void)configureImageForRecipe:(CKRecipe *)recipe {
    DLog("Configure category header with image from recipe [%@]", recipe.name);
    if ([recipe imageFile]) {
       self.imageView.file = [recipe imageFile];
       [self.imageView loadInBackground:^(UIImage *image, NSError *error) {
           if (!error) {
               DLog(@"Loaded image for recipe [%@]", recipe.name);
               UIImage *imageToFit = [image imageCroppedToFitSize:self.imageView.bounds.size];
               self.imageView.image = imageToFit;
           } else {
               DLog(@"Error loading image in background: %@", [error description]);
           }
       }];
    }
}

@end
