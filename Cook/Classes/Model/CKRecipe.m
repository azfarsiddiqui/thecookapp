//
//  CKRecipe.m
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipe.h"
#import "CKBook.h"
#import "CKRecipePin.h"
#import "CKRecipeImage.h"
#import "Ingredient.h"
#import "CKConstants.h"
#import "NSArray+Enumerable.h"
#import "CKActivity.h"
#import "NSString+Utilities.h"
#import "CKRecipeLike.h"
#import "CKRecipeComment.h"
#import "CKPhotoManager.h"
#import "CKRecipeTag.h"
#import "CKLocation.h"
#import "AppHelper.h"

@interface CKRecipe ()

@end

@implementation CKRecipe

@synthesize book = _book;
@synthesize user = _user;
@synthesize geoLocation = _geoLocation;
@synthesize recipeImage = _recipeImage;
@synthesize ingredients = _ingredients;

#define kIngredientDelimiter    @"::"

+ (NSInteger)maxServes {
    return 12;
}

+ (NSInteger)maxPrepTimeInMinutes {
    return 340.0;
}

+ (NSInteger)maxCookTimeInMinutes {
    return 340.0;
}

#pragma mark - creation

+ (CKRecipe *)recipeForBook:(CKBook *)book {
    return [self recipeForBook:book page:nil];
}

+ (CKRecipe *)recipeForBook:(CKBook *)book page:(NSString *)page {
    PFObject *parseRecipe = [self objectWithDefaultSecurityWithClassName:kRecipeModelName];
    CKRecipe *recipe = [[CKRecipe alloc] initWithParseObject:parseRecipe];
    recipe.book = book;
    recipe.user = book.user;
    recipe.page = page;
    recipe.privacy = CKPrivacyPublic;
    return recipe;
}

+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user {
    CKRecipe *recipe = [[CKRecipe alloc] initWithParseObject:parseRecipe];
        
    recipe.numServes = [parseRecipe objectForKey:kRecipeAttrNumServes];
    recipe.cookingTimeInMinutes = [parseRecipe objectForKey:kRecipeAttrCookingTimeInMinutes];
    recipe.prepTimeInMinutes = [parseRecipe objectForKey:kRecipeAttrPrepTimeInMinutes];

    // At the moment, only support one image even though database supports multiple.
    NSArray *photos = [parseRecipe objectForKey:kRecipeAttrRecipePhotos];
    if ([photos count] > 0) {
        recipe.recipeImage = [CKRecipeImage recipeImageForParseRecipeImage:[photos objectAtIndex:0]];
    }
    
    if (user) {
        recipe.user = user;
    }
    return recipe;
}

+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user book:(CKBook *)book {
    CKRecipe *recipe = [self recipeForParseRecipe:parseRecipe user:user];
    if (book) {
        recipe.book = book;
    }
    return recipe;
}

+ (CKRecipe *)recipeForUser:(CKUser *)user book:(CKBook *)book {
    PFObject *parseRecipe = [self objectWithDefaultSecurityWithClassName:kRecipeModelName];
    CKRecipe *recipe = [self recipeForParseRecipe:parseRecipe user:user];
    recipe.book = book;
    return recipe;
}

#pragma mark - Query

+ (void)recipeForObjectId:(NSString *)objectId success:(GetObjectSuccessBlock)success
                  failure:(ObjectFailureBlock)failure {
    
    PFQuery *query = [PFQuery queryWithClassName:kRecipeModelName];
//    [query setCachePolicy:kPFCachePolicyCacheOnly];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query includeKey:kRecipeAttrRecipePhotos];
    [query includeKey:kBookModelForeignKeyName];
    [query includeKey:kRecipeAttrTags];
    [query includeKey:kLocationModelForeignKeyName];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", kBookModelForeignKeyName, kUserModelForeignKeyName]];
    [query includeKey:kUserModelForeignKeyName];
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *parseRecipe, NSError *error) {
        if (!error) {
            success([[CKRecipe alloc] initWithParseObject:parseRecipe]);
        } else {
            failure(error);
        }
    }];
}

#pragma mark - Search

+ (void)searchWithTerm:(NSString *)searchTerm success:(RecipeSearchSuccessBlock)success
               failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"searchRecipes"
                       withParameters:@{ @"keyword" : searchTerm, @"cookVersion": [[AppHelper sharedInstance] appVersion] }
                                block:^(NSDictionary *results, NSError *error) {
                                    if (!error) {
                                        
                                        NSArray *parseRecipes = [results objectForKey:@"recipes"];
                                        NSUInteger recipeCount = [[results objectForKey:@"count"] unsignedIntegerValue];
                                        
                                        // Map to our model.
                                        NSArray *recipes = [parseRecipes collect:^id(PFObject *parseRecipe) {
                                            
                                            PFUser *parseUser = [parseRecipe objectForKey:kUserModelForeignKeyName];
                                            CKUser *user = [CKUser userWithParseUser:parseUser];
                                            return [CKRecipe recipeForParseRecipe:parseRecipe user:user];
                                        }];
                                        
                                        success(recipes, recipeCount);
                                        
                                    } else {
                                        DLog(@"Error searching recipes: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

#pragma mark - Save

- (void)saveWithImage:(UIImage *)image startProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress
             progress:(ProgressBlock)progress completion:(ObjectSuccessBlock)success
              failure:(ObjectFailureBlock)failure {
    
    //Stamp locale info here
    self.locale = [[NSLocale autoupdatingCurrentLocale] localeIdentifier];
    
    // If we have an image, generate a recipe image placeholder.
    if (image) {
        
        // Generate image placeholders.
        CKRecipeImage *recipeImage = [CKRecipeImage recipeImage];
        recipeImage.imageUuid = [[NSUUID UUID] UUIDString];
        recipeImage.thumbImageUuid = [[NSUUID UUID] UUIDString];
        
        // Now save it off in the background first before associating it with this recipe.
        [recipeImage saveInBackground:^{
            
            // Now associate the recipeImage with this recipe.
            [self setRecipeImage:recipeImage];
            
            // Now go ahead and save the recipe.
            [self saveInBackground:^{
                
                // Go ahead and upload it via CKServerManager.
                [[CKPhotoManager sharedInstance] addImage:image recipe:self];
                
                // 100% progress and return.
                progress(endProgress * 100);
                success();
                
            } failure:^(NSError *error) {
                failure(error);
            }];
            
        } failure:^(NSError *error) {
            
            failure(error);
        }];
        

    } else {
        
        // Just go ahead and save the recipe.
        [self saveInBackground:^{
            
            // 100% progress and return.
            progress(endProgress * 100);
            success();
            
        } failure:^(NSError *error) {
            failure(error);
        }];
        
    }
    
}

#pragma mark - Info and viewed by user.

// Stats.
- (void)infoAndViewedWithCompletion:(RecipeInfoSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"recipeInfo"
                       withParameters:@{ @"recipeId" : self.objectId, @"cookVersion": [[AppHelper sharedInstance] appVersion] }
                                block:^(NSDictionary *results, NSError *error) {
                                    if (!error) {
                                        
                                        BOOL liked = [[results objectForKey:@"liked"] boolValue];
                                        
                                        PFObject *parseRecipePin = [results objectForKey:@"recipePin"];
                                        CKRecipePin *recipePin = nil;
                                        if (parseRecipePin) {
                                            PFObject *parseRecipe = [parseRecipePin objectForKey:kRecipeModelForeignKeyName];
                                            recipePin = [[CKRecipePin alloc] initWithParseObject:parseRecipePin];
                                            recipePin.recipe = [[CKRecipe alloc] initWithParseObject:
                                                                [PFObject objectWithoutDataWithClassName:kRecipeModelName objectId:parseRecipe.objectId]];
                                        }
                                        success(liked, recipePin);
                                        
                                    } else {
                                        DLog(@"Error getting info recipe: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

#pragma mark - Likes

- (void)like:(BOOL)like user:(CKUser *)user completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    DLog("like: %@", [NSString CK_stringForBoolean:like]);
    
    if (like) {
        
        // Check if already liked by user.
        [self likedByUser:user completion:^(BOOL liked){
            
            // Already liked, do nothing and return.
            if (liked) {
                success();
            } else {
                
                // Create like object for (user, recipe).
                CKRecipeLike *recipeLike = [CKRecipeLike recipeLikeForUser:user recipe:self];
                [recipeLike saveInBackground:^{
                    success();
                } failure:^(NSError *error) {
                    failure(error);
                }];

            }
            
        } failure:^(NSError *error) {
            failure(error);
        }];
        
        
    } else {
        
        // Get all likes for the recipe given the user.
        PFQuery *likesQuery = [PFQuery queryWithClassName:kRecipeLikeModelName];
        [likesQuery whereKey:kRecipeModelForeignKeyName equalTo:self.parseObject];
        [likesQuery whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
        [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
            
            if (!error) {
                
                // If there are likes, then remove them,
                if ([likes count] > 0) {
                    
                    [PFObject deleteAllInBackground:likes block:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            success();
                        } else {
                            failure(error);
                        }
                    }];
                }
                
            } else {
                failure(error);
            }
        }];
        
    }
    
}

- (void)likedByUser:(CKUser *)user completion:(BoolObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    if ([self persisted] && user) {
        PFQuery *likesQuery = [PFQuery queryWithClassName:kRecipeLikeModelName];
        [likesQuery whereKey:kRecipeModelForeignKeyName equalTo:self.parseObject];
        [likesQuery whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
        [likesQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                success(number > 0);
            } else {
                failure(error);
            }
        }];
    } else {
        failure(nil);
    }
}

- (void)numLikesWithCompletion:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    if ([self persisted]) {
        PFQuery *likesQuery = [PFQuery queryWithClassName:kRecipeLikeModelName];
        [likesQuery whereKey:kRecipeModelForeignKeyName equalTo:self.parseObject];
        [likesQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                success(number);
            } else {
                failure(error);
            }
        }];
    } else {
        failure(nil);
    }
}

#pragma mark - Pins

- (void)pinnedToBook:(CKBook *)book completion:(RecipeCheckPinnedSuccessBlock)success
             failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"recipeIsPinnedToBook"
                       withParameters:@{ @"recipeId" : self.objectId, @"bookId" : book.objectId, @"cookVersion": [[AppHelper sharedInstance] appVersion] }
                                block:^(NSDictionary *results, NSError *error) {
                                    if (!error) {
                                        
                                        BOOL pinned = [[results objectForKey:@"pinned"] boolValue];
                                        NSString *page = nil;
                                        if (pinned) {
                                            page = [results objectForKey:@"page"];
                                        }
                                        DLog(@"Recipe[%@] pinned[%@] page[%@]", self.objectId,
                                             [NSString CK_stringForBoolean:pinned], page);
                                        success(pinned, page);
                                        
                                    } else {
                                        DLog(@"Error pinning recipe: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

- (void)pinToBook:(CKBook *)book page:(NSString *)page completion:(GetObjectSuccessBlock)success
          failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"pinRecipeToBook"
                       withParameters:@{ @"recipeId" : self.objectId, @"bookId" : book.objectId, @"page" : page, @"cookVersion": [[AppHelper sharedInstance] appVersion] }
                                block:^(NSDictionary *results, NSError *error) {
                                    if (!error) {
                                        
                                        PFObject *parseRecipePin = [results objectForKey:@"recipePin"];
                                        CKRecipePin *recipePin = nil;
                                        if (parseRecipePin) {
                                            recipePin = [[CKRecipePin alloc] initWithParseObject:parseRecipePin];
                                        }

                                        DLog(@"Pinned recipe[%@] to book[%@]", self.objectId, book.objectId);
                                        success(recipePin);
                                    } else {
                                        DLog(@"Error pinning recipe: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

- (void)unpinnedFromBook:(CKBook *)book completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"unpinRecipeFromBook"
                       withParameters:@{ @"recipeId" : self.objectId, @"bookId" : book.objectId, @"cookVersion": [[AppHelper sharedInstance] appVersion] }
                                block:^(NSDictionary *results, NSError *error) {
                                    if (!error) {
                                        DLog(@"Unpinned recipe[%@] from book[%@]", self.objectId, book.objectId);
                                        success();
                                    } else {
                                        DLog(@"Error pinning recipe: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

#pragma mark - Comments

- (void)comment:(NSString *)comment user:(CKUser *)user completion:(ObjectSuccessBlock)success
        failure:(ObjectFailureBlock)failure {
    
    // Create comment object for (user, recipe).
    CKRecipeComment *recipeComment = [CKRecipeComment recipeCommentForUser:user recipe:self text:comment];
    [recipeComment saveInBackground:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];

}

- (void)numCommentsWithCompletion:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    if ([self persisted]) {
        PFQuery *likesQuery = [PFQuery queryWithClassName:kRecipeCommentModelName];
        [likesQuery whereKey:kRecipeModelForeignKeyName equalTo:self.parseObject];
        [likesQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                success(number);
            } else {
                failure(error);
            }
        }];
    } else {
        failure(nil);
    }
}

- (void)commentsWithCompletion:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *commentsQuery = [PFQuery queryWithClassName:kRecipeCommentModelName];
    [commentsQuery whereKey:kRecipeModelForeignKeyName equalTo:self.parseObject];
    [commentsQuery includeKey:kUserModelForeignKeyName];
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray *parseComments, NSError *error) {
        if (!error) {
            success([parseComments collect:^id(PFObject *parseComment) {
                return [[CKRecipeComment alloc] initWithParseObject:parseComment];
            }]);
        } else {
            failure(error);
        }
    }];
}

- (void)commentsLikesWithCompletion:(RecipeCommentsLikesSuccessBlock)success failure:(ObjectFailureBlock)failure {
    [PFCloud callFunctionInBackground:@"recipeCommentsLikes"
                       withParameters:@{ @"recipeId" : self.objectId, @"cookVersion": [[AppHelper sharedInstance] appVersion] }
                                block:^(NSDictionary *results, NSError *error) {
                                    if (!error) {
                                        
                                        NSMutableArray *comments = [NSMutableArray array];
                                        NSMutableArray *likes = [NSMutableArray array];
                                        
                                        if (results && [results isKindOfClass:[NSDictionary class]]) {
                                            
                                            // Grab and wrap the comments in our model.
                                            NSArray *parseComments = [results objectForKey:@"comments"];
                                            if (parseComments && [parseComments isKindOfClass:[NSArray class]]) {
                                                [comments addObjectsFromArray:[parseComments collect:^id(PFObject *parseComment) {
                                                    return [[CKRecipeComment alloc] initWithParseObject:parseComment];
                                                }]];
                                            }
                                            
                                            // Grab and wrap the likes in our model.
                                            NSArray *parseLikes = [results objectForKey:@"likes"];
                                            if (parseLikes && [parseLikes isKindOfClass:[NSArray class]]) {
                                                [likes addObjectsFromArray:[parseLikes collect:^id(PFObject *parseLike) {
                                                    return [[CKRecipeLike alloc] initWithParseObject:parseLike];
                                                }]];
                                            }
                                            
                                        }
                                        
                                        success(comments, likes);
                                        
                                    } else {
                                        DLog(@"Error loading comments and likes: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

#pragma mark - other public

- (PFFile *)imageFile {
    return [self.recipeImage imageFile];
}

- (void)setImage:(UIImage *)image {
    if (image) {
        self.recipeImage = [CKRecipeImage recipeImageForImage:image imageName:@"recipeImage.png"];
    }
}

- (BOOL)isOwner {
    return [self isOwner:[CKUser currentUser]];
}

- (BOOL)isOwner:(CKUser *)user {
    return  [self.user isEqual:user];
}

- (BOOL)isPublic {
    return ([self privacy] == CKPrivacyPublic);
}

- (BOOL)isPrivate {
    return ([self privacy] == CKPrivacyPrivate);
}

- (BOOL)isShareable {
    return ([self isOwner] || [self isPublic]);
}

#pragma mark - CKModel methods

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", self.privacy] forKey:kRecipeAttrPrivacy];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self.story length]] forKey:kRecipeAttrStory];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self.method length]] forKey:kRecipeAttrDescription];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self.ingredients count]] forKey:kRecipeAttrIngredients];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self.numServes integerValue]] forKey:kRecipeAttrNumServes];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%dm", [self.prepTimeInMinutes integerValue]] forKey:kRecipeAttrPrepTimeInMinutes];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%dm", [self.cookingTimeInMinutes integerValue]] forKey:kRecipeAttrCookingTimeInMinutes];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:(self.geoLocation != nil)] forKey:kRecipeAttrLocation];
    [descriptionProperties setValue:[NSString CK_safeString:self.locale] forKey:kRecipeAttrLocale];
    [descriptionProperties setValue:self.page forKey:kRecipeAttrPage];
    [descriptionProperties setValue:[self.book description] forKey:kBookModelForeignKeyName];
    [descriptionProperties setValue:[self.user description] forKey:kUserModelForeignKeyName];
    return descriptionProperties;
}

#pragma mark - Wrapper getter/setter methods

- (CKBook *)book {
    if (!_book) {
        _book = [[CKBook alloc] initWithParseObject:[self.parseObject objectForKey:kBookModelForeignKeyName]];
    }
    return _book;
}

- (void)setBook:(CKBook *)book {
    [self.parseObject setObject:book.parseObject forKey:kBookModelForeignKeyName];
}

- (CKUser *)user {
    if (!_user) {
        _user = [CKUser userWithParseUser:[self.parseObject objectForKey:kUserModelForeignKeyName]];
    }
    return _user;
}

- (void)setUser:(CKUser *)user {
    [self.parseObject setObject:user.parseUser forKey:kUserModelForeignKeyName];
}

- (NSString *)method {
    return [self.parseObject objectForKey:kRecipeAttrDescription];
}

- (void)setMethod:(NSString *)method {
    [self.parseObject setObject:[NSString CK_safeString:method] forKey:kRecipeAttrDescription];
}

- (NSString *)page {
    return [self.parseObject objectForKey:kRecipeAttrPage];
}

- (void)setPage:(NSString *)page {
    [self.parseObject setObject:[page uppercaseString] forKey:kRecipeAttrPage];
}

- (NSString *)story {
    return [self.parseObject objectForKey:kRecipeAttrStory];
}

- (void)setStory:(NSString *)story {
    [self.parseObject setObject:[NSString CK_safeString:story] forKey:kRecipeAttrStory];
}

- (NSArray *)tags {
    NSArray *tags = [self.parseObject objectForKey:kRecipeAttrTags];
    NSMutableArray *tagArray = [NSMutableArray new];
    [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CKRecipeTag *recipeTag = [[CKRecipeTag alloc] initWithParseObject:obj];
        [tagArray addObject:recipeTag];
    }];
    return tagArray;
}

- (void)setTags:(NSArray *)tags {
    NSMutableArray *returnArray = [NSMutableArray new];
    [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [returnArray addObject:((CKRecipeTag *)obj).parseObject];
    }];
    [self.parseObject setObject:returnArray forKey:kRecipeAttrTags];
}

- (NSInteger)categoryIndex {
    return [[self.parseObject objectForKey:kRecipeAttrCategoryIndex] intValue];
}

- (void)setCategoryIndex:(NSInteger)categoryIndex {
    [self.parseObject setObject:[NSNumber numberWithInt:categoryIndex]forKey:kRecipeAttrCategoryIndex];
}

- (NSNumber *)numServes {
    return [self.parseObject objectForKey:kRecipeAttrNumServes];
}

- (void)setNumServes:(NSNumber *)numServes {
    if (numServes) {
        [self.parseObject setObject:numServes forKey:kRecipeAttrNumServes];
    } else {
        [self.parseObject removeObjectForKey:kRecipeAttrNumServes];
    }
}

- (void)setCookingTimeInMinutes:(NSNumber *)cookingTimeInMinutes {
    if (cookingTimeInMinutes) {
        [self.parseObject setObject:cookingTimeInMinutes forKey:kRecipeAttrCookingTimeInMinutes];
    } else {
        [self.parseObject removeObjectForKey:kRecipeAttrCookingTimeInMinutes];
    }
}

- (NSNumber *)cookingTimeInMinutes {
    return [self.parseObject objectForKey:kRecipeAttrCookingTimeInMinutes];
}

- (void)setPrepTimeInMinutes:(NSNumber *)prepTimeInMinutes {
    if (prepTimeInMinutes) {
        [self.parseObject setObject:prepTimeInMinutes forKey:kRecipeAttrPrepTimeInMinutes];
    } else {
        [self.parseObject removeObjectForKey:kRecipeAttrPrepTimeInMinutes];
    }
}

- (NSNumber *)prepTimeInMinutes {
    return [self.parseObject objectForKey:kRecipeAttrPrepTimeInMinutes];
}

- (void)setPrivacy:(CKPrivacy)privacy {
    [self.parseObject setObject:@(privacy) forKey:kRecipeAttrPrivacy];
}

- (CKPrivacy)privacy {
    CKPrivacy privacy = CKPrivacyPublic;
    id value = [self.parseObject objectForKey:kRecipeAttrPrivacy];
    if (value) {
        privacy = [value unsignedIntegerValue];
    }
    return privacy;
}

- (void)setRecipeImage:(CKRecipeImage *)recipeImage {
    _recipeImage = recipeImage;

    if (recipeImage.parseObject) {
        
        // Replace the list with a single-element list, future expandable for more photos.
        [self.parseObject setObject:@[recipeImage.parseObject] forKey:kRecipeAttrRecipePhotos];
    } else if (recipeImage == nil) {
        //TODO: Will need to change this later to accomodate multiple images
        [self.parseObject removeObjectForKey:kRecipeAttrRecipePhotos];
    }
}

- (CKRecipeImage *)recipeImage {
    if (!_recipeImage) {
        NSArray *photos = [self.parseObject objectForKey:kRecipeAttrRecipePhotos];
        if ([photos count] > 0) {
            _recipeImage = [CKRecipeImage recipeImageForParseRecipeImage:[photos objectAtIndex:0]];
        }
    }
    return _recipeImage;
}

- (void)setGeoLocation:(CKLocation *)geoLocation {
    if (geoLocation) {
        _geoLocation = geoLocation;
        [self.parseObject setObject:geoLocation.parseObject forKey:kLocationModelForeignKeyName];
    } else {
        _geoLocation = nil;
        [self.parseObject removeObjectForKey:kLocationModelForeignKeyName];
    }
}

- (CKLocation *)geoLocation {
    if (!_geoLocation) {
        PFObject *parseLocationObject = [self.parseObject objectForKey:kLocationModelForeignKeyName];
        _geoLocation = (parseLocationObject != nil) ? [[CKLocation alloc] initWithParseObject:parseLocationObject] :  nil;
    }
    return _geoLocation;
}

- (void)setIngredients:(NSArray *)ingredients {
    NSArray *delimitedIngredients = [ingredients collect:^id(Ingredient *ingredient) {
        if (!ingredient.measurement) {
            return ingredient.name;
        } else {
            return [NSString stringWithFormat:@"%@::%@", ingredient.measurement,ingredient.name];
        }
    }];
    
    _ingredients = ingredients;
    if ([_ingredients count] > 0) {
        [self.parseObject setObject:delimitedIngredients forKey:kRecipeAttrIngredients];
    } else {
        [self.parseObject removeObjectForKey:kRecipeAttrIngredients];
    }
}

- (NSArray *)ingredients {
    if (!_ingredients) {
        _ingredients = [self assembleIngredients];
    }
    return _ingredients;
}

- (NSInteger)numViews {
    return [[self.parseObject objectForKey:kRecipeAttrNumViews] integerValue];
}

- (NSInteger)numLikes {
    return [[self.parseObject objectForKey:kRecipeAttrNumLikes] integerValue];
}

- (NSInteger)numComments {
    return [[self.parseObject objectForKey:kRecipeAttrNumComments] integerValue];
}

- (NSInteger)rankScore {
    return [[self.parseObject objectForKey:kRecipeAttrRankScore] integerValue];
}

- (void)setRecipeUpdatedDateTime:(NSDate *)recipeUpdatedDateTime {
    if (recipeUpdatedDateTime) {
        [self.parseObject setObject:recipeUpdatedDateTime forKey:kRecipeAttrUpdatedAt];
    } else {
        [self.parseObject removeObjectForKey:kRecipeAttrUpdatedAt];
    }
}

- (NSDate *)recipeUpdatedDateTime {
    NSDate *recipeUpdatedDateTime = [self.parseObject objectForKey:kRecipeAttrUpdatedAt];
    if (!recipeUpdatedDateTime) {
        recipeUpdatedDateTime = self.createdDateTime;
    }
    return recipeUpdatedDateTime;
}

- (void)setLocale:(NSString *)recipeLocale {
    if (recipeLocale) {
        [self.parseObject setObject:recipeLocale forKey:kRecipeAttrLocale];
    } else {
        [self.parseObject removeObjectForKey:kRecipeAttrLocale];
    }
}

- (NSString *)locale {
    return (NSString *)[self.parseObject objectForKey:kRecipeAttrLocale];
}

#pragma mark - Existence methods

- (BOOL)hasPhotos {
    return (self.recipeImage.imageFile != nil || [self.recipeImage.imageUuid CK_containsText]);
}

- (BOOL)hasTitle {
    return [self.name CK_containsText];
}

- (BOOL)hasStory {
    return [self.story CK_containsText];
}

- (BOOL)hasMethod {
    return [self.method CK_containsText];
}

- (BOOL)hasIngredients {
    return ([self.ingredients count] > 0);
}

- (BOOL)hasTags {
    return ([self.tags count] > 0);
}

- (NSURL *)userPhotoUrl {
    NSURL *pictureUrl = nil;
    
    PFFile *userPhotoFile = [self.parseObject objectForKey:kRecipeAttrUserPhoto];
    if (userPhotoFile != nil && userPhotoFile.getData.length > 0) {
        pictureUrl = [NSURL URLWithString:userPhotoFile.url];
    }
    
    return pictureUrl;
}

- (void)markShared {
    [PFCloud callFunctionInBackground:@"markRecipeShared"
                       withParameters:@{ @"recipeId" : self.objectId, @"cookVersion": [[AppHelper sharedInstance] appVersion] }
                                block:^(NSDictionary *results, NSError *error) {
                                    if (!error) {
                                        DLog(@"Recipe[%@] marked shared.", self.objectId);
                                    } else {
                                        DLog(@"Error marking recipe[%@] shared.", self.objectId);
                                    }
                                }];
}

#pragma mark - Private Methods

- (NSArray *)assembleIngredients {
    NSArray *delimitedIngredients = [self.parseObject objectForKey:kRecipeAttrIngredients];
    NSArray *ingredients = [delimitedIngredients collect:^id(NSString *delimitedIngredient) {
        NSString *unit = @"";
        NSString *name = @"";
        NSArray *components = [delimitedIngredient componentsSeparatedByString:kIngredientDelimiter];
        if ([components count] == 2) {
            unit = [components objectAtIndex:0];
            name = [components objectAtIndex:1];
        } else if ([components count] == 1) {
            name = [components objectAtIndex:0];
        }
        return [Ingredient ingredientwithName:name measurement:unit];
    }];
    return ingredients;
}

@end
