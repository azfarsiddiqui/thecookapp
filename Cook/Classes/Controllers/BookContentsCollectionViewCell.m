//
//  BookHomeResusableView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentsCollectionViewCell.h"
#import "BookHomeViewController.h"

@interface BookContentsCollectionViewCell ()

@property (nonatomic, strong) BookHomeViewController *homeViewController;

@end

@implementation BookContentsCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)configureBook:(CKBook *)book {
    [self.homeViewController.view removeFromSuperview];
    
    BookHomeViewController *homeViewController = [[BookHomeViewController alloc] initWithBook:book];
    homeViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:homeViewController.view];
    self.homeViewController = homeViewController;
    
}

@end
