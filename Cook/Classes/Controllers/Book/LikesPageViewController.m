//
//  LikesPageViewController.m
//  Cook
//
//  Created by Jonny Sagorin on 12/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "LikesPageViewController.h"
#import "CKRecipeLike.h"

@interface LikesPageViewController ()

@end

@implementation LikesPageViewController

//overridden
-(void)setSectionName:(NSString *)sectionName
{
    [super setSectionName:sectionName];
    [CKRecipeLike fetchLikedRecipesForUser:[CKUser currentUser] withSuccess:^(NSArray *results) {
        self.recipes = results;
        [self.delegate didLoadLikedUserRecipes:results];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        DLog(@"could not fetch user's liked recipes: %@", error);
    }];
}

@end
