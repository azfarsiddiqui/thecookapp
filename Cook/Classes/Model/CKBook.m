//
//  CKBook.m
//  Cook
//
//  Created by Jeff Tan-Ang on 2/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBook.h"
#import "NSString+Utilities.h"

@interface CKBook ()

+ (CKBook *)createBookIfRequiredForParseBook:(PFObject *)parseBook user:(CKUser *)user;

@end

@implementation CKBook

+ (void)bookForUser:(CKUser *)user success:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kCKBookModelName];
    
    // Get local cache first before getting updated with networked version.
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query whereKey:kCKUserKey equalTo:user.parseObject];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *parseBook, NSError *error) {
        if (!error) {
            success([CKBook createBookIfRequiredForParseBook:parseBook user:user]);
        } else {
            failure(error);
        }
    }];

}

+ (PFObject *)parseBookForParseUser:(PFUser *)parseUser {
    PFObject *parseBook = [PFObject objectWithClassName:kCKBookModelName];
    [parseBook setObject:kCKBookDefaultName forKey:kCKModelNameKey];
    [parseBook setObject:parseUser forKey:kCKUserKey];
    return parseBook;
}

- (id)initWithParseBook:(PFObject *)parseBook user:(CKUser *)user {
    if (self = [super initWithParseObject:parseBook]) {
        self.user = user;
    }
    return self;
}

- (void)setCoverPhotoName:(NSString *)coverPhotoName {
    [self.parseObject setObject:coverPhotoName forKey:kCKBookCoverPhotoNameKey];
}

- (NSString *)coverPhotoName {
    return [self.parseObject objectForKey:kCKBookCoverPhotoNameKey];
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:self.coverPhotoName] forKey:@"coverPhotoName"];
    return descriptionProperties;
}

#pragma mark - Private methods

+ (CKBook *)createBookIfRequiredForParseBook:(PFObject *)parseBook user:(CKUser *)user {
    if (!parseBook) {
        parseBook = [CKBook parseBookForParseUser:(PFUser *)user.parseObject];
    }
    return [[CKBook alloc] initWithParseBook:parseBook user:user];
}

@end
