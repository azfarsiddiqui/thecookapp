//
//  CKRecipe.m
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipe.h"
#import "CKBook.h"
#import "CKRecipeImage.h"
#import "Ingredient.h"
#import "CKConstants.h"
#import "NSArray+Enumerable.h"
#import "CKActivity.h"
#import "NSString+Utilities.h"
#import "CKRecipeImage.h"
#import "CKRecipeLike.h"
#import "CKRecipeComment.h"

@interface CKRecipe ()

@end

@implementation CKRecipe

@synthesize book = _book;
@synthesize user = _user;
@synthesize recipeImage = _recipeImage;
@synthesize ingredients = _ingredients;

#define kIngredientDelimiter    @"::"

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
    recipe.privacy = CKPrivacyFriends;
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
    
    recipe.user = user;
    return recipe;
}

+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user book:(CKBook *)book {
    CKRecipe *recipe = [self recipeForParseRecipe:parseRecipe user:user];
    recipe.book = book;
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

#pragma mark - Save

- (void)saveWithImage:(UIImage *)image uploadProgress:(ProgressBlock)progress completion:(ObjectSuccessBlock)success
              failure:(ObjectFailureBlock)failure {
    
    if (image) {
        
        CKRecipeImage *recipeImage = [CKRecipeImage recipeImageForImage:image imageName:@"recipe.jpg"];
        [self setRecipeImage:recipeImage];
        
        // Save the photo first to get its objectId.
        PFFile *recipePhotoFile = [recipeImage imageFile];
        [recipePhotoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error) {
                
                // Save CKRecipeImage now that PFFile has been persisted.
                [recipeImage saveInBackground:^{
                    
                    // Associate with recipe.
                    [self setRecipeImage:recipeImage];
                    
                    // Now go ahead and save the recipe.
                    [self saveInBackground:^{
                        success();
                    } failure:^(NSError *error) {
                        failure(error);
                    }];
                    
                } failure:^(NSError *error) {
                    failure(error);
                }];
                
            } else {
                failure(error);
            }
            
        } progressBlock:^(int percentDone) {
            
            progress(percentDone);
            
        }];
        
    } else {
        
        // Now go ahead and save the recipe.
        [self saveInBackground:^{
            success();
        } failure:^(NSError *error) {
            failure(error);
        }];
        
    }
}

- (void)saveWithImage:(UIImage *)image startProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress
             progress:(ProgressBlock)progress completion:(ObjectSuccessBlock)success
              failure:(ObjectFailureBlock)failure {
    
    CGFloat recipeSaveProgress = 0.1;
    
    if (image) {
        DLog(@"Saving image");
        CKRecipeImage *recipeImage = [CKRecipeImage recipeImageForImage:image imageName:@"recipe.jpg"];
        [self setRecipeImage:recipeImage];
        
        // Save the photo first to get its objectId.
        PFFile *recipePhotoFile = [recipeImage imageFile];
        [recipePhotoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (!error) {
                
                // Save CKRecipeImage now that PFFile has been persisted.
                [recipeImage saveInBackground:^{
                    
                    // Associate with recipe.
                    [self setRecipeImage:recipeImage];
                    
                    // Now go ahead and save the recipe.
                    [self saveInBackground:^{
                        
                        progress(recipeSaveProgress * 100);
                        success();
                        
                    } failure:^(NSError *error) {
                        failure(error);
                    }];
                    
                } failure:^(NSError *error) {
                    failure(error);
                }];
                
            } else {
                failure(error);
            }
            
        } progressBlock:^(int percentDone) {
            
            int overallProgress = percentDone;
            if (overallProgress > startProgress) {
                overallProgress = percentDone * (((endProgress - recipeSaveProgress) * 100) / 100);
            }
            
            progress(overallProgress);
            
        }];
        
    } else {
        
        DLog(@"Saving recipe without an updated image.");
        
        // Now go ahead and save the recipe.
        [self saveInBackground:^{
            
            progress(endProgress * 100);
            success();
            
        } failure:^(NSError *error) {
            failure(error);
        }];
        
    }
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
    if ([self persisted]) {
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

#pragma mark - Comments

- (void)comment:(NSString *)comment user:(CKUser *)user completion:(ObjectSuccessBlock)success
        failure:(ObjectFailureBlock)failure {
    
    // Create comment object for (user, recipe).
    CKRecipeComment *recipeComment = [CKRecipeComment recipeCommentForUser:user recipe:self];
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
    PFQuery *likesQuery = [PFQuery queryWithClassName:kRecipeCommentModelName];
    [likesQuery whereKey:kRecipeModelForeignKeyName equalTo:self.parseObject];
    [likesQuery findObjectsInBackgroundWithBlock:^(NSArray *parseComments, NSError *error) {
        if (!error) {
            success([parseComments collect:^id(PFObject *parseComment) {
                return [[CKRecipeComment alloc] initWithParseObject:parseComment];
            }]);
        } else {
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

- (BOOL)isUserRecipeAuthor:(CKUser *)user {
    return  [self.user isEqual:user];
}

- (void)clearLocation {
    [self.parseObject removeObjectForKey:kRecipeAttrLocation];
}

- (void)setLocation:(CLLocation *)location {
    if (location) {
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                                      longitude:location.coordinate.longitude];
        [self.parseObject setObject:geoPoint forKey:kRecipeAttrLocation];
    }
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
    [self.parseObject setObject:page forKey:kRecipeAttrPage];
}

- (NSString *)story {
    return [self.parseObject objectForKey:kRecipeAttrStory];
}

- (void)setStory:(NSString *)story {
    [self.parseObject setObject:[NSString CK_safeString:story] forKey:kRecipeAttrStory];
}

- (NSArray *)tags {
    return [self.parseObject objectForKey:kRecipeAttrTags];
}

- (void)setTags:(NSArray *)tags {
    [self.parseObject setObject:tags forKey:kRecipeAttrTags];
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
    CKPrivacy privacy = CKPrivacyPrivate;
    id value = [self.parseObject objectForKey:kRecipeAttrPrivacy];
    if (value) {
        privacy = [value unsignedIntegerValue];
    }
    return privacy;
}

- (void)setRecipeImage:(CKRecipeImage *)recipeImage {
    
    // Replace the list with a single-element list, future expandable for more photos.
    [self.parseObject setObject:@[recipeImage.parseObject] forKey:kRecipeAttrRecipePhotos];
    
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

#pragma mark - Existence methods

- (BOOL)hasPhotos {
    return ([self imageFile] != nil);
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
