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

@interface CKRecipe()
@property(nonatomic,strong) CKBook *book;
@end

@implementation CKRecipe

@synthesize category=_category;

#pragma mark - creation

+(CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user {
    CKRecipe *recipe = [[CKRecipe alloc] initWithParseObject:parseRecipe];
    
    NSArray *ingredients = [parseRecipe objectForKey:kRecipeAttrIngredients];
    if (ingredients && [ingredients count] > 0) {
        NSMutableArray *ingredientsArray = [NSMutableArray arrayWithCapacity:[ingredients count]];
        [ingredients each:^(NSString *ingredient) {
            Ingredient *ing = nil;
            if ([ingredient rangeOfString:@"::"].location != NSNotFound) {
                NSArray *ingredientComponents = [ingredient componentsSeparatedByString:@"::"];
                NSString *measurement = [ingredientComponents objectAtIndex:0];
                NSString *ingredientName = [ingredientComponents objectAtIndex:1];
                ing = [Ingredient ingredientwithName:ingredientName measurement:measurement];
            } else {
                ing = [Ingredient ingredientwithName:ingredient measurement:nil];
            }
            [ingredientsArray addObject:ing];
        }];
        recipe.ingredients = [NSArray arrayWithArray:ingredientsArray];
        NSString *recipeViewContentOffset = [parseRecipe objectForKey:kRecipeAttrRecipeViewImageContentOffset];
        if (recipeViewContentOffset) {
            recipe.recipeViewImageContentOffset = CGPointFromString(recipeViewContentOffset);
        }
        
        NSNumber *cookingTime = [parseRecipe objectForKey:kRecipeAttrCookingTimeInSeconds];
        if (cookingTime) {
            recipe.cookingTimeInSeconds = [cookingTime floatValue];
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

+(CKRecipe*) recipeForUser:(CKUser *)user book:(CKBook *)book category:(Category *)category
{
    PFObject *parseRecipe = [self objectWithDefaultSecurityWithClassName:kRecipeModelName];
    CKRecipe *recipe = [self recipeForParseRecipe:parseRecipe user:user];
    recipe.book = book;
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
                        
                        // Add as an array to support multiple photos.
                        [self.parseObject addObject:self.recipeImage.parseObject forKey:kRecipeAttrRecipePhotos];
                        
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
+(void) fetchImagesForRecipe:(CKRecipe*)recipe success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFRelation *images = [recipe.parseObject objectForKey:kRecipeAttrRecipeImages];
    PFQuery *query = [images query];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    if (images) {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects && [objects count] > 0) {
                recipe.recipeImage = [CKRecipeImage recipeImageForParseRecipeImage:[objects objectAtIndex:0]];
                if (!error) {
                    success();
                } else {
                    failure(error);
                }
            }
        }];
    }
}

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
-(Category *)category
{
    if (!_category) {
        PFObject *parseCategory = [self.parseObject objectForKey:kCategoryModelForeignKeyName];
        if (parseCategory) {
            _category = [Category categoryForParseCategory:parseCategory];
        }
    }
    
    return _category;

}

-(void)prepareParseRecipeObjectForSave:(PFObject*)parseRecipeObject
{
    [parseRecipeObject setObject:self.user.parseObject forKey:kUserModelForeignKeyName];
    [parseRecipeObject setObject:self.book.parseObject forKey:kBookModelForeignKeyName];
    [parseRecipeObject setObject:self.category.parseObject forKey:kCategoryModelForeignKeyName];
    [parseRecipeObject setObject:NSStringFromCGPoint(self.recipeViewImageContentOffset) forKey:kRecipeAttrRecipeViewImageContentOffset];
    if (self.numServes > 0) {
        [parseRecipeObject setObject:[NSNumber numberWithInt:self.numServes] forKey:kRecipeAttrNumServes];
    }
    
    if (self.cookingTimeInSeconds > 0.0f) {
        [parseRecipeObject setObject:[NSNumber numberWithFloat:self.cookingTimeInSeconds] forKey:kRecipeAttrCookingTimeInSeconds];
    }
    
    if (self.ingredients && [self.ingredients count] > 0) {
        NSArray *jsonCompatibleIngredients = [self.ingredients collect:^id(Ingredient *ingredient) {
            return ingredient.name;
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


@end
