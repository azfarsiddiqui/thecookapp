//
//  BookNavigationHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 6/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKRecipe;
@class BookNavigationViewController;
@class BookNavigationStackViewController;

typedef void(^BookNavigationUpdatedBlock)();

@interface BookNavigationHelper : NSObject

//@property (nonatomic, strong) BookNavigationViewController *bookNavigationViewController;
@property (nonatomic, strong) BookNavigationViewController *bookNavigationViewController;

+ (BookNavigationHelper *)sharedInstance;

- (void)updateBookNavigationWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion;

@end
