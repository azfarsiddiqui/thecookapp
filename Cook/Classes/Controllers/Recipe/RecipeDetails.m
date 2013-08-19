//
//  RecipeDetails.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeDetails.h"
#import "Ingredient.h"
#import "MRCEnumerable.h"
#import "NSString+Utilities.h"

@interface RecipeDetails ()

@end

@implementation RecipeDetails

- (id)initWithRecipe:(CKRecipe *)recipe {
    if (self = [super init]) {
        self.originalRecipe = recipe;
        
        // Copy to the instance vars, bypassing the setters which will be used for update checking.
        _page = recipe.page;
        _availablePages = recipe.book.pages;
        _user = recipe.user;
        _name = recipe.name;
        _story = recipe.story;
        _method = recipe.method;
        _numServes = recipe.numServes;
        _prepTimeInMinutes = recipe.prepTimeInMinutes;
        _cookingTimeInMinutes = recipe.cookingTimeInMinutes;
        _privacy = recipe.privacy;
        
        _ingredients = [NSArray arrayWithArray:[recipe.ingredients collect:^id(Ingredient *ingredient) {
            return [Ingredient ingredientwithName:ingredient.name measurement:ingredient.measurement];
        }]];
    }
    return self;
}

- (void)updateToRecipe:(CKRecipe *)recipe {
    recipe.page = self.page;
    recipe.name = self.name;
    recipe.story = self.story;
    recipe.method = self.method;
    recipe.numServes = self.numServes;
    recipe.prepTimeInMinutes = self.prepTimeInMinutes;
    recipe.cookingTimeInMinutes = self.cookingTimeInMinutes;
    recipe.ingredients = self.ingredients;
    recipe.privacy = self.privacy;
}

- (BOOL)pageUpdated {
    return ![self.originalRecipe.page CK_equalsIgnoreCase:self.page];
}

- (BOOL)nameUpdated {
    return ![self.originalRecipe.name CK_equals:self.name];
}

- (BOOL)storyUpdated {
    return ![self.originalRecipe.story CK_equals:self.story];
}

- (BOOL)methodUpdated {
    return ![self.originalRecipe.method CK_equals:self.method];
}

- (BOOL)servesPrepUpdated {
    return ((self.originalRecipe.numServes != self.numServes)
            || (self.originalRecipe.prepTimeInMinutes != self.prepTimeInMinutes)
            || (self.originalRecipe.cookingTimeInMinutes != self.cookingTimeInMinutes));
}

- (BOOL)ingredientsUpdated {
    return [self ingredientsChangedForIngredients:self.ingredients];
}

- (BOOL)privacyUpdated {
    return (self.originalRecipe.privacy != self.privacy);
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

#pragma mark - Properties.

- (void)setPage:(NSString *)page {
    _page = page;
    if (![self.originalRecipe.page CK_equalsIgnoreCase:page]) {
        self.saveRequired = YES;
    }
}

- (void)setName:(NSString *)name {
    _name = name;
    if (![self.originalRecipe.name CK_equals:name]) {
        self.saveRequired = YES;
    }
}

- (void)setStory:(NSString *)story {
    _story = story;
    if (![self.originalRecipe.story CK_equals:story]) {
        self.saveRequired = YES;
    }
}

- (void)setMethod:(NSString *)method {
    _method = method;
    if (![self.originalRecipe.method CK_equals:method]) {
        self.saveRequired = YES;
    }
}

- (void)setNumServes:(NSInteger)numServes {
    _numServes = numServes;
    if (self.originalRecipe.numServes != numServes) {
        self.saveRequired = YES;
    }
}

- (void)setPrepTimeInMinutes:(NSInteger)prepTimeInMinutes {
    _prepTimeInMinutes = prepTimeInMinutes;
    if (self.originalRecipe.prepTimeInMinutes != prepTimeInMinutes) {
        self.saveRequired = YES;
    }
}

- (void)setCookingTimeInMinutes:(NSInteger)cookingTimeInMinutes {
    _cookingTimeInMinutes = cookingTimeInMinutes;
    if (self.originalRecipe.cookingTimeInMinutes != cookingTimeInMinutes) {
        self.saveRequired = YES;
    }
}

- (void)setIngredients:(NSArray *)ingredients {
    BOOL ingredientsChanged = [self ingredientsChangedForIngredients:ingredients];
    _ingredients = ingredients;
    if (ingredientsChanged) {
        self.saveRequired = YES;
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.saveRequired = (image != nil);
}

- (void)setPrivacy:(CKPrivacy)privacy {
    _privacy = privacy;
    if (self.originalRecipe.privacy != privacy) {
        self.saveRequired = YES;
    }
}

#pragma mark - Private methods

- (BOOL)ingredientsChangedForIngredients:(NSArray *)ingredients {
    BOOL ingredientsChanged = NO;
    
    if ([self.originalRecipe.ingredients count] != [ingredients count]) {
        ingredientsChanged = YES;
        
    } else {
        
        // Examine each ingredient.
        for (NSUInteger ingredientIndex = 0; ingredientIndex < [ingredients count]; ingredientIndex++) {
            Ingredient *originalIngredient = [self.originalRecipe.ingredients objectAtIndex:ingredientIndex];
            Ingredient *currentIngredient = [ingredients objectAtIndex:ingredientIndex];
            
            // If the ingredient pairs are different, then save worthy, and break from loop.
            if (![originalIngredient.measurement CK_equals:currentIngredient.measurement]
                || ![originalIngredient.name CK_equals:currentIngredient.name]) {
                ingredientsChanged = YES;
                break;
            }
        }
    }
    
    return ingredientsChanged;
}

@end
