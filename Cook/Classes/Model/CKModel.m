//
//  CKModel.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@interface CKModel ()

@end

@implementation CKModel

- (id)initWithParseObject:(PFObject *)parseObject {
    if (self = [super init]) {
        self.parseObject = parseObject;
    }
    return self;
}

- (void)setName:(NSString *)name {
    [self.parseObject setObject:name forKey:kCKModelNameKey];
}

- (NSString *)name {
    return [self.parseObject objectForKey:kCKModelNameKey];
}

- (void)saveEventually {
    [self.parseObject saveEventually];
}

@end
