//
//  CKRecipeSearchFieldView.h
//  CKRecipeSearchFieldViewDemo
//
//  Created by Jeff Tan-Ang on 27/03/2014.
//  Copyright (c) 2014 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKRecipeSearchFieldViewDelegate <NSObject>

- (BOOL)recipeSearchFieldShouldFocus;
- (NSString *)recipeSearchFieldViewPlaceholderText;
- (void)recipeSearchFieldViewSearchByText:(NSString *)text;
- (void)recipeSearchFieldViewClearRequested;

@end

@interface CKRecipeSearchFieldView : UIView

@property (nonatomic, strong) NSString *placeholderText;

- (id)initWithDelegate:(id<CKRecipeSearchFieldViewDelegate>)delegate;
- (CGSize)sizeForExpanded:(BOOL)expanded;
- (void)expand:(BOOL)expand;
- (void)expand:(BOOL)expand animated:(BOOL)animated;
- (void)focus:(BOOL)focus;
- (void)clearSearch;
- (void)setSearching:(BOOL)searching;

@end
