//
//  CKSocialManager.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKRecipe;

@interface CKSocialManager : NSObject

+ (CKSocialManager *)sharedInstance;
- (void)reset;
- (void)configureRecipe:(CKRecipe *)recipe;
- (void)updateRecipe:(CKRecipe *)recipe numComments:(NSUInteger)numComments;
- (void)updateRecipe:(CKRecipe *)recipe numLikes:(NSUInteger)numLikes;
- (void)like:(BOOL)like recipe:(CKRecipe *)recipe;
- (NSUInteger)numCommentsForRecipe:(CKRecipe *)recipe;
- (NSUInteger)numLikesForRecipe:(CKRecipe *)recipe;

@end
