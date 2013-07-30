//
//  Category.h
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@class CKBook;

@interface CKCategory : CKModel

@property (nonatomic, strong) NSNumber *order;
@property (nonatomic, strong) CKBook *book;

+ (CKCategory *)categoryForName:(NSString *)name book:(CKBook *)book;
+ (CKCategory *)categoryForName:(NSString *)name order:(NSInteger)order book:(CKBook *)book;
+ (CKCategory *)categoryForParseCategory:(PFObject *)parseCategory;
+ (void)listCategories:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;

- (BOOL)isDataAvailable;

@end
