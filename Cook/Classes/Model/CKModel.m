//
//  CKModel.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"
#import "NSString+Utilities.h"

@interface CKModel ()

@end

@implementation CKModel

+ (NSError *)errorWithMessage:(NSString *)errorMessage {
    return [self errorWithCode:0 message:errorMessage];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)errorMessage {
    return [NSError errorWithDomain:kCKErrorDomain
                               code:0
                           userInfo:[NSDictionary dictionaryWithObject:errorMessage
                                                                forKey:NSLocalizedDescriptionKey]];
}

- (id)initWithParseObject:(PFObject *)parseObject {
    if (self = [super init]) {
        self.parseObject = parseObject;
    }
    return self;
}

- (void)setName:(NSString *)name {
    [self.parseObject setObject:name forKey:kModelAttrName];
}

- (NSString *)name {
    return [self.parseObject objectForKey:kModelAttrName];
}

- (void)saveEventually {
    [self.parseObject saveEventually];
}

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionary];
    [descriptionProperties setValue:[NSString CK_safeString:self.parseObject.objectId] forKey:@"objectId"];
    [descriptionProperties setValue:[NSString CK_safeString:self.name] forKey:@"name"];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:[self persisted]] forKey:@"persisted"];
    return descriptionProperties;
}

- (BOOL)persisted {
    return (self.parseObject.objectId != nil && [self.parseObject.objectId length] > 0);
}

#pragma mark - NSObject

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@:", NSStringFromClass([self class])];
    NSDictionary *descriptionProperties = [self descriptionProperties];
    NSArray *orderedKeys = [descriptionProperties keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2];
    }];
    for (NSString *key in orderedKeys) {
        [description appendFormat:@" %@[%@]", key, [descriptionProperties valueForKey:key]];
    }
    [description appendString:@">"];
    return description;
}

@end
