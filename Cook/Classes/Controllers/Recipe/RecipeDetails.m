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
#import "CKLocation.h"
#import "CKRecipeTag.h"

@interface RecipeDetails ()

@end

@implementation RecipeDetails

+ (NSInteger)maxPrepCookMinutes {
    return 480.0;
}

+ (NSInteger)maxServes {
    return 12;
}

- (id)initWithRecipe:(CKRecipe *)recipe {
    return [self initWithRecipe:recipe book:recipe.book];
}

- (id)initWithRecipe:(CKRecipe *)recipe book:(CKBook *)book {
    if (self = [super init]) {
        self.book = book;
        self.originalRecipe = recipe;
        
        // Copy to the instance vars, bypassing the setters which will be used for update checking.
        _page = recipe.page;
        _availablePages = book.pages;
        _user = recipe.user;
        _name = recipe.name;
        _story = recipe.story;
        _tags = recipe.tags;
        _method = recipe.method;
        _numServes = recipe.numServes;
        _prepTimeInMinutes = recipe.prepTimeInMinutes;
        _cookingTimeInMinutes = recipe.cookingTimeInMinutes;
        _privacy = recipe.privacy;
        _userPhotoUrl = recipe.userPhotoUrl;
        _location = recipe.geoLocation;
        
        _ingredients = [NSArray arrayWithArray:[recipe.ingredients collect:^id(Ingredient *ingredient) {
            return [Ingredient ingredientwithName:ingredient.name measurement:ingredient.measurement];
        }]];
    }
    return self;
}

- (void)updateToRecipe:(CKRecipe *)recipe {
    recipe.page = self.page;
    recipe.name = self.name;
    recipe.tags = self.tags;
    recipe.story = self.story;
    recipe.method = self.method;
    recipe.numServes = self.numServes;
    recipe.prepTimeInMinutes = self.prepTimeInMinutes;
    recipe.cookingTimeInMinutes = self.cookingTimeInMinutes;
    recipe.ingredients = self.ingredients;
    recipe.privacy = self.privacy;
    recipe.geoLocation = self.location;
    
    // Re-assign original recipe.
    self.originalRecipe = recipe;
}

- (BOOL)pageUpdated {
    return ![self.originalRecipe.page CK_equalsIgnoreCase:self.page];
}

- (BOOL)nameUpdated {
    return ![self.originalRecipe.name CK_equals:self.name];
}

- (BOOL)tagsUpdated {
    return [self tagsChangedForTags:self.tags];
}

- (BOOL)storyUpdated {
    return ![self.originalRecipe.story CK_equals:self.story];
}

- (BOOL)methodUpdated {
    return ![self.originalRecipe.method CK_equals:self.method];
}

- (BOOL)servesPrepUpdated {
    return (([self.numServes integerValue] != [self.originalRecipe.numServes integerValue])
            || ([self.prepTimeInMinutes integerValue] != [self.originalRecipe.prepTimeInMinutes integerValue])
            || ([self.cookingTimeInMinutes integerValue] != [self.originalRecipe.cookingTimeInMinutes integerValue]));
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

- (BOOL)hasServes {
    return (self.numServes || self.prepTimeInMinutes || self.cookingTimeInMinutes);
}

- (BOOL)hasIngredients {
    return [self.ingredients count] > 0;
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

- (void)setTags:(NSArray *)tags {
    _tags = tags;
    BOOL tagsChanged = [self tagsChangedForTags:tags];
    if (tagsChanged) {
        self.saveRequired = YES;
    }
}

- (void)setMethod:(NSString *)method {
    _method = method;
    if (![self.originalRecipe.method CK_equals:method]) {
        self.saveRequired = YES;
    }
}

- (void)setNumServes:(NSNumber *)numServes {
    _numServes = numServes;
    if ([self.originalRecipe.numServes integerValue] != [numServes integerValue]) {
        self.saveRequired = YES;
    }
}

- (void)setPrepTimeInMinutes:(NSNumber *)prepTimeInMinutes {
    _prepTimeInMinutes = prepTimeInMinutes;
    if ([self.originalRecipe.prepTimeInMinutes integerValue] != [prepTimeInMinutes integerValue]) {
        self.saveRequired = YES;
    }
}

- (void)setCookingTimeInMinutes:(NSNumber *)cookingTimeInMinutes {
    _cookingTimeInMinutes = cookingTimeInMinutes;
    if ([self.originalRecipe.cookingTimeInMinutes integerValue] != [cookingTimeInMinutes integerValue]) {
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

- (void)setLocation:(CKLocation *)location {
    _location = location;
    
    if (location != nil) {
        if (self.originalRecipe.geoLocation != nil && ![self.originalRecipe.geoLocation isEqual:location]) {
            
            // Overwrite location.
            self.saveRequired = YES;
            
        } else if (self.originalRecipe.geoLocation == nil) {
            
            // Set location.
            self.saveRequired = YES;
        }
    } else {
        
        if (self.originalRecipe.geoLocation != nil) {
            
            // Clear location.
            self.saveRequired = YES;
        }
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

- (BOOL)tagsChangedForTags:(NSArray *)tags {
    __block BOOL tagsChanged = NO;
    
    if ([self.originalRecipe.tags count] != [tags count]) {
        tagsChanged = YES;
    } else {
        [self.originalRecipe.tags enumerateObjectsUsingBlock:^(CKRecipeTag *obj, NSUInteger idx, BOOL *stop) {
            if (obj.objectId != ((CKRecipeTag *)[tags objectAtIndex:idx]).objectId)
                tagsChanged = YES;
        }];
    }
    return tagsChanged;
}

@end
