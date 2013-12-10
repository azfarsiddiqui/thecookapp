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

@interface CKBookManager () 

@property (nonatomic, strong) CKBook *myBook;

@end

@implementation CKBookManager

#define kPopularRankingName     @"popular"
#define kLatestRankingName      @"latest"
#define kSupportedRankingNames  @[@"popular", @"latest"]

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
    }
    return self;
}

- (NSArray *)supportedRankingNames {
    return kSupportedRankingNames;
}

- (NSString *)defaultRankingName {
    return kPopularRankingName;
}

- (NSString *)resolveRankingNameForName:(NSString *)rankingName {
    
    if ([self isSupportedForRankingName:rankingName]) {
        
        return rankingName;
        
    } else {
        
        // Default popularity ranking algorithm.
        return kPopularRankingName;
    }
}

- (BOOL)isSupportedForRankingName:(NSString *)rankingName {
    return [[self supportedRankingNames] containsObject:[rankingName lowercaseString]];
}

- (CGFloat)rankingScoreForRecipe:(CKRecipe *)recipe {
    return [self rankingScoreForRecipe:recipe rankingName:kPopularRankingName];
}

- (CGFloat)rankingScoreForRecipe:(CKRecipe *)recipe rankingName:(NSString *)rankingName {
    CGFloat rankingScore = 0.0;
    
    if ([[rankingName lowercaseString] isEqualToString:kPopularRankingName]) {
        rankingScore = recipe.numViews + recipe.numComments + (recipe.numLikes * 2.0);
    } else if ([[rankingName lowercaseString] isEqualToString:kLatestRankingName]) {
        rankingScore = [recipe.recipeUpdatedDateTime timeIntervalSince1970];
    }
    
    return rankingScore;
}

#pragma mark - Hang on to my book.

- (CKBook *)myCurrentBook {
    return self.myBook;
}

- (void)holdMyCurrentBook:(CKBook *)book {
    self.myBook = book;
}

@end
