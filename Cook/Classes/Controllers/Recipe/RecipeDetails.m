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

+ (NSInteger)maxMakes {
    return 60;
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
        // Check if tag pointer resolves and ignores invalid tags
        NSMutableArray *tempTags = [NSMutableArray new];
        [recipe.tags enumerateObjectsUsingBlock:^(CKRecipeTag *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.parseObject respondsToSelector:@selector(fetchIfNeeded)])
                [tempTags addObject:obj];
        }];
        _tags = tempTags;
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
        
        _locale = recipe.locale;
        _quantityType = recipe.quantityType;
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
    recipe.quantityType = self.quantityType;
    
    // Re-assign original recipe.
    self.originalRecipe = recipe;
}

- (BOOL)pageUpdated {
    BOOL pageUpdated = ![self.originalRecipe.page CK_equalsIgnoreCase:self.page];
    DLog(@"pageUpdated[%@]", [NSString CK_stringForBoolean:pageUpdated]);
    return pageUpdated;
}

- (BOOL)nameUpdated {
    BOOL nameUpdated = NO;
    if (self.originalRecipe.name) {
        nameUpdated = ![self.originalRecipe.name CK_equals:self.name];
    } else {
        nameUpdated = ([self.name length] > 0);
    }
    
    DLog(@"nameUpdated[%@]", [NSString CK_stringForBoolean:nameUpdated]);
    return nameUpdated;
}

- (BOOL)imageUpdated {
    BOOL imageUpdated = (self.image != nil);
    DLog(@"imageUpdated[%@]", [NSString CK_stringForBoolean:imageUpdated]);
    return imageUpdated;
}

- (BOOL)tagsUpdated {
    BOOL tagsUpdated = [self tagsChangedForTags:self.tags];
    DLog(@"tagsUpdated[%@]", [NSString CK_stringForBoolean:tagsUpdated]);
    return tagsUpdated;
}

- (BOOL)storyUpdated {
    BOOL storyUpdated = NO;
    if (self.originalRecipe.story) {
        storyUpdated = ![self.originalRecipe.story CK_equals:self.story];
    } else {
        storyUpdated = ([self.story length] > 0);
    }

    DLog(@"storyUpdated[%@]", [NSString CK_stringForBoolean:storyUpdated]);
    return storyUpdated;
}

- (BOOL)methodUpdated {
    BOOL methodUpdated = NO;
    if (self.originalRecipe.story) {
        methodUpdated = ![self.originalRecipe.method CK_equals:self.method];
    } else {
        methodUpdated = ([self.method length] > 0);
    }
    
    DLog(@"methodUpdated[%@]", [NSString CK_stringForBoolean:methodUpdated]);
    return methodUpdated;
}

- (BOOL)servesPrepUpdated {
    BOOL servesPrepUpdated = (([self.numServes integerValue] != [self.originalRecipe.numServes integerValue])
                              || ([self.prepTimeInMinutes integerValue] != [self.originalRecipe.prepTimeInMinutes integerValue])
                              || ([self.cookingTimeInMinutes integerValue] != [self.originalRecipe.cookingTimeInMinutes integerValue]));
    BOOL quantityTypeUpdated = self.quantityType != self.originalRecipe.quantityType;
    DLog(@"servesPrepUpdated[%@]", [NSString CK_stringForBoolean:servesPrepUpdated]);
    return servesPrepUpdated || quantityTypeUpdated;
}

- (BOOL)ingredientsUpdated {
    BOOL ingredientsUpdated = NO;
    ingredientsUpdated = [self ingredientsChangedForIngredients:self.ingredients];
    DLog(@"ingredientsUpdated[%@]", [NSString CK_stringForBoolean:ingredientsUpdated]);
    return ingredientsUpdated;
}

- (BOOL)locationUpdated {
    BOOL locationUpdated = NO;
    
    if (![self isNew]) {
        
        if (self.location && !self.originalRecipe.geoLocation) {
            
            // Has location but not in original.
            locationUpdated = YES;
            
        } else if (self.location == nil && self.originalRecipe.geoLocation) {
            
            // No location but has in original.
            locationUpdated = YES;
            
        } else if (self.location && self.originalRecipe.geoLocation) {
            
            // Both has locations, then do logical compare.
            return ![self.location isEqual:self.originalRecipe.geoLocation];
            
        }
    }
    
    DLog(@"locationUpdated[%@]", [NSString CK_stringForBoolean:locationUpdated]);
    return locationUpdated;
}

- (BOOL)privacyUpdated {
    BOOL privacyUpdated = NO;
    if ([self isNew]) {
        privacyUpdated = (self.originalRecipe.privacy != CKPrivacyPublic);
    } else {
        privacyUpdated = (self.originalRecipe.privacy != self.privacy);
    }
    DLog(@"privacyUpdated[%@]", [NSString CK_stringForBoolean:privacyUpdated]);
    return privacyUpdated;
}

- (BOOL)saveRequired {
    BOOL needsSaving = [self privacyUpdated]
                        || [self locationUpdated]
                        || [self pageUpdated]
                        || [self imageUpdated]
                        || [self nameUpdated]
                        || [self tagsUpdated]
                        || [self storyUpdated]
                        || [self servesPrepUpdated]
                        || [self ingredientsUpdated]
                        || [self methodUpdated];
    DLog(@"Original Recipe: %@ needsSaving[%@]", self.originalRecipe, [NSString CK_stringForBoolean:needsSaving]);
    return needsSaving;
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

- (BOOL)isNew {
    return ![self.originalRecipe persisted];
}

#pragma mark - Properties.

- (void)setPage:(NSString *)page {
    _page = page;
}

- (void)setName:(NSString *)name {
    _name = name;
}

- (void)setStory:(NSString *)story {
    _story = story;
}

- (void)setTags:(NSArray *)tags {
    _tags = tags;
}

- (void)setMethod:(NSString *)method {
    _method = method;
}

- (void)setNumServes:(NSNumber *)numServes {
    _numServes = numServes;
}

- (void)setPrepTimeInMinutes:(NSNumber *)prepTimeInMinutes {
    _prepTimeInMinutes = prepTimeInMinutes;
}

- (void)setCookingTimeInMinutes:(NSNumber *)cookingTimeInMinutes {
    _cookingTimeInMinutes = cookingTimeInMinutes;
}

- (void)setIngredients:(NSArray *)ingredients {
    _ingredients = ingredients;
}

- (void)setImage:(UIImage *)image {
    _image = image;
}

- (void)setPrivacy:(CKPrivacy)privacy {
    _privacy = privacy;
}

- (void)setLocation:(CKLocation *)location {
    _location = location;
}

- (NSDate *)createdDateTime {
    return self.originalRecipe.createdDateTime;
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
