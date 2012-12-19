//
//  ContentsPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ContentsPageViewController.h"
#import "ContentsCollectionViewController.h"
#import "UIFont+Cook.h"
#import "MRCEnumerable.h"
#import "CKRecipe.h"
#import "RecipeLike.h"
#import "NewRecipeViewController.h"
#import "ContentsTableViewCell.h"
#import "ContentsPhotoCell.h"
#import "ViewHelper.h"
#import "Theme.h"
#import "FacebookUserView.h"
#import "EventHelper.h"

@interface ContentsPageViewController () <UITableViewDataSource, UITableViewDelegate, NewRecipeViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) ContentsCollectionViewController *contentsCollectionViewController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, assign) BOOL currentUserIsBookAuthor;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) FacebookUserView *facebookView;
@end

@implementation ContentsPageViewController

#pragma mark - PageViewController methods

#define kNameYOffset    150.0
#define kContentSectionCellId @"ContentSectionCellId"

-(void)refreshData
{
    DLog();
    [self.tableView reloadData];
    [self.contentsCollectionViewController loadRecipes:[self.dataSource recipesInBook]];
    [self showPageNumberAndHideLoading];
}

- (void)initPageView {
    [self initCollectionView];
    [self initTitleView];
    [self initFacebookView];
    [self initTableView];
    [self initCreateButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DLog();
    [self hidePageNumberAndDisplayLoading];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource sectionsInPageContent];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContentSectionCellId forIndexPath:indexPath];

    
    NSString *sectionName = [self.dataSource sectionNameForPageContentAtIndex:indexPath.row];
    // Left item.
    cell.textLabel.font = [Theme defaultBoldFontWithSize:16.0];
    cell.textLabel.text = [sectionName uppercaseString];
    cell.textLabel.textColor = [Theme contentsItemColor];
    
    // Right page num.
    cell.detailTextLabel.font = [Theme defaultBoldFontWithSize:16.0];
    cell.detailTextLabel.textColor = [Theme defaultLabelColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [self.dataSource pageNumForSectionName:sectionName]];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *sectionName = [self.dataSource sectionNameForPageContentAtIndex:indexPath.row];
    NSUInteger requestedPageIndex = [self.dataSource pageNumForSectionName:sectionName];
    [self.delegate recipeWithIndexRequested:requestedPageIndex];
}

#pragma mark - NewRecipeViewDelegate methods

- (void)closeRequested {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recipeCreated {
    [self.delegate bookViewReloadRequested];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)initTitleView {
    
    CKBook *book = [self.dataSource currentBook];
    NSString *title = [book.name uppercaseString];
    UIFont *font = [Theme defaultFontWithSize:40.0];
    CGSize size = [title sizeWithFont:font constrainedToSize:self.view.bounds.size lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat xOffset = self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width;
    CGFloat availableWidth = self.view.bounds.size.width - xOffset;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + floorf((availableWidth - size.width) / 2.0),
                                                                   kNameYOffset,
                                                                   size.width,
                                                                   size.height)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = font;
    nameLabel.textColor = [Theme contentsTitleColor];
    nameLabel.shadowColor = [UIColor whiteColor];
    nameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    nameLabel.text = title;
    [self.view addSubview:nameLabel];
    self.nameLabel = nameLabel;
}

- (void)initFacebookView {
    CGFloat xOffset = self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width;
    CGFloat availableWidth = self.view.bounds.size.width - xOffset;
    FacebookUserView *facebookView = [[FacebookUserView alloc] initWithFrame:CGRectZero];
    [facebookView setUser:[[self.dataSource currentBook] user]];
    facebookView.frame = CGRectMake(xOffset + floorf((availableWidth - facebookView.frame.size.width) / 2.0) - 20.0,
                                    self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height,
                                    facebookView.frame.size.width,
                                    facebookView.frame.size.height);
    [self.view addSubview:facebookView];
    self.facebookView = facebookView;
}

- (void)initTableView {
    CGFloat xOffset = self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width;
    UIEdgeInsets tableInsets = UIEdgeInsetsMake(20.0, 150.0, 50.0, 100.0);
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(xOffset + tableInsets.left,
                                                                           self.facebookView.frame.origin.y + self.facebookView.frame.size.height + tableInsets.top,
                                                                           350.0,
                                                                           self.view.bounds.size.height - tableInsets.top - tableInsets.bottom)
                                                           style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.autoresizingMask = UIViewAutoresizingNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self.tableView registerClass:[ContentsTableViewCell class] forCellReuseIdentifier:kContentSectionCellId];
    
}

- (void)initCollectionView {
    ContentsCollectionViewController *collectionViewController  = [[ContentsCollectionViewController alloc] init];
    collectionViewController.view.frame = CGRectMake(0.0,
                                                     0.0,
                                                     collectionViewController.view.frame.size.width,
                                                     self.view.bounds.size.height);
    collectionViewController.bookViewDataSource = self.dataSource;
    collectionViewController.bookViewDelegate = self.delegate;
    [self.view addSubview:collectionViewController.view];
    self.contentsCollectionViewController = collectionViewController;
}

- (void)initCreateButton {
    
    
    
    UIButton *createButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_addbook.png"]
                                                  target:self selector:@selector(createTapped:)];
    [createButton setFrame:CGRectMake(self.contentsCollectionViewController.view.frame.origin.x + self.contentsCollectionViewController.view.frame.size.width - floorf(createButton.frame.size.width / 2.0),
                                      self.contentsCollectionViewController.view.frame.origin.y + floorf(([ContentsPhotoCell midSize].height - createButton.frame.size.width) / 2.0),
                                      createButton.frame.size.width, createButton.frame.size.height)];
    createButton.hidden = YES;
    
    [self.view addSubview:createButton];
    
    CKBook *book = [self.dataSource currentBook];
    self.currentUserIsBookAuthor = [book isUserBookAuthor:[CKUser currentUser]];
    createButton.hidden = !self.currentUserIsBookAuthor;
    
    if (!self.currentUserIsBookAuthor) {
        [book isFollowedByUser:[CKUser currentUser] success:^(BOOL boolean) {
            createButton.hidden = boolean;
        } failure:^(NSError *error) {
            DLog(@"could not confirm current user follows this book. %@", [error description]);
        }];
    }

    self.createButton = createButton;
}

- (void)createTapped:(id)sender {
    
    if (self.currentUserIsBookAuthor) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Cook" bundle:nil];
        NewRecipeViewController *newRecipeViewVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NewRecipeViewController"];
        newRecipeViewVC.recipeViewDelegate = self;
        newRecipeViewVC.book = [self.dataSource currentBook];
        [self presentViewController:newRecipeViewVC animated:YES completion:nil];
    } else {
        CKBook *book = [self.dataSource currentBook];
        BOOL isThisMyFriendsBook = [book isThisMyFriendsBook];
        [book addFollower:[CKUser currentUser]
                  success:^{
                      [EventHelper postFollow:YES friends:isThisMyFriendsBook];
                      UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Book was added to Dashboard" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                      [alertView show];
                  } failure:^(NSError *error) {
                      DLog(@"Unable to follow.");
                  }];
    }

}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog();
    if ([alertView.message isEqualToString:@"Book was added to Dashboard"]) {
        self.createButton.hidden = YES;
    }
}

@end
