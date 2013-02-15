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

@interface CategoryHeaderView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation CategoryHeaderView

#define kCategoryFont   [Theme defaultBoldFontWithSize:64.0]

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        // Pre-create the background image view.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
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

- (void)configureImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)configureImageForRecipe:(CKRecipe *)recipe {
//    DLog("Configure category header with image from recipe [%@]", recipe.name);
//    self.imageView.image = nil;
//    
//    if (recipe.recipeImage) {
//        self.imageView.hidden = NO;
//        self.imageView.file = [recipe.recipeImage imageFile];
//        [self.imageView loadInBackground:^(UIImage *image, NSError *error) {
//           if (!error) {
//               DLog(@"Loaded image for recipe [%@]", recipe.name);
//               
//               dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//               dispatch_async(queue, ^{
//                   UIImage *imageToFit = [image imageCroppedToFitSize:self.imageView.bounds.size];
//                   dispatch_async(dispatch_get_main_queue(), ^{
//                       self.imageView.image = imageToFit;
//                   });
//               });
//
////               self.imageView.image = image;
//           } else {
//               DLog(@"Error loading image in background: %@", [error description]);
//           }
//       }];
//    } else {
//        self.imageView.hidden = YES;
//    }
}

- (CGSize)imageSize {
    return self.imageView.frame.size;
}

@end
