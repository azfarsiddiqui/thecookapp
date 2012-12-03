//
//  CKBook.h
//  Cook
//
//  Created by Jeff Tan-Ang on 2/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Parse/Parse.h>
#import "CKModel.h"
#import "CKUser.h"

@class CKBook;

typedef void(^BenchtopBooksSuccessBlock)(CKBook *myBook, NSArray *friendsBooks);

@interface CKBook : CKModel

@property (nonatomic, strong) CKUser *user;

@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *illustration;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, assign) NSInteger numRecipes;
@property (nonatomic, assign) NSInteger numCategories;
@property (nonatomic, strong) NSArray *categories;

+ (void)bookForUser:(CKUser *)user success:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)createBookForUser:(CKUser *)user succeess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (PFObject *)createParseBook;
+ (PFObject *)createParseBookForParseUser:(PFUser *)parseUser;
+ (void)followBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)friendsBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)featuredBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (CKBook *)myInitialBook;
+ (CKBook *)defaultBook;

- (id)initWithParseBook:(PFObject *)parseBook user:(CKUser *)user;
- (void)listRecipesSuccess:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (NSString *)userName;
- (BOOL)editable;
- (void)addFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)removeFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

@end
