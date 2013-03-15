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
    [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
    [query orderByAscending:kModelAttrName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *categoryList, NSError *error) {
        if (!error) {
            NSArray *categories = [categoryList collect:^id(PFObject *parseCategory) {
                return [Category categoryForParseCategory:parseCategory];
            }];
            success(categories);
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

-(BOOL)isDataAvailable
{
    return [self.parseObject isDataAvailable];
}

@end
