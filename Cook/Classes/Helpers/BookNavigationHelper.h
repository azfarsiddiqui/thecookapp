//
//  BookNavigationHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 6/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKRecipe;
@class CKRecipePin;
@class BookNavigationViewController;

typedef void(^BookNavigationUpdatedBlock)();

@interface BookNavigationHelper : NSObject

@property (nonatomic, strong) BookNavigationViewController *bookNavigationViewController;

+ (BookNavigationHelper *)sharedInstance;

- (void)updateBookNavigationWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion;
- (void)updateBookNavigationWithDeletedRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion;
- (void)updateBookNavigationWithUnpinnedRecipe:(CKRecipePin *)recipePin completion:(BookNavigationUpdatedBlock)completion;
- (void)updateBookNavigationWithPinnedRecipe:(CKRecipePin *)recipePin completion:(BookNavigationUpdatedBlock)completion;
- (void)updateBookNavigationWithDeletedPage:(NSString *)page completion:(BookNavigationUpdatedBlock)completion;
- (void)updateBookNavigationWithRenamedPage:(NSString *)page fromPage:(NSString *)fromPage completion:(BookNavigationUpdatedBlock)completion;

@end
