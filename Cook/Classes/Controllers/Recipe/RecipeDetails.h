//
//  RecipeDetails.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKUser;

@interface RecipeDetails : NSObject

@property (nonatomic, strong) CKUser *user;

@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *story;
@property (nonatomic, copy) NSString *method;

@property (nonatomic, assign) NSInteger numServes;
@property (nonatomic, assign) NSInteger prepTimeInMinutes;
@property (nonatomic, assign) NSInteger cookingTimeInMinutes;
@property (nonatomic, strong) NSArray *ingredients;

@end
