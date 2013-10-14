//
//  CKRecipeTag.m
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipeTag.h"
#import "CKUser.h"
#import "CKConstants.h"

@implementation CKRecipeTag

#define DEFAULT_LANGUAGE @"en"

+ (void)tagListWithSuccess:(GetTagsSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    PFQuery *query = [PFQuery queryWithClassName:kRecipeTagModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    // TODO: Need to filter out region specific tags
    //[query whereKey:kUserModelForeignKeyName equalTo:objectID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSMutableArray *tagObjects = [NSMutableArray new];
            for (PFObject *parseTagObject in objects) {
                CKRecipeTag *recipeTag = [[CKRecipeTag alloc] initWithParseObject:parseTagObject];
                [tagObjects addObject:recipeTag];
            }
            success(tagObjects);
        }
        else
            failure(error);
    }];
}

- (NSString *)displayName
{
    NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0]; //Current user's language code
    //Grab dictionary of localised names and try to resolve with current language
    NSString *localisedDictString = [self.parseObject objectForKey:kRecipeTagDisplayNames];
    NSData *stringData = [localisedDictString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:nil];
    
    //Grab localised string, otherwise, use EN ver
    NSString *localisedString = [JSON valueForKey:languageCode];
    if (!localisedString)
    {
        localisedString = [JSON valueForKey:DEFAULT_LANGUAGE];
    }
    return localisedString;
}



@end
