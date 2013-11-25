//
//  CKBookManager.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKBook;
@class CKRecipe;

typedef void(^BookManagerRecipesSuccessBlock)(CKBook *book);
typedef void(^BookManagerRecipesFailureBlock)(NSError *error);

@interface CKBookManager : NSObject

+ (instancetype)sharedInstance;

// Hang onto my book references.
- (CKBook *)myCurrentBook;
- (void)holdMyCurrentBook:(CKBook *)book;

// To handle loading/processing of recipes within a book.
- (void)updateWithRecipe:(CKRecipe *)recipe completion:(void (^)())completion;
- (void)updateWithDeletedRecipe:(CKRecipe *)recipe completion:(void (^)())completion;
- (void)updateWithPage:(NSString *)page completion:(void (^)())completion;
- (void)updateWithRenamedPage:(NSString *)page fromPage:(NSString *)fromPage completion:(void (^)())completion;

- (CKRecipe *)featuredRecipeForBook:(CKBook *)book;
- (CKRecipe *)featuredRecipeForPage:(NSString *)page;
- (NSArray *)recipesForPage:(NSString *)page book:(CKBook *)book;
- (NSArray *)pagesForBook:(CKBook *)book;
- (BOOL)hasUpdatedRecipesForPage:(NSString *)page book:(CKBook *)book;
- (BOOL)hasLikesForBook:(CKBook *)book;

- (void)clearBook:(CKBook *)book;

@end
