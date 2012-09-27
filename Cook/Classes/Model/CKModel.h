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
typedef void(^NumObjectSuccessBlock)(int numObjects);
typedef void(^ListObjectsSuccessBlock)(NSArray *results);
typedef void(^ProgressBlock)(int percentDone);

@interface CKModel : NSObject

@property (nonatomic, strong) PFObject *parseObject;
@property (nonatomic, copy) NSString *name;

- (id)initWithParseObject:(PFObject *)parseObject;
- (void)saveEventually;

@end
