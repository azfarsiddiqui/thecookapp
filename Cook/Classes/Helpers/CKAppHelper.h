//
//  CKAppHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKAppHelper : NSObject

+ (CKAppHelper *)sharedInstance;

- (BOOL)newInstall;

@end
