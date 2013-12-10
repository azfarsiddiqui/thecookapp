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

@interface CKBookManager : NSObject

@property (nonatomic, strong) NSArray *tagArray;

+ (instancetype)sharedInstance;

// Rankings.
- (NSArray *)supportedRankingNames;
- (NSString *)defaultRankingName;
- (BOOL)isSupportedForRankingName:(NSString *)rankingName;
- (CGFloat)rankingScoreForRecipe:(CKRecipe *)recipe;
- (CGFloat)rankingScoreForRecipe:(CKRecipe *)recipe rankingName:(NSString *)rankingName;

// Hang onto my book references.
- (CKBook *)myCurrentBook;
- (void)holdMyCurrentBook:(CKBook *)book;

@end
