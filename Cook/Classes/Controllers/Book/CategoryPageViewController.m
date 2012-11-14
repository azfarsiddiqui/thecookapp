//
//  CategoryPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryPageViewController.h"
#import "Category.h"

@interface CategoryPageViewController ()

@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIImageView *categoryImageView;

@end

@implementation CategoryPageViewController

#define kCategoryFont   [UIFont boldSystemFontOfSize:30.0]

- (void)initPageView {
    UIImageView *categoryImageView = [[UIImageView alloc] initWithImage:nil];
    categoryImageView.frame = self.view.bounds;
    [self.view addSubview:categoryImageView];
    self.categoryImageView = categoryImageView;
}

- (void)loadData {
    [super loadData];
    [self dataDidLoad];
}

- (void)setCategory:(NSString *)category {
    
    // Update category image.
    self.categoryImageView.image = [Category bookImageForCategory:category];
    
    NSString *categoryDisplay = [NSString stringWithFormat:@"Category: %@", category];
    
    if (!self.categoryLabel) {
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.font = kCategoryFont;
        categoryLabel.textColor = [UIColor blackColor];
        categoryLabel.shadowColor = [UIColor whiteColor];
        categoryLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [self.view addSubview:categoryLabel];
        self.categoryLabel = categoryLabel;
    }
    
    CGSize size = [categoryDisplay sizeWithFont:kCategoryFont constrainedToSize:self.view.bounds.size
                                  lineBreakMode:NSLineBreakByTruncatingTail];
    self.categoryLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                          floorf((self.view.bounds.size.height - size.height) / 2.0),
                                          size.width,
                                          size.height);
    self.categoryLabel.text = categoryDisplay;
}

@end
