//
//  Ingredient.h
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

@interface Ingredient : NSObject
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *measurement;
+(Ingredient *)ingredientwithName:(NSString *)name measurement:(NSString*)measurement;
@end
