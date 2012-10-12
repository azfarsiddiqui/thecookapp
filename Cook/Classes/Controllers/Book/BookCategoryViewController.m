//
//  BookCategoryViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 10/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCategoryViewController.h"

@interface BookCategoryViewController ()

@end

@implementation BookCategoryViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self initScreen];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

-(void)initScreen
{
    self.view.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
}
@end
