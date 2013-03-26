//
//  CategoryHeaderView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCategoryView.h"
#import <Parse/Parse.h>
#import "Theme.h"
#import "UIImage+ProportionalFill.h"
#import "CKRecipe.h"
#import "CKRecipeImage.h"
#import "CKMaskedLabel.h"
#import "ViewHelper.h"
#import "ImageHelper.h"

@interface BookCategoryView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CKMaskedLabel *maskedLabel;

@end

@implementation BookCategoryView

#define kCategoryFont   [Theme defaultFontWithSize:100.0]
#define kCategoryInsets UIEdgeInsetsMake(40.0, 30.0, 10.0, 30.0)

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        // Pre-create the background image view.
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.backgroundColor = [Theme categoryHeaderBackgroundColour];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        // Black overlay under the label.
        UIView *overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.alpha = 0.3;
        [self addSubview:overlayView];
        self.overlayView = overlayView;
        
        // Pre-create the label.
        CKMaskedLabel *maskedLabel = [[CKMaskedLabel alloc] initWithFrame:CGRectZero];
        maskedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        maskedLabel.numberOfLines = 2;
        maskedLabel.font = kCategoryFont;
        [self addSubview:maskedLabel];
        self.maskedLabel = maskedLabel;
        
    }
    return self;
}

- (void)configureCategoryName:(NSString *)categoryName {
    self.categoryName = [categoryName uppercaseString];
    
    // Figure ou the required size with padding.
    CGSize size = [self.categoryName sizeWithFont:kCategoryFont constrainedToSize:self.bounds.size lineBreakMode:NSLineBreakByWordWrapping];
    size.width += kCategoryInsets.left + kCategoryInsets.right;
    size.height += kCategoryInsets.top + kCategoryInsets.bottom;
    
    // Set the frame in motion.
    self.maskedLabel.frame = CGRectMake(floorf((self.bounds.size.width - size.width) / 2.0),
                                        floorf((self.bounds.size.height - size.height) / 2.0),
                                        size.width,
                                        size.height);
    self.overlayView.frame = self.maskedLabel.frame;
    self.maskedLabel.insets = kCategoryInsets;
    self.maskedLabel.text = self.categoryName;
}

- (void)configureImage:(UIImage *)image {
    [ImageHelper configureImageView:self.imageView image:image];
}

- (CGSize)imageSize {
    return self.imageView.frame.size;
}

@end
