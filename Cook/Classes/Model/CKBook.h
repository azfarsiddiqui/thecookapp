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

//fetch
+ (void)fetchBookForUser:(CKUser *)user success:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)fetchRecipesSuccess:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;

////persistence operations
+ (void)saveBookForUser:(CKUser *)user succeess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)followBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)friendsBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)featuredBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)addFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)removeFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

//creation
+ (PFObject *)createParseBookForParseUser:(PFUser *)parseUser;

- (id)initWithParseBook:(PFObject *)parseBook user:(CKUser *)user;
- (NSString *)userName;
- (BOOL)editable;
- (BOOL)friendsBook;
- (BOOL)isUserBookAuthor:(CKUser*)user;

@end
