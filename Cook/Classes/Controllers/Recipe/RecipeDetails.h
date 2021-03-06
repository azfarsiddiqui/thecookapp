//
//  RecipeDetails.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRecipe.h"

@class CKUser;
@class CKLocation;
@class CKBook;

@interface RecipeDetails : NSObject

@property (nonatomic, strong) CKRecipe *originalRecipe;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) CKLocation *location;
@property (nonatomic, copy) NSString *page;
@property (nonatomic, strong) NSArray *availablePages;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, copy) NSString *story;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, strong) NSNumber *numServes;
@property (nonatomic, strong) NSNumber *prepTimeInMinutes;
@property (nonatomic, strong) NSNumber *cookingTimeInMinutes;
@property (nonatomic, strong) NSArray *ingredients;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CKPrivacy privacy;
@property (nonatomic, strong) NSURL *userPhotoUrl;
@property (nonatomic, readonly) NSDate *createdDateTime;
@property (nonatomic, readonly) NSString *locale;
@property (nonatomic, assign) CKQuantityType quantityType;
@property (nonatomic, readonly) NSString *credits;

+ (NSInteger)maxPrepCookMinutes;
+ (NSInteger)maxServes;
+ (NSInteger)maxMakes;

- (id)initWithRecipe:(CKRecipe *)recipe;
- (id)initWithRecipe:(CKRecipe *)recipe book:(CKBook *)book;
- (void)updateToRecipe:(CKRecipe *)recipe;

- (BOOL)pageUpdated;
- (BOOL)nameUpdated;
- (BOOL)imageUpdated;
- (BOOL)tagsUpdated;
- (BOOL)storyUpdated;
- (BOOL)methodUpdated;
- (BOOL)servesPrepUpdated;
- (BOOL)ingredientsUpdated;
- (BOOL)locationUpdated;
- (BOOL)privacyUpdated;
- (BOOL)saveRequired;

- (BOOL)hasTitle;
- (BOOL)hasStory;
- (BOOL)hasMethod;
- (BOOL)hasCredits;
- (BOOL)hasServes;
- (BOOL)hasIngredients;

- (BOOL)isNew;

@end
