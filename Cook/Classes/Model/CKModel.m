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

+ (PFObject *)objectWithDefaultSecurityWithClassName:(NSString *)parseClassName {
    return [self objectWithDefaultSecurityForUser:[PFUser currentUser] className:parseClassName];
}

+ (PFObject *)objectWithDefaultSecurityForUser:(PFUser *)parseUser className:(NSString *)parseClassName {
    PFObject *pfObject = [PFObject objectWithClassName:parseClassName];
    PFACL *objectACL = [PFACL ACLWithUser:parseUser];
    [objectACL setPublicReadAccess:YES];
    pfObject.ACL = objectACL;
    return pfObject;
}

- (id)initWithParseObject:(PFObject *)parseObject {
    if (self = [super init]) {
        self.parseObject = parseObject;
    }
    return self;
}

- (void)saveEventually {
    [self.parseObject saveEventually];
}

- (void)deleteEventually {
    [self.parseObject deleteEventually];
}

- (void)saveInBackground {
    [self saveInBackground:^{
        // Ignore success.
    } failure:^(NSError *error) {
        DLog(@"Error: %@", error);
        [self saveEventually];
    }];
}

- (void)saveInBackground:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    [self.parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            success();
        } else {
            failure(error);
        }
    }];
}

- (void)deleteInBackground:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    [self.parseObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            success();
        } else {
            failure(error);
        }
    }];
}

- (void)fetchIfNeededCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    if (![self.parseObject isDataAvailable]) {
        [self.parseObject fetchIfNeededInBackgroundWithBlock:^(PFObject *parseObject, NSError *error) {
            
            if (!error) {
                self.parseObject = parseObject;
                success();
            } else {
                failure(error);
            }
        }];
        
    } else {
        success();
    }
}

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionary];
    [descriptionProperties setValue:[NSString CK_safeString:self.parseObject.objectId] forKey:@"objectId"];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:[self persisted]] forKey:@"persisted"];
    if ([self.parseObject isDataAvailable]) {
        [descriptionProperties setValue:[NSString CK_safeString:self.name] forKey:@"name"];
    } else {
        [descriptionProperties setValue:[NSString CK_stringForBoolean:NO] forKey:@"dataAvailable"];
    }
    return descriptionProperties;
}

- (BOOL)persisted {
    return (self.parseObject.objectId != nil && [self.parseObject.objectId length] > 0);
}

- (BOOL)dataAvailable {
    return [self.parseObject isDataAvailable];
}

- (NSDate *)createdDateTime {
     return self.parseObject.createdAt;
}

- (NSDate *)updatedDateTime {
    return self.parseObject.updatedAt;
}

- (NSDate *)modelUpdatedDateTime {
    return [self.parseObject objectForKey:kModelAttrModelUpdatedAt];
}

#pragma mark - Wrapper getters/setters

- (void)setName:(NSString *)name {
    [self.parseObject setObject:[NSString CK_safeString:name] forKey:kModelAttrName];
}

- (NSString *)name {
    return [self.parseObject objectForKey:kModelAttrName];
}

- (NSString *)objectId {
    return self.parseObject.objectId;
}

#pragma mark - NSObject

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@:", NSStringFromClass([self class])];
    NSDictionary *descriptionProperties = [self descriptionProperties];
    NSArray *orderedKeys = [[descriptionProperties allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *key in orderedKeys) {
        [description appendFormat:@" %@[%@]", key, [descriptionProperties valueForKey:key]];
    }
    [description appendString:@">"];
    return description;
}

@end
