//
//  RecipeClipboard.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCategory.h"
#import "CKRecipe.h"

@interface RecipeClipboard : NSObject

@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *story;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, strong) NSArray *ingredients;

@property (nonatomic, assign) NSInteger serves;
@property (nonatomic, assign) NSInteger prepMinutes;
@property (nonatomic, assign) NSInteger cookMinutes;

@property (nonatomic, assign) CKPrivacy privacy;

@end
