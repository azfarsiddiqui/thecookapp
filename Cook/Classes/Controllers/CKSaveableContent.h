//
//  CKSaveableContent.h
//  Cook
//
//  Created by Jeff Tan-Ang on 31/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKSaveableContent <NSObject>

- (BOOL)contentSaveRequired;
- (void)contentPerformSave:(BOOL)save;

@end
