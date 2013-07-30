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
#import "CKBook.h"

@implementation CKCategory

+ (CKCategory *)categoryForName:(NSString *)name book:(CKBook *)book {
    return [self categoryForName:name order:0 book:book];
}

+ (CKCategory *)categoryForName:(NSString *)name order:(NSInteger)order book:(CKBook *)book {
    PFObject *parseObject = [PFObject objectWithClassName:kCategoryModelName];
    CKCategory *category = [self categoryForParseCategory:parseObject];
    category.order = [NSNumber numberWithInteger:order];
    category.name = name;
    category.book = book;
    return category;
}

+ (CKCategory *)categoryForParseCategory:(PFObject *)parseCategory {
    CKCategory *category = [[CKCategory alloc] initWithParseObject:parseCategory];
    return category;
}

+ (void)listCategories:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
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

- (BOOL)isDataAvailable {
    return [self.parseObject isDataAvailable];
}

#pragma mark - Properties

- (void)setOrder:(NSNumber *)order {
    [self.parseObject setObject:order forKey:kCategoryAttrOrder];
}

- (NSNumber *)order {
    return [self.parseObject objectForKey:kCategoryAttrOrder];
}

- (void)setBook:(CKBook *)book {
    [self.parseObject setObject:book.parseObject forKey:kBookModelForeignKeyName];
}

- (CKBook *)book {
    return [self.parseObject objectForKey:kBookModelForeignKeyName];
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self.order integerValue]] forKey:kCategoryAttrOrder];
    return descriptionProperties;
}

@end
