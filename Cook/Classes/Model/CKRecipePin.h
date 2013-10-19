//
//  CKRecipePin.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@class CKRecipe;

@interface CKRecipePin : CKModel

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) NSString *page;

@end
