//
//  RecipeSocialViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeSocialViewController.h"
#import "CKRecipe.h"

@interface RecipeSocialViewController ()

@property (nonatomic, strong) CKRecipe *recipe;

@end

@implementation RecipeSocialViewController

- (id)initWithRecipe:(CKRecipe *)recipe {
    if (self = [super init]) {
        self.recipe = recipe;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0.0, 0.0, 640.0, 630.0);
}

@end
