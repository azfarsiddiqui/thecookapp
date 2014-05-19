//
//  CKModel.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CKConstants.h"

typedef void(^ObjectFailureBlock)(NSError *error);
typedef void(^ObjectSuccessBlock)();
typedef void(^GetObjectSuccessBlock)(id object);
typedef void(^GetCachedObjectSuccessBlock)(id object, BOOL cached);
typedef void(^NumObjectSuccessBlock)(int numObjects);
typedef void(^BoolObjectSuccessBlock)(BOOL yesNo);
typedef void(^ListObjectsSuccessBlock)(NSArray *results);
typedef void(^DictionaryObjectsSuccessBlock)(NSDictionary *results);
typedef void(^ProgressBlock)(int percentDone);
typedef void(^PaginatedListSuccessBlock)(NSArray *items, NSUInteger numItems, NSUInteger batchIndex, NSUInteger numBatches);

#define kCKErrorDomain                  @"CKErrorDomain"
#define kCKLoginFailedErrorCode         210
#define kCKLoginCancelledErrorCode      211
#define kCKLoginFriendsErrorCode        212

@interface CKModel : NSObject

@property (nonatomic, strong) PFObject *parseObject;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, readonly) NSDate *createdDateTime;
@property (nonatomic, readonly) NSDate *updatedDateTime;
@property (nonatomic, readonly) NSDate *modelUpdatedDateTime;

+ (NSError *)errorWithMessage:(NSString *)errorMessage;
+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)errorMessage;
//default security - read/write by current user, read by public
+ (PFObject *)objectWithDefaultSecurityWithClassName:(NSString *)parseClassName;
+ (PFObject *)objectWithDefaultSecurityForUser:(PFUser *)parseUser className:(NSString *)parseClassName;
+ (instancetype)modelWithParseObject:(PFObject *)parseObject;

- (id)initWithParseObject:(PFObject *)parseObject;
- (void)saveEventually;
- (void)deleteEventually;
- (void)saveInBackground;
- (void)saveInBackground:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)deleteInBackground:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)fetchIfNeededCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (NSDictionary *)descriptionProperties;
- (BOOL)persisted;
- (BOOL)dataAvailable;

@end
