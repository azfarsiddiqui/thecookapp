//
//  CKError.m
//  Cook
//
//  Created by Jeff Tan-Ang on 28/02/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKError.h"
#import "CKConstants.h"

@implementation CKError

+ (BOOL)noConnectionError:(NSError *)error {
    return ([error.domain isEqualToString:@"Parse"] && error.code == 100);
}

+ (BOOL)bookPageRenameBlockedError:(NSError *)error {
    return ([self cookErrorCodeForError:error] == kCookCloudPageRenameBlockErrorCode);
}

#pragma mark - Private methods

+ (NSInteger)cookErrorCodeForError:(NSError *)error {
    return [[[self cookErrorInfoForError:error] objectForKey:kCookCloudCodeKey] integerValue];
}

+ (NSDictionary *)cookErrorInfoForError:(NSError *)error {
    NSString *errorJSON = [[error userInfo] objectForKey:@"error"];
    NSDictionary *errorInfo = nil;
    
    if ([errorJSON length] > 0) {
        NSError *error = nil;
        errorInfo = [NSJSONSerialization JSONObjectWithData:[errorJSON dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:NSJSONReadingMutableContainers
                                                      error:&error];
    }
    
    return errorInfo;
}

@end
