//
//  RecipeCollectionViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeCollectionViewCell.h"
#import <Parse/Parse.h>
#import "CKRecipe.h"
#import "Theme.h"
#import "UIImage+ProportionalFill.h"

@interface RecipeCollectionViewCell ()

@property (nonatomic, strong) PFImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation RecipeCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        PFImageView *imageView = [[PFImageView alloc] initWithImage:nil];
        imageView.frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, 200.0);
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [Theme recipeGridTitleFont];
        titleLabel.textColor = [Theme recipeGridTitleColour];
        titleLabel.numberOfLines = 2;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
    }
    return self;
}

- (void)configureRecipe:(CKRecipe *)recipe {
    self.recipe = recipe;
    [self updateTitle];
    [self updateImage];
}

- (void)updateImage {
    DLog();
    if ([self.recipe imageFile]) {
//        self.imageView.file = [self.recipe imageFile];
//        [self.imageView loadInBackground:^(UIImage *image, NSError *error) {
//            if (!error) {
//                UIImage *imageToFit = [image imageCroppedToFitSize:self.imageView.bounds.size];
//                self.imageView.image = imageToFit;
//            } else {
//                DLog(@"Error loading image in background: %@", [error description]);
//            }
//        }];
    }
}

#pragma mark - Private methods

- (void)updateTitle {
    NSString *title = [self.recipe.name uppercaseString];
    CGSize size = [title sizeWithFont:self.titleLabel.font constrainedToSize:self.contentView.bounds.size
                        lineBreakMode:NSLineBreakByWordWrapping];
    self.titleLabel.frame = CGRectIntegral(CGRectMake(0.0, 0.0, size.width, size.height));
    self.titleLabel.text = title;
}

@end
