//
//  RecipeDetails.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKUser;
@class CKRecipe;

@interface RecipeDetails : NSObject

@property (nonatomic, strong) CKUser *user;
@property (nonatomic, copy) NSString *page;
@property (nonatomic, strong) NSArray *availablePages;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, copy) NSString *story;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, assign) NSInteger numServes;
@property (nonatomic, assign) NSInteger prepTimeInMinutes;
@property (nonatomic, assign) NSInteger cookingTimeInMinutes;
@property (nonatomic, strong) NSArray *ingredients;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL saveRequired;

- (id)initWithRecipe:(CKRecipe *)recipe;
- (void)updateToRecipe:(CKRecipe *)recipe;

@end
