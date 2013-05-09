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

@interface CKRecipe ()

@end

@implementation CKRecipe

@synthesize category = _category;

#pragma mark - creation

+ (CKRecipe *)recipeForBook:(CKBook *)book {
    PFObject *parseRecipe = [self objectWithDefaultSecurityWithClassName:kRecipeModelName];
    CKRecipe *recipe = [[CKRecipe alloc] initWithParseObject:parseRecipe];
    recipe.book = book;
    return recipe;
}

+(CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user {
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

+(CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user book:(CKBook *)book
{
    CKRecipe *recipe = [self recipeForParseRecipe:parseRecipe user:user];
    recipe.book = book;
    return recipe;
}

+(CKRecipe *)recipeForUser:(CKUser *)user book:(CKBook *)book
{
    PFObject *parseRecipe = [self objectWithDefaultSecurityWithClassName:kRecipeModelName];
    CKRecipe *recipe = [self recipeForParseRecipe:parseRecipe user:user];
    recipe.book = book;
    return recipe;
}

+(CKRecipe*) recipeForUser:(CKUser *)user book:(CKBook *)book category:(CKCategory *)category
{
    CKRecipe *recipe = [CKRecipe recipeForUser:user book:book];
    recipe.category = category;
    return recipe;
}
#pragma mark - save
-(void)saveAndUploadImageWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure imageUploadProgress:(ProgressBlock)imageUploadProgress
{
    
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
-(void) fetchCategoryNameWithSuccess:(GetObjectSuccessBlock)getObjectSuccess
{
    [self.category.parseObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        getObjectSuccess(_category.name);
    }];
}

#pragma mark - other public
-(PFFile*) imageFile
{
    return [self.recipeImage imageFile];
}

- (BOOL)hasPhotos {
    return ([self imageFile] != nil);
}

-(void)setImage:(UIImage *)image
{
    if (image) {
        self.recipeImage = [CKRecipeImage recipeImageForImage:image imageName:@"recipeImage.png"];
    }
}

-(BOOL)isUserRecipeAuthor:(CKUser *)user
{
    return  [self.user isEqual:user];
}

#pragma mark - Private Methods

-(void)prepareParseRecipeObjectForSave:(PFObject*)parseRecipeObject
{
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

#pragma mark - Overridden methods
-(NSString *)description
{
    return [self.parseObject objectForKey:kRecipeAttrDescription];
}

-(void)setDescription:(NSString *)description
{
    [self.parseObject setObject:description forKey:kRecipeAttrDescription];
}

- (NSString *)story {
    return [self.parseObject objectForKey:kRecipeAttrStory];
}

-(void)setStory:(NSString *)story {
    [self.parseObject setObject:story forKey:kRecipeAttrStory];
}

-(NSInteger)categoryIndex
{
    return [[self.parseObject objectForKey:kRecipeAttrCategoryIndex] intValue];
}

-(void)setCategoryIndex:(NSInteger)categoryIndex
{
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
    _category = category;
    [self.parseObject setObject:category.parseObject forKey:kCategoryModelForeignKeyName];
}

- (void)setNumServes:(NSInteger)numServes {
    _numServes = numServes;
    [self.parseObject setObject:[NSNumber numberWithInt:numServes] forKey:kRecipeAttrNumServes];
}

- (void)setCookingTimeInMinutes:(NSInteger)cookingTimeInMinutes {
    _cookingTimeInMinutes = cookingTimeInMinutes;
    [self.parseObject setObject:[NSNumber numberWithInt:cookingTimeInMinutes] forKey:kRecipeAttrCookingTimeInMinutes];
}

- (void)setPrepTimeInMinutes:(NSInteger)prepTimeInMinutes {
    _prepTimeInMinutes = prepTimeInMinutes;
    [self.parseObject setObject:[NSNumber numberWithInt:prepTimeInMinutes] forKey:kRecipeAttrPrepTimeInMinutes];
}

@end
