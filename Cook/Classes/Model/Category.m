//
//  CKCategory.m
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "Category.h"
#import "NSArray+Enumerable.h"

@implementation Category


+(Category *)categoryForParseCategory:(PFObject *)parseCategory {
    Category *category = [[Category alloc] initWithParseObject:parseCategory];
    return category;
}

+(void)listCategories:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    PFQuery *query = [PFQuery queryWithClassName:kCategoryModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query orderByAscending:kModelAttrName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *categoryList, NSError *error) {
        if (!error) {
            if ([categoryList count] == 0) {
                //no categories. populate with data
                DLog(@"No categories. populating with seed data");
                [Category seedData];
                [self listCategories:success failure:failure];
            } else {
                NSLog(@"Found %i categories.", [categoryList count]);
                NSArray *categories = [categoryList collect:^id(PFObject *parseCategory) {
                    return [Category categoryForParseCategory:parseCategory];
                }];
                success(categories);
            }
        } else {
            failure(error);
        }
    }];

}

+ (UIImage *)bookImageForCategory:(NSString *)category {
    return [UIImage imageNamed:[NSString stringWithFormat:@"cook_category_%@.png",
                                [[category stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString]]];
}

- (UIImage *)bookImage {
    return [Category bookImageForCategory:self.name];
}

#pragma mark - Category population. Populate once only

+(void)seedData
{
    NSArray *seedData = @[@"Meat", @"Chicken", @"Fish", @"Vegetarian", @"Snacks and Sides", @"Soup", @"Pasta", @"Baking", @"Dessert", @"Drinks",
    @"Quick and Easy", @"Allergy Free", @"Kid-friendly", @"Healthy", @"Comfort", @"Festive"];
    
    for (NSString *categoryName in seedData) {
        PFObject *parseCategoryObject = [PFObject objectWithClassName:kCategoryModelName];
        [parseCategoryObject setObject:categoryName forKey:kModelAttrName];
        [parseCategoryObject save];
    }
    
    DLog(@"seeding category data completed.");
}
@end
