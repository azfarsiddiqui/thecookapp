//
//  BookProfilePageViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 11/21/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookProfilePageViewController.h"

@interface BookProfilePageViewController ()
@property(nonatomic,strong) IBOutlet UILabel *userNameLabel;
@property(nonatomic,strong) IBOutlet UILabel *bookNameLabel;
@end

@implementation BookProfilePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData];
}

#pragma mark - overridden methods
-(NSArray *)pageOptionIcons
{
    return [[self.dataSource currentBook] isUserBookAuthor:[CKUser currentUser]] ? @[@"cook_book_icon_editpage.png"] : nil;
}

-(NSArray *)pageOptionLabels
{
    return [[self.dataSource currentBook] isUserBookAuthor:[CKUser currentUser]] ? @[@"EDIT"] : nil;
}

-(void)didSelectCustomOptionAtIndex:(NSInteger)optionIndex
{
    if (optionIndex == 0) {
        DLog("EDIT");
    }
}
#pragma mark - Private methods

-(void) refreshData
{
    self.userNameLabel.text = [[self.dataSource currentBook] user].name;
    self.bookNameLabel.text = [[self.dataSource currentBook].name uppercaseString];
}
@end
