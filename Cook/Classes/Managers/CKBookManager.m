//
//  CKBookManager.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBookManager.h"
#import "CKBook.h"
#import "CKRecipe.h"
#import "CKSocialManager.h"
#import "MRCEnumerable.h"
#import <Parse/Parse.h>

@interface CKBookManager ()

@property (nonatomic, strong) CKBook *myBook;
@property (nonatomic, strong) NSMutableDictionary *bookContents;

@end

@implementation CKBookManager

#define kRecipes            @"recipes"
#define kPages              @"pages"
#define kPageRecipes        @"pageRecipes"
#define kPagesWithUpdates   @"pagesWithUpdates"
#define kLikesPageName      @"likesPageName"
#define kPageFeaturedRecipe @"pageFeaturedRecipe"
#define kFeaturedRecipe     @"featuredRecipe"

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static CKBookManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CKBookManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.bookContents = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Hang on to my book.

- (CKBook *)myCurrentBook {
    return self.myBook;
}

- (void)holdMyCurrentBook:(CKBook *)book {
    self.myBook = book;
}

#pragma mark - TODO Complete loading/processing of recipes for a book.

- (void)recipesForBook:(CKBook *)book success:(BookManagerRecipesSuccessBlock)success
               failure:(BookManagerRecipesFailureBlock)failure {
    
    // Fetch all recipes for the book, and categorise them.
    [book bookRecipesSuccess:^(PFObject *parseBook, NSArray *recipes, NSArray *likedRecipes, NSArray *recipePins,
                               NSDate *lastAccessedDate) {
        
        CKBook *refreshedBook = [CKBook bookWithParseObject:parseBook];
        [self processRecipes:recipes likedRecipes:likedRecipes lastAccessedDate:lastAccessedDate book:refreshedBook];
        
        success(refreshedBook);
        
    } failure:^(NSError *error) {
        DLog(@"Error %@", [error localizedDescription]);
        failure(error);
    }];
}

- (void)updateWithRecipe:(CKRecipe *)recipe completion:(void (^)())completion {
    
}

- (void)updateWithDeletedRecipe:(CKRecipe *)recipe completion:(void (^)())completion {
    
}

- (void)updateWithPage:(NSString *)page completion:(void (^)())completion {
    
}

- (void)updateWithRenamedPage:(NSString *)page fromPage:(NSString *)fromPage completion:(void (^)())completion {
    
}

- (CKRecipe *)featuredRecipeForBook:(CKBook *)book {
    return nil;
}

- (CKRecipe *)featuredRecipeForPage:(NSString *)page {
    return nil;
}

- (NSArray *)recipesForPage:(NSString *)page book:(CKBook *)book {
    return nil;
}

- (NSArray *)pagesForBook:(CKBook *)book {
    return [[self contentsForBook:book] objectForKey:kPages];
}

- (void)clearBook:(CKBook *)book {
    [self.bookContents removeObjectForKey:book.objectId];
}

- (BOOL)hasUpdatedRecipesForPage:(NSString *)page book:(CKBook *)book {
    if ([book isOwner]) {
        return NO;
    } else {
        NSDictionary *pagesContainingUpdatedRecipes = [[self contentsForBook:book] objectForKey:kPagesWithUpdates];
        return ([pagesContainingUpdatedRecipes objectForKey:page] != nil);
    }
}

- (BOOL)hasLikesForBook:(CKBook *)book {
    NSString *likesPageName = [[self contentsForBook:book] objectForKey:kLikesPageName];
    return ([likesPageName length] > 0);
}

#pragma mark - Private methods

- (void)processRecipes:(NSArray *)recipes likedRecipes:(NSArray *)likedRecipes
      lastAccessedDate:(NSDate *)lastAccessedDate book:(CKBook *)book {
    
    // Reset social manager.
    [[CKSocialManager sharedInstance] reset];
    
    // Model structures
    NSMutableArray *bookPages = [NSMutableArray arrayWithArray:book.pages];
    NSMutableDictionary *bookPageRecipes = [NSMutableDictionary dictionary];
    NSMutableDictionary *bookPageContainingUpdatedRecipes = [NSMutableDictionary dictionary];
    
    // Loop through and gather recipes for each page.
    for (CKRecipe *recipe in recipes) {
        
        NSString *page = recipe.page;
        
        // Collect recipes into their corresponding pages.
        NSMutableArray *pageRecipes = [bookPageRecipes objectForKey:page];
        if (!pageRecipes) {
            pageRecipes = [NSMutableArray array];
            [bookPageRecipes setObject:pageRecipes forKey:page];
        }
        [pageRecipes addObject:recipe];
        
        // Update social cache.
        [[CKSocialManager sharedInstance] configureRecipe:recipe];
        
        // Is this a new recipe?
        if (lastAccessedDate
            && ([recipe.modelUpdatedDateTime compare:lastAccessedDate] == NSOrderedDescending)) {
            
            // Mark the page as new.
            [bookPageContainingUpdatedRecipes setObject:@YES forKey:page];
        }
    }
    
    // Add likes if we have at least one page.
    NSString *likesPageName = [self resolveLikesPageNameForBook:book];
    if ([book isOwner] && [book.pages count] > 0) {
        likesPageName = [self resolveLikesPageNameForBook:book];
        [bookPages addObject:likesPageName];
        [bookPageRecipes setObject:likedRecipes forKey:likesPageName];
    }
    
    // Update model
    [[self contentsForBook:book] setObject:recipes forKey:kRecipes];
    [[self contentsForBook:book] setObject:bookPages forKey:kPages];
    [[self contentsForBook:book] setObject:bookPageRecipes forKey:kPageRecipes];
    [[self contentsForBook:book] setObject:bookPageContainingUpdatedRecipes forKey:kPagesWithUpdates];
    [[self contentsForBook:book] setObject:likesPageName forKey:kLikesPageName];
    
    // Process rankings.
    [self processRanksForRecipes:recipes book:book];
}

- (void)processRanksForRecipes:(NSArray *)recipes book:(CKBook *)book {
    NSMutableDictionary *bookFeaturedRecipes = [NSMutableDictionary dictionary];
    NSDictionary *pageRecipes = [[self contentsForBook:book] objectForKey:kPageRecipes];
    
    // Gather the highest ranked recipes for each page.
    [pageRecipes each:^(NSString *page, NSArray *recipes) {
        
        if ([recipes count] > 0) {
            
            // Get the highest ranked recipe with photos, then fallback to without.
            CKRecipe *highestRankedRecipe = [self highestRankedRecipeForPage:page hasPhotos:YES book:book];
            if (!highestRankedRecipe) {
                highestRankedRecipe = [self highestRankedRecipeForPage:page hasPhotos:NO book:book];
            }
            [bookFeaturedRecipes setObject:highestRankedRecipe forKey:page];
        }
        
    }];
    
    // Get the highest ranked recipe among the highest ranked recipes.
    __block CKRecipe *bookFeaturedRecipe = nil;
    [bookFeaturedRecipes each:^(NSString *page, CKRecipe *recipe) {
        if (bookFeaturedRecipe) {
            if ([self rankForRecipe:recipe] > [self rankForRecipe:bookFeaturedRecipe]) {
                bookFeaturedRecipe = recipe;
            }
        } else {
            bookFeaturedRecipe = recipe;
        }
    }];
    
    // Update model
    [[self contentsForBook:book] setObject:bookFeaturedRecipes forKey:kPageFeaturedRecipe];
    [[self contentsForBook:book] setObject:bookFeaturedRecipe forKey:kFeaturedRecipe];
}

- (NSMutableDictionary *)contentsForBook:(CKBook *)book {
    NSMutableDictionary *contents = [self.bookContents objectForKey:book.objectId];
    if (contents == nil) {
        contents = [NSMutableDictionary dictionary];
        [self.bookContents setObject:contents forKey:book.objectId];
    }
    return contents;
}

- (NSString *)resolveLikesPageNameForBook:(CKBook *)book {
    NSString *resolvedLikePageName = nil;
    
    for (NSString *likePageName in [self potentialLikesPageNames]) {
        if (![book.pages containsObject:likePageName]) {
            resolvedLikePageName = likePageName;
            break;
        }
    }
    
    return resolvedLikePageName;
}

- (NSArray *)potentialLikesPageNames {
    return @[@"LIKES", @"LIKED", @"COOK LIKES", @"COOK LIKED"];
}

- (CKRecipe *)highestRankedRecipeForPage:(NSString *)page hasPhotos:(BOOL)hasPhotos book:(CKBook *)book {
    NSDictionary *pageRecipes = [[self contentsForBook:book] objectForKey:kPageRecipes];
    NSArray *recipes = [pageRecipes objectForKey:page];
    return [self highestRankedRecipeForRecipes:recipes hasPhotos:hasPhotos];
}

- (CKRecipe *)highestRankedRecipeForRecipes:(NSArray *)recipes hasPhotos:(BOOL)hasPhotos {
    if (hasPhotos) {
        recipes = [recipes select:^BOOL(CKRecipe *recipe) {
            return [recipe hasPhotos];
        }];
    }
    
    __block CKRecipe *highestRankedRecipe = nil;
    [recipes each:^(CKRecipe *recipe) {
        if (highestRankedRecipe) {
            if ([self rankForRecipe:recipe] > [self rankForRecipe:highestRankedRecipe]) {
                highestRankedRecipe = recipe;
            }
        } else {
            highestRankedRecipe = recipe;
        }
        
    }];
    return highestRankedRecipe;
}

- (CGFloat)rankForRecipe:(CKRecipe *)recipe {
    return recipe.numViews + recipe.numComments + (recipe.numLikes * 2.0);
}

@end
