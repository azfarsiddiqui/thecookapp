//
//  CKTodayRecipe.h
//  Cook
//
//  Created by Gerald on 24/09/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^GetObjectSuccessBlock)(id object);
typedef void(^ObjectFailureBlock)(NSError *error);

@class PFFile;

@interface CKTodayRecipe : NSObject

@property (nonatomic, strong) NSString *profilePicUrl;
@property (nonatomic, strong) PFFile *recipePic;
@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSString *recipeName;
@property (nonatomic, strong) NSDate *recipeUpdatedAt;
@property (nonatomic, strong) NSString *numServes;
@property (nonatomic, strong) NSNumber *makeTimeMins;
@property (nonatomic, strong) NSNumber *quantityType;

+ (void)latestRecipesWithSuccess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

@end
