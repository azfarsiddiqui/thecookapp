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

- (NSString *)displayName
{
    NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0]; //Current user's language code
    //Grab dictionary of localised names and try to resolve with current language
    [self.parseObject fetchIfNeeded];
    NSString *localisedDictString = [self.parseObject objectForKey:kRecipeTagDisplayNames];
    if (!localisedDictString)
        return @"";
    NSData *stringData = [localisedDictString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:nil];
    
    //Grab localised string, otherwise, use EN ver
    NSString *localisedString = [JSON valueForKey:languageCode];
    if (!localisedString)
    {
        localisedString = [JSON valueForKey:DEFAULT_LANGUAGE];
    }
    return [localisedString uppercaseString];
}

- (NSInteger)categoryIndex {
    [self.parseObject fetchIfNeeded];
    NSNumber *categoryNumber = [self.parseObject objectForKey:kRecipeTagCategory];
    return [categoryNumber integerValue];
}

- (NSInteger)orderIndex {
    [self.parseObject fetchIfNeeded];
    NSNumber *categoryNumber = [self.parseObject objectForKey:kRecipeTagOrderIndex];
    return [categoryNumber integerValue];
}

- (NSString *)imageType {
    [self.parseObject fetchIfNeeded];
    NSString *imageType = [self.parseObject objectForKey:kRecipeTagImageType];
    if (!imageType)
        return @"";
    return imageType;
}

- (BOOL)isEqual:(CKRecipeTag *)object
{
    return [self.objectId isEqualToString:object.objectId];
}


@end
