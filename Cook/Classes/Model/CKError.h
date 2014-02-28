//
//  CKError.h
//  Cook
//
//  Created by Jeff Tan-Ang on 28/02/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKError : NSObject

+ (BOOL)noConnectionError:(NSError *)error;
+ (BOOL)bookPageRenameBlockedError:(NSError *)error;

@end
