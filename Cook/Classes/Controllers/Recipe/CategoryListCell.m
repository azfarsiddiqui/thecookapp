//
//  CategoryListCell.m
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryListCell.h"


@interface CategoryListCell ()
@property (strong, nonatomic) IBOutlet UILabel *categoryNameLabel;
@end

@implementation CategoryListCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // change to our custom selected background view
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.backgroundColor = [UIColor redColor];
        self.selectedBackgroundView = backgroundView;
    }
    return self;
}

-(void)configure:(Category*)category;
{
    self.categoryNameLabel.text = category.name;
    self.selectedBackgroundView.backgroundColor = [UIColor redColor];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.categoryNameLabel.text = nil;
}

@end
