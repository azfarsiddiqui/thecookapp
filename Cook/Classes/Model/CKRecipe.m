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

@interface CKRecipe ()

@end

@implementation CKRecipe

@synthesize book = _book;
@synthesize user = _user;
@synthesize category = _category;
@synthesize privacy = _privacy;
@synthesize method = _method;
@synthesize story = _story;
@synthesize numServes = _numServes;
@synthesize prepTimeInMinutes = _prepTimeInMinutes;
@synthesize cookingTimeInMinutes = _cookingTimeInMinutes;
@synthesize recipeImage = _recipeImage;

#pragma mark - creation

+ (CKRecipe *)recipeForBook:(CKBook *)book {
    PFObject *parseRecipe = [self objectWithDefaultSecurityWithClassName:kRecipeModelName];
    CKRecipe *recipe = [[CKRecipe alloc] initWithParseObject:parseRecipe];
    recipe.book = book;
    recipe.user = book.user;
    return recipe;
}

+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user {
    CKRecipe *recipe = [[CKRecipe alloc] initWithParseObject:parseRecipe];
    
    NSArray *ingredients = [parseRecipe objectForKey:kRecipeAttrIngredients];
    if (ingredients && [ingredients count] > 0) {
        NSMutableArray *mutableIngredientsArray = [NSMutableArray arrayWithCapacity:[ingredients count]];
        [ingredients each:^(NSString *ingredientText) {
            Ingredient *ing = nil;
            if ([ingredientText rangeOfString:@"::"].location != NSNotFound) {
                NSArray *ingredientComponents = [ingredientText componentsSeparatedByString:@"::"];
                NSString *measurement = [ingredientComponents objectAtIndex:0];
                NSString *ingredientName = [ingredientComponents objectAtIndex:1];
                ing = [Ingredient ingredientwithName:ingredientName measurement:measurement];
            } else {
                ing = [Ingredient ingredientwithName:ingredientText measurement:nil];
            }
            [mutableIngredientsArray addObject:ing];
        }];
        recipe.ingredients = mutableIngredientsArray;
        NSString *recipeViewContentOffset = [parseRecipe objectForKey:kRecipeAttrRecipeViewImageContentOffset];
        if (recipeViewContentOffset) {
            recipe.recipeViewImageContentOffset = CGPointFromString(recipeViewContentOffset);
        }
        
        NSNumber *cookingTime = [parseRecipe objectForKey:kRecipeAttrCookingTimeInMinutes];
        if (cookingTime) {
            recipe.cookingTimeInMinutes = [cookingTime integerValue];
        }

        NSNumber *prepTime = [parseRecipe objectForKey:kRecipeAttrPrepTimeInMinutes];
        if (prepTime) {
            recipe.prepTimeInMinutes = [prepTime integerValue];
        }

        NSNumber *numServes = [parseRecipe objectForKey:kRecipeAttrNumServes];
        if (numServes) {
            recipe.numServes = [numServes intValue];
        }
    }
    
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

+ (CKRecipe*) recipeForUser:(CKUser *)user book:(CKBook *)book category:(CKCategory *)category {
    CKRecipe *recipe = [CKRecipe recipeForUser:user book:book];
    recipe.category = category;
    return recipe;
}

#pragma mark - Save

- (void)saveWithImage:(UIImage *)image uploadProgress:(ProgressBlock)progress completion:(ObjectSuccessBlock)success
              failure:(ObjectFailureBlock)failure {
    
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
    
}

- (void)saveAndUploadImageWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure
                  imageUploadProgress:(ProgressBlock)imageUploadProgress {
    
    PFObject *parseRecipe = self.parseObject;
    [self prepareParseRecipeObjectForSave:parseRecipe];
    
    if (self.recipeImage) {
        PFFile *imageFile = [self.recipeImage imageFile];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                failure(error);
            } else {
                
                //must save image reference to get an object id
                [self.recipeImage.parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        failure(error);
                    } else {
                        // Add as an array - replace entire photos collection
                        [self.parseObject setObject:@[self.recipeImage.parseObject] forKey:kRecipeAttrRecipePhotos];
                        
                        // Save the image relation to recipe.
                        [self saveInBackground:^{
                            success();
                        } failure:^(NSError *error) {
                            failure(error);
                        }];
                        
                    }
                }];
                
            }
            
        } progressBlock:^(int percentDone) {
            imageUploadProgress(percentDone);
        }];
    }
}

- (void)saveWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFObject *parseRecipe = self.parseObject;
    BOOL newRecipe = ![self persisted];
    [self prepareParseRecipeObjectForSave:parseRecipe];
    
    [self saveInBackground:^{
        
        // Save add/update activities.
        if (newRecipe) {
            [CKActivity saveAddRecipeActivityForRecipe:self];
        } else {
            [CKActivity saveUpdateRecipeActivityForRecipe:self];
        }
        
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - fetch

- (void)fetchCategoryNameWithSuccess:(GetObjectSuccessBlock)getObjectSuccess {
    [self.category.parseObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        getObjectSuccess(_category.name);
    }];
}

#pragma mark - other public

- (PFFile *)imageFile {
    return [self.recipeImage imageFile];
}

- (BOOL)hasPhotos {
    return ([self imageFile] != nil);
}

- (void)setImage:(UIImage *)image {
    if (image) {
        self.recipeImage = [CKRecipeImage recipeImageForImage:image imageName:@"recipeImage.png"];
    }
}

- (BOOL)isUserRecipeAuthor:(CKUser *)user {
    return  [self.user isEqual:user];
}

#pragma mark - CKModel methods

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%@", [NSString CK_stringForBoolean:self.privacy]] forKey:kRecipeAttrPrivacy];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self.story length]] forKey:kRecipeAttrStory];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self.method length]] forKey:kRecipeAttrDescription];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self.ingredients count]] forKey:kRecipeAttrIngredients];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", self.numServes] forKey:kRecipeAttrNumServes];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%dm", self.prepTimeInMinutes] forKey:kRecipeAttrPrepTimeInMinutes];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%dm", self.cookingTimeInMinutes] forKey:kRecipeAttrCookingTimeInMinutes];
    [descriptionProperties setValue:[self.category description] forKey:kCategoryModelForeignKeyName];
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
    if (!_method) {
        _method = [self.parseObject objectForKey:kRecipeAttrDescription];
    }
    return _method;
}

- (void)setMethod:(NSString *)method {
    [self.parseObject setObject:[NSString CK_safeString:method] forKey:kRecipeAttrDescription];
}

- (NSString *)story {
    if (!_story) {
        _story = [self.parseObject objectForKey:kRecipeAttrStory];
    }
    return _story;
}

- (void)setStory:(NSString *)story {
    [self.parseObject setObject:[NSString CK_safeString:story] forKey:kRecipeAttrStory];
}

- (NSInteger)categoryIndex {
    return [[self.parseObject objectForKey:kRecipeAttrCategoryIndex] intValue];
}

- (void)setCategoryIndex:(NSInteger)categoryIndex {
    [self.parseObject setObject:[NSNumber numberWithInt:categoryIndex]forKey:kRecipeAttrCategoryIndex];
}

- (CKCategory *)category {
    if (!_category) {
        PFObject *parseCategory = [self.parseObject objectForKey:kCategoryModelForeignKeyName];
        if (parseCategory) {
            _category = [CKCategory categoryForParseCategory:parseCategory];
        }
    }
    
    return _category;
}

- (void)setCategory:(CKCategory *)category {
    [self.parseObject setObject:category.parseObject forKey:kCategoryModelForeignKeyName];
}

- (NSInteger)numServes {
    if (!_numServes) {
        _numServes = [[self.parseObject objectForKey:kRecipeAttrNumServes] integerValue];
    }
    return _numServes;
}

- (void)setNumServes:(NSInteger)numServes {
    [self.parseObject setObject:[NSNumber numberWithInt:numServes] forKey:kRecipeAttrNumServes];
}

- (void)setCookingTimeInMinutes:(NSInteger)cookingTimeInMinutes {
    [self.parseObject setObject:[NSNumber numberWithInt:cookingTimeInMinutes] forKey:kRecipeAttrCookingTimeInMinutes];
}

- (NSInteger)cookingTimeInMinutes {
    if (!_cookingTimeInMinutes) {
        _cookingTimeInMinutes = [[self.parseObject objectForKey:kRecipeAttrCookingTimeInMinutes] integerValue];
    }
    return _cookingTimeInMinutes;
}

- (void)setPrepTimeInMinutes:(NSInteger)prepTimeInMinutes {
    [self.parseObject setObject:[NSNumber numberWithInt:prepTimeInMinutes] forKey:kRecipeAttrPrepTimeInMinutes];
}

- (NSInteger)prepTimeInMinutes {
    if (!_prepTimeInMinutes) {
        _prepTimeInMinutes = [[self.parseObject objectForKey:kRecipeAttrPrepTimeInMinutes] integerValue];
    }
    return _prepTimeInMinutes;
}

- (void)setPrivacy:(BOOL)privacy {
    [self.parseObject setObject:[NSNumber numberWithBool:privacy] forKey:kRecipeAttrPrivacy];
}

- (BOOL)privacy {
    return [[self.parseObject objectForKey:kRecipeAttrPrivacy] boolValue];
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

#pragma mark - Private Methods

- (void)prepareParseRecipeObjectForSave:(PFObject*)parseRecipeObject {
    [parseRecipeObject setObject:self.user.parseObject forKey:kUserModelForeignKeyName];
    [parseRecipeObject setObject:self.book.parseObject forKey:kBookModelForeignKeyName];
    if (self.category && self.category.parseObject) {
        [parseRecipeObject setObject:self.category.parseObject forKey:kCategoryModelForeignKeyName];
    }
    [parseRecipeObject setObject:NSStringFromCGPoint(self.recipeViewImageContentOffset) forKey:kRecipeAttrRecipeViewImageContentOffset];
    if (self.numServes > 0) {
        [parseRecipeObject setObject:[NSNumber numberWithInt:self.numServes] forKey:kRecipeAttrNumServes];
    }
    
    if (self.cookingTimeInMinutes > 0) {
        [parseRecipeObject setObject:[NSNumber numberWithInt:self.cookingTimeInMinutes] forKey:kRecipeAttrCookingTimeInMinutes];
    }
    
    if (self.prepTimeInMinutes > 0) {
        [parseRecipeObject setObject:[NSNumber numberWithInt:self.cookingTimeInMinutes] forKey:kRecipeAttrPrepTimeInMinutes];
    }
    
    if (self.ingredients && [self.ingredients count] > 0) {
        NSArray *jsonCompatibleIngredients = [self.ingredients collect:^id(Ingredient *ingredient) {
            if (!ingredient.measurement) {
                return ingredient.name;
            } else {
                return [NSString stringWithFormat:@"%@::%@", ingredient.measurement,ingredient.name];
            }
        }];
        
        [parseRecipeObject setObject:jsonCompatibleIngredients forKey:kRecipeAttrIngredients];
    }
    
    // Now add the category to book.
    // Why is this here?
    [self.book.parseObject addUniqueObject:self.category.parseObject forKey:kBookAttrCategories];
}

@end
