//
//  CategoryPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryPageViewController.h"

@interface CategoryPageViewController ()

@end

@implementation CategoryPageViewController

- (void)loadData {
}

- (void)initPageView {
    
    NSString *title = [self.dataSource bookViewCurrentCategory];
    UIFont *font = [UIFont boldSystemFontOfSize:20.0];
    CGSize size = [title sizeWithFont:font constrainedToSize:self.view.bounds.size lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                                                                       floorf((self.view.bounds.size.height - size.height) / 2.0),
                                                                       size.width,
                                                                       size.height)];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.font = font;
    categoryLabel.textColor = [UIColor blackColor];
    categoryLabel.shadowColor = [UIColor whiteColor];
    categoryLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    categoryLabel.text = title;
    [self.view addSubview:categoryLabel];
}

@end
