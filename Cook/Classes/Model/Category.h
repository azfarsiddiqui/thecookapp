//
//  Category.h
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@interface Category : CKModel

+(Category *)categoryForParseCategory:(PFObject *)parseCategory;
+(void) listCategories:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
@end
