//
//  CKCategory.m
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKCategory.h"
#import "NSArray+Enumerable.h"
#import "NSString+Utilities.h"

@implementation CKCategory


+(CKCategory *)categoryForParseCategory:(PFObject *)parseCategory {
    CKCategory *category = [[CKCategory alloc] initWithParseObject:parseCategory];
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
                return [CKCategory categoryForParseCategory:parseCategory];
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
    return [CKCategory bookImageForCategory:self.name];
}

-(BOOL)isDataAvailable
{
    return [self.parseObject isDataAvailable];
}

- (void)setOrder:(NSNumber *)order {
    [self.parseObject setObject:order forKey:kCategoryAttrOrder];
}

- (NSNumber *)order {
    return [self.parseObject objectForKey:kCategoryAttrOrder];
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self.order integerValue]] forKey:kCategoryAttrOrder];
    return descriptionProperties;
}

@end
