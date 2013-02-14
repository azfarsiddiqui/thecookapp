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

#define kImageHeight        140.0
#define kTitleOffsetNoImage 70.0
#define kImageTitleGap      10.0

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        PFImageView *imageView = [[PFImageView alloc] initWithImage:nil];
        imageView.frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, kImageHeight);
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [Theme recipeGridTitleFont];
        titleLabel.textColor = [Theme recipeGridTitleColour];
        titleLabel.numberOfLines = 2;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.frame = CGRectMake(0.0, imageView.frame.origin.y + imageView.frame.size.height + kTitleOffsetNoImage, 0.0, 0.0);
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
    
    if ([self.recipe hasPhotos]) {
        
        self.imageView.hidden = NO;
        self.imageView.file = [self.recipe imageFile];
        [self.imageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                UIImage *imageToFit = [image imageCroppedToFitSize:self.imageView.bounds.size];
                self.imageView.image = imageToFit;
//                self.imageView.image = image;
            } else {
                DLog(@"Error loading image in background: %@", [error description]);
            }
        }];
        
    } else {
        self.imageView.image = nil;
        self.imageView.hidden = YES;
    }
}

#pragma mark - Private methods

- (void)updateTitle {
    NSString *title = [self.recipe.name uppercaseString];
    CGRect frame = self.titleLabel.frame;
    CGSize size = [title sizeWithFont:self.titleLabel.font constrainedToSize:self.contentView.bounds.size
                        lineBreakMode:NSLineBreakByWordWrapping];
    if ([self.recipe hasPhotos]) {
        frame.origin = CGPointMake(frame.origin.x, self.imageView.frame.origin.y + self.imageView.frame.size.height + kImageTitleGap);
    } else {
        frame.origin = CGPointMake(frame.origin.x, kTitleOffsetNoImage);
    }
    frame.size = CGSizeMake(size.width, size.height);
    self.titleLabel.frame = frame;
    self.titleLabel.text = title;
}

@end
