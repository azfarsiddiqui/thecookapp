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
#import "CKConstants.h"

@interface CKRecipe()
@property(nonatomic,strong) CKRecipeImage *recipeImage;
@property(nonatomic,strong) CKUser *user;
@property(nonatomic,strong) CKBook *book;
@end

@implementation CKRecipe

+(CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user {
    CKRecipe *recipe = [[CKRecipe alloc] initWithParseObject:parseRecipe];
    recipe.user = user;
    return recipe;
}

+(CKRecipe*) recipeForUser:(CKUser *)user book:(CKBook *)book
{
    PFObject *parseRecipe = [PFObject objectWithClassName:kRecipeModelName];
    CKRecipe *recipe = [[CKRecipe alloc] initWithParseObject:parseRecipe];
    recipe.user = user;
    recipe.book = book;
    return recipe;
}


+(void) imagesForRecipe:(CKRecipe*)recipe success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFRelation *images = [recipe.parseObject objectForKey:kRecipeAttrRecipeImages];
    if (images ) {
        [[images query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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

-(PFFile*) imageFile
{
    return [self.recipeImage imageFile];
}

-(void)saveWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure progress:(ProgressBlock)progress
{
    
    PFObject *parseRecipe = self.parseObject;
    [parseRecipe setObject:self.user.parseObject forKey:kUserModelForeignKeyName];
    [parseRecipe setObject:self.book.parseObject forKey:kBookModelForeignKeyName];
    
    if (self.recipeImage) {
        PFFile *imageFile = [self.recipeImage imageFile];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                failure(error);
            } else {
                //save rest of object
                [self.recipeImage.parseObject save];
                PFRelation *relation = [parseRecipe relationforKey:kRecipeAttrRecipeImages];
                [relation addObject:self.recipeImage.parseObject];
                [parseRecipe saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        failure(error);
                    } else {
                        success([CKRecipe recipeForParseRecipe:parseRecipe user:self.user]);
                    }
                }];
                
            }
        } progressBlock:^(int percentDone) {
            progress(percentDone);
        }];
    } else {
        [parseRecipe saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                failure(error);
            } else {
                success([CKRecipe recipeForParseRecipe:parseRecipe user:self.user]);
            }
        }];
    }
    
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

-(NSInteger)categoryIndex
{
    return [[self.parseObject objectForKey:kRecipeAttrCategoryIndex] intValue];
}

-(void)setCategoryIndex:(NSInteger)categoryIndex
{
    [self.parseObject setObject:[NSNumber numberWithInt:categoryIndex]forKey:kRecipeAttrCategoryIndex];
}

-(void)setImage:(UIImage *)image
{
    if (image) {
        self.recipeImage = [CKRecipeImage recipeImageForImage:image imageName:@"recipeImage.png"];
    }
}

@end
