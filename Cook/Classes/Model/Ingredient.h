//
//  Ingredient.h
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

@interface Ingredient : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *measurement;

+ (Ingredient *)ingredientwithName:(NSString *)name measurement:(NSString*)measurement;

@end
