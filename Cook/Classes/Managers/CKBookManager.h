//
//  CKBookManager.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKBook;

@interface CKBookManager : NSObject

+ (instancetype)sharedInstance;

// Hang onto my book references.
- (CKBook *)myCurrentBook;
- (void)holdMyCurrentBook:(CKBook *)book;

@end
